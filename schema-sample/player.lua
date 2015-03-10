local schema = {}

schema['players'] = {
	['description'] = 'Base table for Players',
	['fields'] = {
		['id'] = {
			['description'] = 'Primary identifier for a player',
			['type'] = 'int',
			['unsigned'] = true,
			['not null'] = true,
			['auto increment'] = true
		},
		['steamid'] = {
			['description'] = 'SteamID identifier for a player',
			['type'] = 'varchar',
			['not null'] = true,
			['length'] = 25
		},
		['characterLimit'] = {
			['description'] = 'How many characters this player may create',
			['type'] = 'int',
			['unsigned'] = true,
			['not null'] = true,
			['default'] = 1
		}
	},
	['primary key'] = 'id'
}
	
schema['roles'] = {
	['description'] = 'Player Roles Definitions',
	['fields'] = {
		['id'] = {
			['description'] = 'Primary identifier for a role',
			['type'] = 'int',
			['unsigned'] = true,
			['not null'] = true,
			['auto increment'] = true
			},
		['title'] = {
			['description'] = 'Name of the role for permissions',
			['type'] = 'varchar',
			['length'] = 60,
			['not null'] = true
		},
		['description'] = {
			['description'] =	'Description of this role',
			['type'] = 'varchar',
			['length'] = 255,
			['not null'] = true,
			['default'] = ''
		}
	},
	['primary key'] = 'id'
}

schema['playerRoles'] = {
	['description'] = 'Index of players and respective role assignments',
	['fields'] = {
		['playerId'] = {
			['description'] = 'Foreign Key for Player Identifier',
			['type'] = 'int',
			['unsigned'] = true,
			['not null'] = true,
		},
		['roleId'] = {
			['description'] = 'Foreign key for Role Identifier',
			['type'] = 'int',
			['unsigned'] = true,
			['not null'] = true,
			['default'] = 0,
		}
	},
	['foreign key'] = {
		['playerId'] = 'players(id)',
		['roleId'] = 'roles(id)'
	}
}

schema['permissions'] = {
	['description'] = 'Permissions settings',
	['fields'] = {
		['id'] = {
			['description'] = 'Primary identifier for permission',
			['type'] = 'int',
			['unsigned'] = true,
			['not null'] = true,
			['auto increment'] = true			
			},
		['title'] = {
			['description'] = 'Description of permission for role',
			['type'] = 'varchar',
			['length'] = 60,
			['not null'] = true
		},
		['name'] = {
			['description'] = 'Name of permission to be returned to gamemode',
			['type'] = 'varchar',
			['length'] = 60,
			['not null'] = true
		}	
	},
	['primary key'] = 'id'
}

return {schema = schema}
