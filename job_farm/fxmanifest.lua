fx_version 'adamant'
games { 'gta5' };

shared_scripts { 
	'@es_extended/imports.lua',
    'config.lua',
}

client_scripts {
    '@es_extended/locale.lua',
    'client/*.lua',
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'@es_extended/locale.lua',
    'server/*.lua'
}