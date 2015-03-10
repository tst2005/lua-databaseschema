--[[--------------------------------------------------------
	-- Database Schema - A SQL Table Schema Tool for Lua --
	-- Copyright (c) 2014-2015 TsT worldmaster.fr --
--]]--------------------------------------------------------
local target = "databaseschema"
local path = (... or ""):gsub("%.[^%.]+$", "");path=path~="" and path.."." or ""
return require(path..target)
