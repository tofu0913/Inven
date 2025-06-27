_addon.name = 'Inven'
_addon.author = 'Cliff'
_addon.version = '0.0.1'
_addon.commands = {'inven','iv'}

require("logger")
require('mylibs/utils')

windower.register_event('addon command', function (...)
	local args	= T{...}:map(string.lower)
	if args[1] == nil or T{"help","h","show"}:contains(args[1]) then
		log('Nothing')
		
	elseif T{"export","ex"}:contains(args[1]) then
		local inventory = windower.ffxi.get_items(0)
		local file = assert(io.open(windower.addon_path..'items.lua', "w"))
		for i=1,inventory.max do
			if inventory[i].id > 0 then
				file:write('\t"'..res.items[inventory[i].id].en..'",--'..res.items[inventory[i].id].ja..'\n')
			end
		end
		file:close()
		log('File exported!!')
	end
end)

windower.register_event('unload', function()
end)

windower.register_event('load', function()
    log('===========loaded===========')
end)