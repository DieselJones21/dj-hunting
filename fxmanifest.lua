fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'dj-hunting'
author 'DieselJones21'
description 'Rebel Roleplay hunting: zones, XP ranks, license, outfitter store, harvest, and buyback'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'data/equipment.lua',
}

client_scripts {
    'client/main.lua',
    'client/hunting.lua',
}

server_scripts {
    'server/bridge.lua',
    'server/stats.lua',
    'server/main.lua',
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/app.js',
    'html/brand/*.png',
    'html/images/*.png',
    'locales/*.json',
}

ox_libs {
    'locale',
}

dependencies {
    'ox_lib',
    'ox_inventory',
    'interact',
}
