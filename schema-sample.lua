--[[--------------------------------------------------------
	-- Database Schema - A SQL Table Schema Tool for Lua --
	-- Copyright (c) 2014-2015 TsT worldmaster.fr --
--]]--------------------------------------------------------

local schema = require("schema-sample.init")
local databaseschema = require("databaseschema")

local column_affinities = require("column_affinities")
local column_affinity_to_native = column_affinities.to_native
-- column_affinities.column_affinities['sqlite']

local dbtype = 'sqlite'
local x = databaseschema.schemaToSql(schema, dbtype)
for k,v in pairs(x) do
	print(v)
end



