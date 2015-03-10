--[[--------------------------------------------------------
	-- Database Schema - A SQL Table Schema Tool for Lua --
	-- Copyright (c) 2014-2015 TsT worldmaster.fr --
--]]--------------------------------------------------------

------------------------------------------------------------------------------
-- hoPairs --
-------------
--
--local hoPairs = assert( require("orderedpairs").hoPairs )
--
--
-- original source : http://lua-users.org/wiki/SortedIteration
--
-- Ordered table iterator, allow to iterate on the natural order of the keys
-- of a table.

local function cmp_multitype(op1, op2)
	local type1, type2 = type(op1), type(op2)
	if type1 ~= type2 then --cmp by type
		return type1 < type2
	elseif type1 == "number" and type2 == "number"
		or type1 == "string" and type2 == "string" then
		return op1 < op2 --comp by default
	elseif type1 == "boolean" and type2 == "boolean" then
		return op1 == true
	else
		return tostring(op1) < tostring(op2) --cmp by address
	end
end

local function __genHybrideOrderedIndex( t )
	local orderedIndex = {}
	local rev = {}
	for key,val in pairs(t) do
		if type(key) == "string" then
			table.insert( orderedIndex, key )
		else
			rev[val] = key -- rev['id'] = n
		end
	end
	local function cmp_keyorder(op1, op2)
		-- type are all strings here
		local r1,r2 = rev[op1], rev[op2]
		local type1, type2 = type(r1), type(r2)
		if type1 ~= type2 then -- string VS number (or n VS s)
			return type1 == "number" -- forced first
		end
		if not r1 and not r2 then -- no forced order : alphabetical order
			return tostring(op1) < tostring(op2)
		end
		return r1 < r2
	end
	table.sort( orderedIndex, cmp_keyorder )
	return orderedIndex
end

local function genericNext(t, state, genindex)
	local genindex = genindex or __genOrderedIndex
	local key
	--print("orderedNext: state = "..tostring(state) )
	if state == nil then -- the first time, generate the index
		t.__orderedIndex = genindex( t )
		key = t.__orderedIndex[1]
		return key, t[key]
	end

	-- fetch the next value
	key = nil
	for i = 1,table.getn(t.__orderedIndex) do
		if t.__orderedIndex[i] == state then
			key = t.__orderedIndex[i+1]
		end
	end

	if key then
		return key, t[key]
	end

	-- no more value to return, cleanup
	t.__orderedIndex = nil
	return
end

local function hoNext(t, state)
	return genericNext(t, state, __genHybrideOrderedIndex)
end

local function hoPairs(t)
	return hoNext, t, nil
end

--
------------------------------------------------------------------------------


--local dbtype = 'mysql'
--local dbtype = 'sqlite'

local datatypes = {
	['serial'] = {
		-- stub
	},
	['int'] = {
		['mysql'] = 'int',
		['sqlite'] = 'INTEGER',
	},
	['float'] = {
		-- stub
	},
	['numeric'] = {
		-- stub
	},
	['varchar'] = {
		['mysql']  = 'varchar',
		['sqlite'] = 'VARCHAR',
	},
	['char'] = {
		-- stub
	},
	['text'] = {
		['sqlite'] = 'TEXT',
		-- stub
	},
	['blob'] = {
		-- stub
	},
	['datetime'] = {
		['sqlite'] = 'datetime',
		-- stub
	}
}

-- getDbFieldType( string abstractType )
-- Input: (String) string Generic Type of DB Field - see datatypes table
-- Output: (String) Returns Type specific to database implementation (mysql, sqlite)
--
local function getDbFieldType(abstractType, dbtype)
	return assert(dbtype, "missing dbtype") and datatypes and datatypes[abstractType] and datatypes[abstractType][dbtype]
end

local function renderLine(linetab)
	if type(linetab) == "string" then return linetab end
	local sep = linetab.sep or '' -- separator
	local bol = linetab.bol or '' -- begin of line
	local eol = linetab.eol or '' -- end of line
	for i,v in ipairs(linetab) do
		local tv = type(v)
		if tv == "table" then
			local rendered = renderLine(v)
			linetab[i] = rendered
			tv=type(rendered)
			assert(tv=="string", "rendered element must be a string")
		end
		assert(tv=="string", "element must be a string")
	end
	return bol..table.concat(linetab, sep)..eol
end

assert("(AA, B B, C C C);" == renderLine({ sep=', ',  bol='(', eol=');',"AA", "B B", "C C C"}), "renderLine() selftest 1")
assert("(AA,\"1/22/333\",C C C);" == renderLine({ sep=',', bol='(', eol=');', "AA", { sep='/', bol='"', eol='"', "1", "22", "333", }, "C C C", }), "renderLine() selftest 2")


local function _f_char_text(t2, len)
	if(len) then
		return '('..len..')'
	end
end

local function _f_varchar(t2, len)
	--assert(not len, 'Database Error: varchar type must have length property')
	if not len then
		print('Database Error: varchar type must have length property')
	end
	return _f_char_text(t2, len)
end



-- generateAttributes( table tableAttributes, string dbtype, boolean isprimarykey) )
-- Input: (Table) Table with attributes ; (String) 'sqlite' or 'mysql' ; (Boolean) True if the current field is a primary key
-- Output: (Table) SQL Field Attributes
--
local function generateAttributes(tableAttributes, dbtype, isprimarykey)
	assert(dbtype)
	assert( type(tableAttributes) == "table", "tableAttributes must be a table :"..type(tableAttributes))
	local len = tableAttributes['length']
	local t2  = tableAttributes['type']

	local t_attributes = {sep=' ', bol=nil, eol=nil}
	t_attributes[#t_attributes+1] = getDbFieldType(t2, dbtype) or t2

	if(t2 == 'varchar') then
		local r = _f_varchar(t2, len)
		if r then
			t_attributes[#t_attributes+1] = r
		end
	elseif(t2 == 'char' or t2 == 'text') then
		local r = _f_char_text(t2, len)
		if r then
			t_attributes[#t_attributes+1] = r
		end
	end

	if not (dbtype == 'sqlite' and isprimarykey) then
		if(tableAttributes['unsigned'] == true) then
			t_attributes[#t_attributes+1] = 'UNSIGNED'
		end
	end
	if(tableAttributes['default']) then
		t_attributes[#t_attributes+1] = 'DEFAULT '..'\''..tableAttributes['default']..'\''
	end
	if(tableAttributes['not null'] == true) then
		t_attributes[#t_attributes+1] = 'NOT NULL'
	end

	if(tableAttributes['auto increment'] == true) then
		if(dbtype == 'mysql') then
			t_attributes[#t_attributes+1] = 'AUTO_INCREMENT'
		elseif(dbtype == 'sqlite') then
			if isprimarykey then
				t_attributes[#t_attributes+1] = 'PRIMARY KEY AUTOINCREMENT'
			else
				print("WARNING: 'auto increment' should be apply if field is not a primary key")
			--	-- autoincrement only allowed on primary key
			end
		end
	end

	if(tableAttributes['description'] and dbtype == 'mysql') then
		t_attributes[#t_attributes+1] = 'COMMENT \''..tableAttributes['description']..'\''
	end
	return t_attributes
end

local function schemaIsValid(schema)
	assert(type(schema) == "table", "Schema must be a table")
	if schema.schema then
		return false, "Found a schema.schema. The real schema is maybe inside the schema.schema."
	end
	for tableName,columns in pairs(schema) do
		if columns.description and type(columns.description) ~= "string" then
			return false, ("Invalid element in the table '%s' definition, description must be a string"):format(tableName)
		end
		if type(columns.fields) ~= "table" then
			return false, ("Invalid element in the table '%s' definition, fields must be a table"):format(tableName)
		end
	end
	return true
end

local function schema_orderedfieldnames(fields)
	if #fields == 0 then -- no number, use keys
		return false
	end
	local ifields = {}
	for k,v in pairs(fields) do
		if type(k) == "number" then
			ifields[#ifields+1] = v
		end
	end
--	table.sort(ifields, function(a,b) return fields[a] > fields[b] end)
	table.sort(ifields)
	return ifields
end


-- schemaToSql( table schema, string dbtype )
-- Input: (Table) Containing DB Schema elements
--        (String) Target Database Engine to format SQL : 'mysql'|'sqlite'
-- Output: (Table) SQL for creating Database Tables
--
local function schemaToSql(schema, dbtype)
	assert(dbtype and (dbtype == 'mysql' or dbtype == 'sqlite'), "You must specify the database type (mysql or sqlite)")
	local sqlQueryQueue = {}

	local newline = '\n'
	local prefix = '\t'

	local fkey_enabled = false -- Enable FOREIGN KEY SUPPORT only once

	-- CREATE Tables
	for tableName,columns in pairs(schema) do
		local foreignkeys = columns['foreign key']
		if foreignkeys and dbtype == 'sqlite' then
			if not fkey_enabled then
				sqlQueryQueue[#sqlQueryQueue+1] = "PRAGMA foreign_keys=ON;"..newline
				fkey_enabled=true
			end
		end

		local primarykey  = columns['primary key']
		local description = columns['description']

		-- CREATE Tables
		local sqlOut2 = {
			bol='CREATE TABLE '..tableName..' ',
			eol=';'..newline,
			sep=''
		}
		if description and (dbtype == 'sqlite' or dbtype == 'mysql') then
			sqlQueryQueue[#sqlQueryQueue+1] = "-- COMMENT '"..description.."'"
		end
		local sqlOut = {
			bol='('..newline,
			eol=newline..')',
			sep=','..newline,
		}

		local stuff = function(columnName, attributes)
			local isprimarykey = not not (columnName == primarykey)
			local ta2 = generateAttributes(attributes, assert(dbtype), isprimarykey)
			local attr = renderLine(ta2)
			local columnName = ("%-20s"):format( columnName )
			sqlOut[#sqlOut+1] = prefix..columnName..' '..attr
		end

		for columnName, attributes in hoPairs(columns['fields']) do
			if type(columnName) ~= "number" then
--				print("hoPairs():", columnName, attributes)
				stuff(columnName, attributes)
			end
		end

		-- After the Last Column
		if primarykey then
			if dbtype == 'mysql' or dbtype == 'sqlite' then
				if not (dbtype == 'sqlite' and columns['fields'][primarykey]['auto increment'] ) then
					sqlOut[#sqlOut+1] = prefix..'PRIMARY KEY ('..primarykey..')'
				end
			end
		end
		if foreignkeys then
			if dbtype == 'sqlite' then
				for key,foreignkey in pairs(foreignkeys) do
					sqlOut[#sqlOut+1] = prefix..'FOREIGN KEY ('..key..') REFERENCES '..foreignkey..' ON UPDATE CASCADE ON DELETE CASCADE'
				end
			end
		end

		if(description and dbtype == 'mysql') then
			sqlOut[#sqlOut+1] = "ENGINE=InnoDB COMMENT '"..description.."'"
		end

		sqlOut2[#sqlOut2+1] = sqlOut
		sqlQueryQueue[#sqlQueryQueue+1] = renderLine(sqlOut2)
	end

	-- ALTER CREATED TABLES TO PROVIDE FOREIGN KEY SUPPORT
	for tableName,columns in pairs(schema) do
		local foreignkeys = columns['foreign key']
		if foreignkeys and dbtype ~= 'sqlite' then
			local sqlOut2 = {
				bol='ALTER TABLE '..tableName..' '..newline..prefix,
				eol=';'..newline,
				sep=', '..newline..prefix,
			}

			for key, foreignkey in pairs(foreignkeys) do
				sqlOut2[#sqlOut2+1] = 'ADD CONSTRAINT fk_'..tableName..'_'..key..' FOREIGN KEY ('..key..') REFERENCES '..foreignkey..' ON UPDATE CASCADE ON DELETE CASCADE'
			end
			sqlQueryQueue[#sqlQueryQueue+1] = renderLine(sqlOut2)
		end
	end

	return sqlQueryQueue
end

local function schemaTables(schema)
	local tables = {}
	for tablename in pairs(schema) do
		if type(tablename) == "string" then
			tables[#tables+1] = tablename
		end
	end
	return tables
end

local _M = {}

_M.schemaToSql		= assert(schemaToSql)
_M.schemaIsValid	= assert(schemaIsValid)
_M.schemaTables		= assert(schemaTables)

return _M

-- usefull links :
-- http://www.w3schools.com/sql/default.asp
