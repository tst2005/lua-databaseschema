local schema = {}

schema['groups'] = {
	['description'] = 'Base table for Groups',
	['fields'] = {
		['id'] = {
			['description'] = 'Primary identifier for a group',
			['type'] = 'int',
			['unsigned'] = true,
			['not null'] = true,
			['auto increment'] = true			
		},
		['name'] = {
			['description'] = 'Name of the group',
			['type'] = 'varchar',
			['not null'] = true,
			['length'] = '20',
			['default'] = ''			
		},
		['description'] = {
			['description'] = 'Group description',
			['type'] = 'varchar',
			['not null'] = true,
			['length'] = '255',
			['default'] = ''			
		}
	},
	['primary key'] = 'id'
}

schema['groupRoster'] = {
	['description'] = 'Table for identifying player to their group and rank',
	['fields'] = {
		['groupId'] = {
			['description'] = 'Foreign key for group identifier',
			['type'] = 'int',
			['unsigned'] = true,
			['not null'] = true,
		},
		['characterId'] = {
			['description'] = 'Foreign key for character identifier',
			['type'] = 'int',
			['unsigned'] = true,
			['not null'] = true,
		},		
		['rankId'] = {
			['description'] = 'Foreign key for rank identifier',
			['type'] = 'int',
			['unsigned'] = true,
			['not null'] = true,
		}
	},
	['foreign key'] = {
		['groupId'] = 'groups(id)',
		['characterId'] = 'characters(id)',
		['rankId'] = 'groupRanks(id)'
	}
}

schema['groupRanks'] = {
	['description'] = 'Base table for Group Ranks',
	['fields'] = {
		['id'] = {
			['description'] = 'Primary identifier for a group',
			['type'] = 'int',
			['unsigned'] = true,
			['not null'] = true,
			['auto increment'] = true			
		},
		['groupId'] = {
			['description'] = 'Foreign key for group identifier',
			['type'] = 'int',
			['unsigned'] = true,
			['not null'] = true,
		},		
		['name'] = {
			['description'] = 'Name of the rank',
			['type'] = 'varchar',
			['not null'] = true,
			['length'] = '20',
			['default'] = ''			
		},
		['description'] = {
			['description'] = 'Group description',
			['type'] = 'varchar',
			['not null'] = true,
			['length'] = '255',
			['default'] = ''
		},
		['isDefault'] = {
			['description'] = 'Identifies whether this is the default rank for the group',
			['type'] = 'int',
			['unsigned'] = true,
			['not null'] = true,
			['default'] = 0
		},	
		['spawnGroup'] = {
			['description'] = 'Identifies which spawngroup members of this rank are in',
			['type'] = 'int',
			['unsigned'] = true,
			['not null'] = true,
			['default'] = 0
		}				
	},
	['primary key'] = 'id',
	['foreign key'] = {
		['groupId'] = 'groups(id)'
	}
}

return {schema = schema}
