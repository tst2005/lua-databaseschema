local schema = {}

schema['characters'] = {
	['description'] = 'Base table for Characters',
	['fields'] = {
		['id'] = {
			['description'] = 'Primary identifier for a character',
			['type'] = 'int',
			['unsigned'] = true,
			['not null'] = true,
			['auto increment'] = true
		},
		['playerId'] = {
			['description'] = 'Foreign key identifier for player',
			['type'] = 'int',
			['unsigned'] = true,
			['not null'] = true,
		},
		['health'] = {
			['description'] = 'Characters health',
			['type'] = 'int',
			['default'] = 100,
			['unsigned'] = true,
			['not null'] = true
		},
		['gender'] = {
			['description'] = 'Character Gender',
			['type'] = 'int',
			['default'] = 0,
			['unsigned'] = true,
			['not null'] = true
		},
		['model'] = {
			['description'] = 'Character Model',
			['type'] = 'int',
			['default'] = 0,
			['unsigned'] = true,
			['not null'] = true
		},
		['lastonline'] = {
			['description'] = 'Unix timestamp when character was last online',
			['type'] = 'int',
			['default'] = 0,
			['unsigned'] = true,
			['not null'] = true
		},
		['description'] = {
			['description'] = 'Character Description',
			['type'] = 'varchar',
			['length'] = '80',
			['not null'] = true
		},
		['name'] = {
			['description'] = 'Character Name',
			['type'] = 'varchar',
			['length'] = '30',
			['not null'] = true
		}
	},
	['primary key'] = 'id',
	['foreign key'] = {
			['playerId'] = 'players(id)'
	}
}

return {schema = schema}
