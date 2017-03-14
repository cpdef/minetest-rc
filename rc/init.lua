rc = {}
local function is_valid_pos(pos)
        if type(pos) == 'table' then
	        if tonumber(pos.x) and tonumber(pos.y) and tonumber(pos.z) then
		        return pos
		end
	end
	return
end

rc.send = function(radius, from_pos, to_pos, msg, sender)
	print('rc_msg: ', radius, from_pos, to_pos, msg, sender)
        if ((not is_valid_pos(from_pos)) or (not is_valid_pos(to_pos))) then return end
        local node = minetest.get_node(to_pos)
        local node_def = minetest.registered_nodes[node.name]
	local distance = vector.distance(from_pos, to_pos)
	if distance > radius then return end
	if node_def.rc and node_def.rc.receive then
	        node_def.rc.receive(to_pos, msg, sender)
	end
end