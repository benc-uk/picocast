-- --------------------------------------
-- Simple vector functions
-- --------------------------------------

function v_rotate(v, angle)
  local cs = cos(angle)
  local sn = sin(angle)
  local tx = cs*v.x - sn*v.y
  local ty = sn*v.x + cs*v.y
  v.x = tx
  v.y = ty
end

function v_new(x, y)
  local v = {}
  v.x = x
  v.y = y
  return v
end

