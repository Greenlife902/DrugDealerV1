fx_version 'cerulean'
lua54 'yes'
game 'gta5'

author 'Greenlife710'
description 'DrugDealerV1 - Scheduled 1 Inspired Dealer System (QBCore)'

shared_script '@ox_lib/init.lua'
shared_script 'shared/config.lua'

client_scripts {
  'client/main.lua',
  'client/boss.lua'
}

server_scripts {
  'server/functions.lua',
  'server/main.lua'
}

dependency {
  'ox_lib',
  'oxmysql'
}
