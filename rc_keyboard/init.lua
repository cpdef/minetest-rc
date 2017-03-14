

-- from Original keyboard mod by bas080
-- Cracked by jogag -> cracked by juli from digilines to rc
-- Added features: useable with rc mod

local RC_RADIUS = 5

minetest.register_node("rc_keyboard:rc_keyboard", {
  description = "rc_keyboard",
  tiles = {"rc_keyboard_top.png", "rc_keyboard_bottom.png", "rc_keyboard_side.png", "rc_keyboard_side.png", "rc_keyboard_side.png", "rc_keyboard_side.png"},
  walkable = true,
  paramtype = "light",
  paramtype2 = "facedir",
  drawtype = "nodebox",
  node_box = {
    type = "fixed",
    fixed = {
      {-4/8, -4/8, 0, 4/8, -3/8, 4/8},
    },
  },
  selection_box = {
    type = "fixed",
    fixed = {
      {-4/8, -4/8, 0, 4/8, -3/8, 4/8},
    },
  },
  groups =  {choppy = 3, dig_immediate = 2},
  on_construct = function(pos)
    local meta = minetest.get_meta(pos)
    meta:set_string("formspec", "field[x;X;]" ..
                                                 "field[y;Y;]" ..
						 "field[z;Z;]" )
    meta:set_string("infotext", "rc_keyboard")
    meta:set_int("lines", 0)
  end,
  on_receive_fields = function(pos, formname, fields, sender)
    local meta = minetest.get_meta(pos)
    local x = meta:get_int("x")
    local y = meta:get_int("y")
    local z = meta:get_int("z")
    if tonumber(fields.x) and tonumber(fields.y) and tonumber(fields.z) then
      meta:set_int("x", tonumber(fields.x))
      meta:set_int("y", tonumber(fields.y))
      meta:set_int("z", tonumber(fields.z))
      meta:set_string("formspec", "field[text;Enter text;]")
    elseif fields.text then
      rc.send(RC_RADIUS, pos, {x=x,y=y,z=z}, fields.text, sender:get_player_name())
    end
  end,
})
