
local mylib = {}

local windust_areas = {
    'ウィンダス森の区',
    'ウィンダス石の区',
    'ウィンダス水の区',
    'ウィンダス港',
}

local windusts_areas = {
    'ウィンダス水の区〔Ｓ〕',
}

local adoulin_areas = {
    '西アドゥリン',
    '東アドゥリン',
}

local function is_in_array (tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

function mylib.is_in_adoulin(val)
    return is_in_array(adoulin_areas, val)
end

function mylib.is_in_windust(val)
    return is_in_array(windust_areas, val)
end

function mylib.is_in_windusts(val)
    return is_in_array(windusts_areas, val)
end


function mylib.tprint (tbl, indent)
  if not indent then indent = 0 end
  local toprint = string.rep(" ", indent) .. "{\r\n"
  indent = indent + 2 
  for k, v in pairs(tbl) do
    toprint = toprint .. string.rep(" ", indent)
    if (type(k) == "number") then
      toprint = toprint .. "[" .. k .. "] = "
    elseif (type(k) == "string") then
      toprint = toprint  .. k ..  "= "   
    end
    if (type(v) == "number") then
      toprint = toprint .. v .. ",\r\n"
    elseif (type(v) == "string") then
      toprint = toprint .. "\"" .. v .. "\",\r\n"
    elseif (type(v) == "table") then
      toprint = toprint .. tprint(v, indent + 2) .. ",\r\n"
    else
      toprint = toprint .. "\"" .. tostring(v) .. "\",\r\n"
    end
  end
  toprint = toprint .. string.rep(" ", indent-2) .. "}"
  return toprint
end

function mylib.has_storm()
	if not windower.ffxi.get_player() then return false end
	
	local storms = {178, 179, 180, 181, 182, 183, 184, 185, 
					589, 590, 591, 592, 593, 594, 595, 596}
	for _,k in ipairs(storms) do
		for _,b in ipairs(windower.ffxi.get_player().buffs) do
			if k == b then
				return true
			end
		end
	end
	return false
end

return mylib