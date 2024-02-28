fx_version 'adamant'
game 'gta5'
lua54 'yes'

author 'Sigge x Dallefar'
description 'Postbud script af Sigge oversæt til vrp af dallefar.'
version '1.2.0'

dependency "vrp"

shared_scripts {
  '@ox_lib/init.lua',
  "Config.lua",
}

client_scripts{ 
  "lib/Proxy.lua",
  "lib/Tunnel.lua",
  "client.lua"
}

server_scripts{ 
  "@vrp/lib/utils.lua",
  "server.lua"
}