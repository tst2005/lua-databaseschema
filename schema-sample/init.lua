local path = (... or ""):gsub("%.[^%.]+$", "")
path=path~="" and path.."." or ""

-- Load Abstracted DB Schema
local schema_loadlist = {"player", "groups", "characters"}

local schema = {}
for i,mod in ipairs(schema_loadlist) do
	local modname = path..mod
	local modschema = assert( require(modname).schema )
	for k,v in pairs(modschema) do
		schema[k] = v
	end
end
return schema
