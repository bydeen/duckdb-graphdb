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
        vector<vector<string>> column_values;
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

    void QueueToColumnValues(std::queue<std::queue<std::string>> &result, vector<vector<string>> &column_values)
    {
        while (!result.empty())
        {
            auto inner_queue = result.front();
            result.pop();

            vector<string> row;
            while (!inner_queue.empty())
            {
                row.push_back(inner_queue.front());
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
                // FlatVector::GetData<string_t>(output.data[cidx])[count] = column_values[lstate.row_index][cidx].ToString();
                FlatVector::GetData<string_t>(output.data[cidx])[count] = column_values[lstate.row_index][cidx];
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
        string cypher_query = input.inputs[0].GetValue<std::string>();

        size_t sql_pos = cypher_query.find("sql(");
        size_t sql_end_pos = cypher_query.find(")", sql_pos);

        if (sql_pos != string::npos && sql_end_pos != string::npos)
        {
            Connection conn(*(context.db));
            const string sql_query = cypher_query.substr(sql_pos + 4, sql_end_pos - sql_pos - 4);
            cout << "Extracted SQL query: " << sql_query << endl;

            auto sql_result = conn.Query(sql_query);
            // auto sql_result = context.Query(sql_query, false);
            D_ASSERT(!sql_result->HasError());

            string in_clause = "[";

            while (true)
            {
                auto chunk = sql_result->Fetch();
                if (!chunk || chunk->size() == 0)
                {
                    break;
                }
                for (idx_t row = 0; row < chunk->size(); row++)
                {
                    auto value = chunk->GetValue(0, row);
                    in_clause += value.ToString();
                    if (row < chunk->size() - 1)
                    {
                        in_clause += ", ";
                    }
                }
            }
            in_clause += "]";

            cypher_query.replace(sql_pos, sql_end_pos - sql_pos + 1, in_clause);
        }

        cout << "Cypher query: " << cypher_query << endl;

        MatchDesc match_desc;
        WhereDesc where_desc;
        ReturnDesc return_desc;

        if (parser.ParseCypher(cypher_query, match_desc, where_desc, return_desc) != FEE_OK)
        {
            parser.DestroyJVM();
            throw Exception(ExceptionType::PARSER, "Parsing Cypher failed");
        }

        int tid = TRV_AddTraversal(match_desc, where_desc, return_desc);
        queue<queue<string>> results = TRV_GetResults(tid);

        unique_ptr<GraphReadData> bind_data = make_uniq<GraphReadData>();
        QueueToColumnValues(results, bind_data->column_values);

        for (auto &ret : return_desc.variables)
        {
            return_types.push_back(LogicalType::VARCHAR); // TODO: Use the correct type
            names.emplace_back(ret.first + "." + ret.second);
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
