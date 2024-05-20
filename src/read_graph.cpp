#include "duckdb.hpp"
#include "duckdb/common/exception.hpp"
#include "duckdb/function/table_function.hpp"
#include "duckdb/main/extension_util.hpp"
#include "duckdb/parser/parsed_data/create_table_function_info.hpp"

#include "cypher_extension.hpp"

#include "minirel.h"
#include "bf.h"
#include "pf.h"
#include "hf.h"
#include "trv.h"
#include "fe.h"

namespace duckdb
{
    struct GraphReadData : public TableFunctionData
    {
        vector<vector<Value>> column_values;
    };

    struct GraphReadGlobalState : public GlobalTableFunctionState
    {
        bool finished;
        GraphReadGlobalState() : finished(false) {}
    };

    struct GraphReadLocalState : public LocalTableFunctionState
    {
        idx_t row_index;
        GraphReadLocalState() : row_index(0) {}
    };

    void QueueToColumnValues(std::queue<std::queue<std::string>> &result, vector<vector<Value>> &column_values)
    {
        while (!result.empty())
        {
            auto inner_queue = result.front();
            result.pop();

            vector<Value> row;
            while (!inner_queue.empty())
            {
                row.push_back(Value(inner_queue.front()));
                inner_queue.pop();
            }

            column_values.push_back(row);
        }
    }

    static void ReadGraphFunction(ClientContext &context, TableFunctionInput &data_p, DataChunk &output)
    {
        auto &data = data_p.bind_data->Cast<GraphReadData>();
        auto &gstate = data_p.global_state->Cast<GraphReadGlobalState>();
        auto &lstate = data_p.local_state->Cast<GraphReadLocalState>();

        if (gstate.finished)
        {
            output.SetCardinality(0);
            output.Verify();
            return;
        }

        auto &column_values = data.column_values;
        idx_t col_count = column_values.empty() ? 0 : column_values[0].size();
        idx_t row_count = column_values.size();

        idx_t count = 0;
        while (lstate.row_index < row_count && count < STANDARD_VECTOR_SIZE)
        {
            for (idx_t cidx = 0; cidx < col_count; cidx++)
            {
                FlatVector::GetData<string_t>(output.data[cidx])[count] = column_values[lstate.row_index][cidx].ToString();
            }

            lstate.row_index++;
            count++;
        }

        output.SetCardinality(count);
        output.Verify();

        if (lstate.row_index >= row_count)
        {
            gstate.finished = true;
        }
    }

    unique_ptr<FunctionData> ReadGraphBind(ClientContext &context, TableFunctionBindInput &input, vector<LogicalType> &return_types, vector<string> &names)
    {
        MatchDesc match_desc;
        ReturnDesc return_desc;

        if (parser.ParseCypher(input.inputs[0].GetValue<std::string>(), match_desc, return_desc) != FEE_OK)
        {
            parser.DestroyJVM();
            throw Exception(ExceptionType::PARSER, "Parsing Cypher failed");
        }
        if (trv.execute(match_desc, return_desc) != TRVE_OK)
        {
            trv.closeDBFiles();
            throw Exception(ExceptionType::EXECUTOR, "Executing traverse failed");
        }

        unique_ptr<GraphReadData> bind_data = make_uniq<GraphReadData>();
        QueueToColumnValues(trv.returnRes, bind_data->column_values);

        for (auto &ret : return_desc.variables)
        {
            return_types.push_back(LogicalType::VARCHAR); // TODO: Use the correct type
            names.emplace_back(ret.second);
        }

        return std::move(bind_data);
    }

    unique_ptr<GlobalTableFunctionState> ReadGraphGlobalStateInit(ClientContext &context, TableFunctionInitInput &input)
    {
        return make_uniq<GraphReadGlobalState>();
    }

    unique_ptr<LocalTableFunctionState> ReadGraphLocalStateInit(ExecutionContext &context, TableFunctionInitInput &input, GlobalTableFunctionState *gstate)
    {
        return make_uniq<GraphReadLocalState>();
    }

    TableFunction CypherExtension::GetTableFunction()
    {
        TableFunction function("cypher", {LogicalType::VARCHAR}, ReadGraphFunction, ReadGraphBind, ReadGraphGlobalStateInit, ReadGraphLocalStateInit);

        return function;
    }
}
