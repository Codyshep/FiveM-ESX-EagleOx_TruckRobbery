fx_version 'cerulean'
game 'gta5'

lua54 'yes'

author 'AydinsRp'
description 'None'
version '1.0.0'

server_scripts {
    'config.lua',
    'server.lua',
}

client_scripts {
    'config.lua',
    'client.lua',
}

shared_scripts {
    '@ox_lib/init.lua',
}

escrow_ignore {
    'config.lua'
}