
-- Created by cpdef/juli
-- Part of rc_enhanced
-- Mod: rc copier

local OK_MSG = "OK"
local NO_SPACE_MSG   = "NOSPACE"
local NO_PAPER_MSG   = "NOPAPER"
local BUSY_MSG       = "BUSY"
local PRINT_DELAY    = 3
local SPLIT_CHAR     = ";"
local DEFAULT_SIGNUM = "THE COPIER"

local RC_RADIUS = 3

-- taken from pipeworks mod
local function facedir_to_dir(facedir)
	--a table of possible dirs
	return ({{x=0, y=0, z=1},
		{x=1, y=0, z=0},
		{x=0, y=0, z=-1},
		{x=-1, y=0, z=0},
		{x=0, y=-1, z=0},
		{x=0, y=1, z=0}})
		
			--indexed into by a table of correlating facedirs
			[({[0]=1, 2, 3, 4, 
				5, 2, 6, 4,
				6, 2, 5, 4,
				1, 5, 3, 6,
				1, 6, 3, 5,
				1, 4, 3, 2})
				
				--indexed into by the facedir in question
				[facedir]]
end

local print_paper = function(inv, pos, node, msg, signum, owner, send_pos)
        --get front pos
	local vel = facedir_to_dir(node.param2)
	local front = { x = pos.x - vel.x, y = pos.y - vel.y, z = pos.z - vel.z }
	
	if inv:is_empty("paper") then 
		rc.send(RC_RADIUS, pos, send_pos, NO_PAPER_MSG, owner)
		minetest.get_meta(pos):set_string("infotext", "Copier No Paper!")
	elseif minetest.get_node(front).name ~= "air" then 
	        rc.send(RC_RADIUS, pos, send_pos, NO_SPACE_MSG, owner)
		minetest.get_meta(pos):set_string("infotext", "Copier: No Space!")
	else
                --remove one item from paper stack:
		local paper = inv:get_stack("paper", 1)
		paper:take_item()
		inv:set_stack("paper", 1, paper)
		
                --print the letter
		minetest.add_node(front, {
			name = (msg == "" and "memorandum:letter_empty" or "memorandum:letter_written"),
			param2 = node.param2
		})
		
                --set text of letter
		local meta = minetest.get_meta(front)
		meta:set_string("text", msg)
		meta:set_string("signed", signum)
		meta:set_string("infotext", 
                "On this piece of paper is written: " ..msg .. " Signed by " .. signum)
		
                --done :-)
		rc.send(RC_RADIUS, pos, send_pos, OK_MSG, owner)
	end
	minetest.get_meta(pos):set_string("infotext", "Copier Idle")
end

local copy = function(inv, pos, copier, node, scanpos, owner, send_pos)
         local vel = facedir_to_dir(copier.param2)
	 local front = { x = pos.x - vel.x, y = pos.y - vel.y, z = pos.z - vel.z }

	if inv:is_empty("paper") then 
		rc.send(RC_RADIUS, pos, send_pos, NO_PAPER_MSG, owner)
		minetest.get_meta(pos):set_string("infotext", "Copier No Paper!")
	elseif minetest.get_node(front).name ~= "air" then 
	        rc.send(RC_RADIUS, pos, send_pos, NO_SPACE_MSG, owner)
		minetest.get_meta(pos):set_string("infotext", "Copier: No Space!")
         else
             local paper = inv:get_stack("paper", 1)
             paper:take_item(1)
             inv:set_stack("paper", 1, paper)

             minetest.add_node(front, node)
             local meta     = minetest.get_meta(front  )
             local scanmeta = minetest.get_meta(scanpos)
             meta:set_string("text",     scanmeta:get_string("text"    ))
             meta:set_string("signed",   scanmeta:get_string("signed"  ))
             meta:set_string("infotext", scanmeta:get_string("infotext"))

             rc.send(RC_RADIUS, pos, send_pos, OK_MSG, owner)
         end
end        

local on_rc_receive = function(pos, msg, sender)--function(pos, node, channel, msg)
                node = minetest.get_node_or_nil(pos)
                if (msg == "" or msg == nil or not node) then return end
	        local meta = minetest.get_meta(pos)
		local msg = msg:split(SPLIT_CHAR)
		
                local x = meta:get_int("x")
                local y = meta:get_int("y")
                local z = meta:get_int("z")
		local send_pos = {x=x,y=y,z=z}
		
		local owner = meta:get_string("owner")
                --RC COMMANDS
                --usable for more than one function
                local scanpos = {x = pos.x, y = pos.y+1, z = pos.z}
                local scanmeta = minetest.get_meta(scanpos)
                local inv = minetest.get_meta(pos):get_inventory()
                --SCAN:
                if msg[1] == "SCAN" then
                    if minetest.get_node_or_nil(scanpos).name == "memorandum:letter_written" then
                        local text = scanmeta:to_table().fields.text
                        text = text .. " signed: " .. scanmeta:get_string("signed")
			rc.send(RC_RADIUS, pos, send_pos, text, owner)
                    end

                --PRINT:
                elseif msg[1] == "PRINT" then
                    if (  meta:get_string("infotext"):find("Busy") == nil  ) then
                        meta:set_string("infotext", "rc Printer Busy")
                        if (msg[2]) then
                            if (msg[3]) then
                                minetest.after(PRINT_DELAY, print_paper, inv, pos, node, msg[2], msg[3], owner)
                            else
                                minetest.after(PRINT_DELAY, print_paper, inv, pos, node, msg[2], DEFAULT_SIGNUM, owner, send_pos)
                            end
                        end
			minetest.after(PRINT_DELAY, function(pos)
			                minetest.get_meta(pos):set_string("infotext", "Copier Idle")
			        end, pos)
	            else
                        rc.send(RC_RADIUS, pos, send_pos, BUSY_MSG, owner)
                    end
                 
		--COPY
                elseif msg[1] == "COPY" then
                    if (  meta:get_string("infotext"):find("Busy") == nil  ) then
                        meta:set_string("infotext", "rc Printer Busy")
                        local scannode = minetest.get_node_or_nil(scanpos)
                        if (scannode and scannode.name == "memorandum:letter_written") then
                            minetest.after(PRINT_DELAY, copy,         
                                          inv, pos, node ,scannode, scanpos, owner, send_pos)
                        end
	            else
			rc.send(RC_RADIUS, pos, send_pos, BUSY_MSG, owner)
                    end
                 
                --get paper laying on copier
                elseif msg[1] == "GETPAPER" then
                    if (minetest.get_node_or_nil(scanpos).name == "default:paper"
                      or minetest.get_node_or_nil(scanpos).name == "memorandum:letter_empty") 
                      then
                        local paper = inv:get_stack("paper", 1)
                        paper:add_item("default:paper")
		        inv:set_stack("paper", 1, paper)
                        minetest.remove_node(scanpos)
                    end

                elseif msg[1] == "IDLE" then
                       minetest.get_meta(pos):set_string("infotext", "Copier Idle")
                end

                --COMMAND END
end

minetest.register_node("rc_copier:copier", {
		description = "copy, scan and print device",
		drawtype = "normal",
	        tiles = {"copier.png","copier_sides.png","copier_sides.png",
			"copier_sides.png","copier_sides.png","copier_front.png"},

		paramtype = "light",
		paramtype2 = "facedir",
		groups = {dig_immediate=2},
		--selection_box = chip_selbox,
		rc= {
			receive = on_rc_receive
		},

		on_construct = function(pos,sender)
			local meta = minetest.get_meta(pos)
			meta:set_string("data", "return {}")
                        local inv = meta:get_inventory()
		        inv:set_size("paper", 1)
                        meta:set_string("formspec", "field[x;X;]" ..
                                                                    "field[y;Y;]" ..
						                    "field[z;Z;]" )
		end,
		
		after_place_node = function(pos, placer, itemstack, pointed_thing)
		        local meta = minetest.get_meta(pos)
			meta:set_string("owner", placer:get_player_name())
		end,

                --allowed to put in something?
                allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		        if minetest.is_protected(pos, player:get_player_name()) then return 0 end
		        return (stack:get_name() == "default:paper" and stack:get_count() or 0)
	        end,
                
                --allowed to take out something?
	        allow_metadata_inventory_take = function(pos, listname, index, stack, player)
                        if minetest.is_protected(pos, player:get_player_name()) 
                            then return 0 end
                        if (minetest.get_meta(pos):get_string("infotext"):find("Busy") == nil) then
                            return stack:get_count()
                        else return 0
                        end
	        end,
                
                --allowed to dig?
                can_dig = function(pos, player)
		        return minetest.get_meta(pos):get_inventory():is_empty("paper")
	        end,
		
		on_receive_fields = function(pos, formname, fields, sender)
		        local posstring = "nodemeta:"..pos.x..","..pos.y..","..pos.z
                        local meta = minetest.get_meta(pos)
                        local x = meta:get_int("x")
                        local y = meta:get_int("y")
			local z = meta:get_int("z")
			if tonumber(fields.x) and tonumber(fields.y) and tonumber(fields.z) then
				meta:set_int("x", tonumber(fields.x))
				meta:set_int("y", tonumber(fields.y))
				meta:set_int("z", tonumber(fields.z))
				meta:set_string("formspec", "size[8,10]"..
				                                             "list["..posstring..";paper; 3.5,4;1,1;]" .. 
				                                             "label[1,4;Paper]"..
                                                                             "list[current_player;main;0,6;8,4;]")
			end
  end,
	})
	
minetest.register_craft({
	type = "shapeless",
	output = "rc_copier:copier",
	recipe = {
		"default:dirt",
		"default:dirt",
	},
})
