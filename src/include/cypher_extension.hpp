#pragma once

#include "duckdb.hpp"

class Parser;
extern Parser parser;

class Traverse;
extern Traverse trv;

namespace duckdb
{
	class CypherExtension : public Extension
	{
	public:
		void Load(DuckDB &db) override;
		std::string Name() override;

		static TableFunction GetTableFunction();
	};
} // namespace duckdb
