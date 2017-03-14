minetest.register_tool("rc_smartphone:smartphone", {
                description = "Smartphone",
                inventory_image = "smartphone.png",
	        stack_max = 1,
                on_use = function(itemstack, player, pointed_thing)
		        pos = pointed_thing.under
		        minetest.chat_send_player(player:get_player_name(), '{x='..pos.x..',y='..pos.y..',z='..pos.z..'}')

                minetest.after(3.5, function() 
                    print("3.5 seconds later")
                end)
                print('after minetest.after')
	        end,
		})
