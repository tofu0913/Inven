_addon.name = 'Inven'
_addon.author = 'Cliff'
_addon.version = '0.0.1'
_addon.commands = {'inven','iv'}

require("logger")
require('mylibs/utils')

local use_queue = {}
local use_timer = os.clock()

windower.register_event('prerender', function(...)
	if #use_queue > 0 and os.clock() - use_timer > 1 then
		local item = table.remove(use_queue, 1)
		windower.send_command(windower.to_shift_jis("input /item "..item.." <me>"))
		use_timer = os.clock() + 5
	end
end)

local big_inven = {}

function put_big_inven(k, v)
	-- log(k..','..v)
	if not big_inven[v] then--TODO, augment
		big_inven[v] = {}
	end
	table.insert(big_inven[v], k)
end

function parse_sets(set, key)
	for k, v in pairs(set) do
		if type(v) == 'table' then
			if v.name then
				put_big_inven(key..'.'..k, v.name)
			else
				parse_sets(v, key..'.'..k)
			end
		else
			put_big_inven(key..'.'..k, v)
		end
	end
end

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
	
	elseif T{"open","op","o"}:contains(args[1]) then
		use_queue = {}
		local inventory = windower.ffxi.get_items(0)
		for i=1,inventory.max do
			if inventory[i].id > 0 then
				local item = res.items[inventory[i].id]
				if item and item.category == 'Usable' then
					for j=1,inventory[i].count do
						table.insert(use_queue, 1, item.ja)
					end
				end
			end
		end
	
	elseif args[1] == 'gs' then
		require('gs_dummy')
		for k,v in pairs(res.jobs) do
			local infile = io.open(windower.addon_path..'../GearSwap/data/'..v.ens..'.lua', "r")
			if not infile then
				infile = io.open(windower.addon_path..'../GearSwap/data/'..windower.ffxi.get_player().name..'_'..v.ens..'.lua', "r")
			end
			local outfile = nil
			if infile then
				outfile = io.open(windower.addon_path..'/gs/'..v.ens..'.lua', "wb")
				local content = infile:read("*a")
				outfile:write(content)
				infile:close()
			end
			if outfile then
				outfile:close()
				log('Analyzing '..v.ens..'.lua...')
				sets = {}
				require('gs/'..v.ens)
				get_sets()
				parse_sets(sets, v.ens..'.sets')
			end
			-- break
		end
		-- for k, vals in pairs(big_inven) do
			-- for i, v in pairs(vals) do
				-- log(k..' in '..v)
			-- end
		-- end
		local BAGS = {8,10,11,12,13,14,15,16}
		-- local BAGS = {8,10}
		local count = 0
		local report = io.open(windower.addon_path..'report.txt', "wb")
		for _, v in ipairs(BAGS) do
			local inventory = windower.ffxi.get_items(v)
			log('Analyzing '..res.bags[v].en)
			report:write('=== '..res.bags[v].en..' ===\n')
			for i=1,inventory.max do
				if res.items[inventory[i].id] then
					local name = res.items[inventory[i].id].ja
					local line = ''
					for _, found in pairs(big_inven[name] or {}) do
						line = line..found..', '
					end
					if big_inven[name] == nil then
						count = count +1
					end
					report:write(name..',\t'..line..'\n')
				end
			end
		end
		report:close()
		log('done')
		log(count..' unused item found.')
		sets = {}
		big_inven = {}
	end
end)

windower.register_event('unload', function()
end)

windower.register_event('load', function()
    log('===========loaded===========')
end)