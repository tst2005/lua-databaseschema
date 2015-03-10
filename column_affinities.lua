--[[--------------------------------------------------------
	-- Database Schema - A SQL Table Schema Tool for Lua --
	-- Copyright (c) 2014-2015 TsT worldmaster.fr --
--]]--------------------------------------------------------

-- https://www.sqlite.org/datatype3.html # 2.1 Determination Of Column Affinity
-- The affinity of a column is determined by the declared type of the column, according to the following rules in the order shown:
--    1.[INTEGER] If the declared type contains the string "INT" then it is assigned INTEGER affinity.
--    2.[TEXT]    If the declared type of the column contains any of the strings "CHAR", "CLOB", or "TEXT" then that column has TEXT affinity. Notice that the type VARCHAR contains the string "CHAR" and is thus assigned TEXT affinity.
--    3.[NONE]    If the declared type for a column contains the string "BLOB" or if no type is specified then the column has affinity NONE.
--    4.[REAL]    If the declared type for a column contains any of the strings "REAL", "FLOA", or "DOUB" then the column has REAL affinity.
--    5.[NUMERIC] Otherwise, the affinity is NUMERIC.
--
-- Note that the order of the rules for determining column affinity is important. A column whose declared type is "CHARINT" will match both rules 1 and 2 but the first rule takes precedence and so the column affinity will be INTEGER.
--


local column_affinities = {
	['sqlite'] = {
		{	"INTEGER",	{	"INT"			},	},
		{	"TEXT",		{	"CHAR", "CLOB", "TEXT", },	},
		{	"NONE",		{	"BLOB",			},	},
		{	"REAL",		{	"REAL", "FLOA", "DOUB",	},	},
		default = "NUMERIC",
		no_datatype_specified = "NONE",
	}
}

local function column_affinity_to_native(fieldtype, dbtype)
	assert(dbtype, "You must specify the dbtype")
	local column_affinities = assert(column_affinities[dbtype], "No such column affinity for "..dbtype)

	if not fieldtype or fieldtype == "" then return column_affinities.no_datatype_specified end

	local fieldtype = fieldtype:upper()
	for i,v in ipairs(column_affinities) do
		local affinity = v[1]
		for i2, patn in ipairs(v[2]) do
			if fieldtype:find(patn, nil, true) then
				return affinity
			end
		end
	end
	return column_affinities.default
end

do
	local selftests_sqlite = {
		["ZZZ"]			= "NUMERIC",
		["CHARINT"]		= "INTEGER",
		["UNSIGNED BIG INT"]	= "INTEGER",
		["BLOB"]		= "NONE",
		["FLOAT"]		= "REAL",
		["BOOLEAN"]		= "NUMERIC",
	}
	for k,v in pairs(selftests_sqlite) do assert( v == column_affinity_to_native(k, 'sqlite') ) end
end

local _M = {}

_M.to_native = column_affinity_to_native
_M.column_affinities = column_affinities

return _M
