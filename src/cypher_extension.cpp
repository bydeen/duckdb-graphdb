#define DUCKDB_EXTENSION_MAIN

#include "duckdb.hpp"
#include "duckdb/common/exception.hpp"
#include "duckdb/common/string_util.hpp"
#include "duckdb/function/scalar_function.hpp"
#include "duckdb/main/extension_util.hpp"
#include <duckdb/parser/parsed_data/create_scalar_function_info.hpp>

#include "cypher_extension.hpp"

#include "minirel.h"
#include "bf.h"
#include "pf.h"
#include "hf.h"
#include "trv.h"
#include "fe.h"

Parser parser;

namespace duckdb
{
    void CypherExtension::Load(DuckDB &db)
    {
        if (parser.InitJVM() != FEE_OK)
            throw Exception(ExceptionType::PARSER, "Initializing JVM failed");

        // dummy execution to initialize the parser
        MatchDesc match_desc;
        WhereDesc where_desc;
        ReturnDesc return_desc;

        if (parser.ParseCypher("MATCH ()-[]-()", match_desc, where_desc, return_desc) != FEE_OK)
        {
            parser.DestroyJVM();
            throw Exception(ExceptionType::PARSER, "Parsing Cypher failed");
        }

        if (TRV_Init() != TRVE_OK)
        {
            parser.DestroyJVM();
            throw Exception(ExceptionType::INTERNAL, "Initializing traverse layer failed");
        }

        auto table_function = CypherExtension::GetTableFunction();
        ExtensionUtil::RegisterFunction(*db.instance, table_function);
    }
    std::string CypherExtension::Name()
    {
        return "cypher";
    }
} // namespace duckdb

extern "C"
{
    DUCKDB_EXTENSION_API void cypher_init(duckdb::DatabaseInstance &db)
    {
        duckdb::DuckDB db_wrapper(db);
        db_wrapper.LoadExtension<duckdb::CypherExtension>();
    }

    DUCKDB_EXTENSION_API const char *cypher_version()
    {
        return duckdb::DuckDB::LibraryVersion();
    }
}

#ifndef DUCKDB_EXTENSION_MAIN
#error DUCKDB_EXTENSION_MAIN not defined
#endif
