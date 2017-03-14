local colors={"red", "blue", "green", "brown", "yellow", "cyan", "violet"}

local is_in = function(table_, test)
	for key, value in pairs(table_) do
                if value == test then 
	                return true 
		end
        end
        return false
end



for key, color in pairs(colors) do
for key, fullorglass in pairs({"glass", "full"}) do

if fullorglass == "full" then
	drawtype = "normal"
	alpha=nil
else
	drawtype = "glasslike"--_framed_optional"
	alpha=50
end

minetest.register_node("rclight:"..fullorglass.."_"..color.."_on", {
	description="RC light_on_"..fullorglass..color,
	drawtype=drawtype,
	alpha = alpha,
	light_source = default.LIGHT_MAX-2,
	tiles = {fullorglass..color..".png"},
	is_ground_content = false,
	groups = {crumbly = 2, not_in_creative_inventory=1},
	paramtype = "light",
	sunlight_propagates = true,
	sounds = default.node_sound_glass_defaults(),
	rc = {
			receive = function(pos, msg, sender)
			        node = minetest.get_node_or_nil(pos)
				if not node then return end
				if msg == "off" then
					minetest.swap_node(pos, {name = "rclight:"..fullorglass.."_"..color.."_off", param2 = node.param2})
				elseif msg == "full" then
					minetest.swap_node(pos, {name = "rclight:full_"..color.."_on", param2 = node.param2})
				elseif msg == "glass" then
					minetest.swap_node(pos, {name = "rclight:glass_"..color.."_on", param2 = node.param2})
				elseif is_in(colors, msg) then
					minetest.swap_node(pos, {name = "rclight:"..fullorglass.."_"..msg.."_on", param2 = node.param2})
				end
			end
		},
})

minetest.register_node("rclight:"..fullorglass.."_"..color.."_off", {
	description="RC light_off_"..fullorglass..color,
	drawtype=drawtype,
	alpha = alpha,
	tiles = {fullorglass..color..".png"},
	is_ground_content = false,
	groups = {crumbly = 2},
	paramtype = "light",
	sunlight_propagates = true,
	sounds = default.node_sound_glass_defaults(),
	rc = {
			receive = function(pos, msg, sender)
			        node = minetest.get_node_or_nil(pos)
				if not node then return end
			        print("rclight", pos.x, pos.y, pos.z, msg[1], msg[2]) 
				if msg == "on" then
					minetest.swap_node(pos, {name = "rclight:"..fullorglass.."_"..color.."_on", param2 = node.param2})
				elseif msg == "full" then
					minetest.swap_node(pos, {name = "rclight:full_"..color.."_off", param2 = node.param2})
				elseif msg == "glass" then
					minetest.swap_node(pos, {name = "rclight:glass_"..color.."_off", param2 = node.param2})
				elseif is_in(colors, msg) then
					minetest.swap_node(pos, {name = "rclight:"..fullorglass.."_"..msg.."_off", param2 = node.param2})
				end
			end
		},
})

end
end
drawtype = nil --has been global before
alpha = nil 