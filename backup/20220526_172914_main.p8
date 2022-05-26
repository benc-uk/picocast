pico-8 cartridge // http://www.pico-8.com
version 36
__lua__
#include vector.lua
bsize = 4

p = {}
p.x = 2.5
p.y = 2.5
p.f = v_new(1, 0)
wall_height = 64

speed = 0
turn = 0

cam_plane = v_new(0, 0.44)

function _update()
  local turn_speed = 0.015
  local move_speed = 0.22

  if (btn(0)) turn  = turn_speed 
  if (btn(1)) turn  = -turn_speed 
  if (btn(2)) speed = move_speed
  if (btn(3)) speed = -move_speed

  if (turn != 0) then
    v_rotate(p.f, turn)
    v_rotate(cam_plane, turn)
    turn = turn * 0.6
  end

  if (speed != 0) then
    local px = p.x + p.f.x * speed
    local py = p.y + p.f.y * speed
    if (mget(px, py) == 0) then
      p.x = px
      p.y = py
    end
    speed = speed * 0.6
  end
  
  if (abs(speed) < 0.0001) speed = 0
  if (abs(turn) < 0.0001) turn = 0
end

function _draw()
  rectfill(0, 0, 127, 63, 12)
  rectfill(0, 64, 127, 127, 5)

  for x = 0, 127 do 
    local cameraX = ((2 * x) / 128) - 1 -- xcoordinate in camera space
    local rayDirX = p.f.x + cam_plane.x * cameraX
    local rayDirY = p.f.y + cam_plane.y * cameraX

    -- which cell of the map we're in
    local mapX = flr(p.x)
    local mapY = flr(p.y)

    -- length of ray from current position to next x or y-side
    local sideDistX
    local sideDistY

    local deltaDistX = abs(1 / rayDirX)
    if (rayDirX == 0) deltaDistX = 32767
    local deltaDistY = abs(1 / rayDirY) 
    if (rayDirY == 0) deltaDistY = 32767

    local perpWallDist;

    -- what direction to step in x or y-direction (either +1 or -1)
    local stepX
    local stepY

    local hit = 0 --was there a wall hit?
    local side    --was a NS or a EW wall hit?

    -- calculate step and initial sideDist
    if(rayDirX < 0) then
      stepX = -1
      sideDistX = (p.x - mapX) * deltaDistX
    else
      stepX = 1
      sideDistX = (mapX + 1.0 - p.x) * deltaDistX
    end

    if(rayDirY < 0) then
      stepY = -1
      sideDistY = (p.y - mapY) * deltaDistY
    else
      stepY = 1
      sideDistY = (mapY + 1.0 - p.y) * deltaDistY
    end

    -- carry out DDA
    while(hit == 0) do
      -- jump to next map square, either in x-direction, or in y-direction
      if(sideDistX < sideDistY) then
        sideDistX += deltaDistX
        mapX += stepX
        side = 0
      else
        sideDistY += deltaDistY
        mapY += stepY
        side = 1
      end

      if(abs(mapY-p.y) > 20 or abs(mapX-p.x) > 20) then
        -- Max dist check, I added this to prevent the ray from going too far
        hit = -1
      else
        -- Check if ray has hit a wall
        if(mget(mapX, mapY) > 0) hit = 1
      end
    end

    if(hit > 0) then
      perpWallDist = 0 
      if(side == 0) then
        perpWallDist = (sideDistX - deltaDistX)
      else          
        perpWallDist = (sideDistY - deltaDistY)
      end

      lineHeight = 128 / perpWallDist;

      -- finally draw the column of wall
      line(x, 64 - lineHeight/2, x, 64 + lineHeight/2, mget(mapX, mapY)+side)
    end
  end

  print("speed: "..speed, 0, 0, 0)
  print("turn: "..turn, 0, 8, 0)
  -- for x=0,127 do
  --   for y=0, 63 do
  --     m = mget(x,y)
  --     if (m > 0) then   
  --       draw_square(x*bsize, y*bsize, bsize, m)
  --     end
  --   end
  -- end

  -- if(btn(4)) then
  --   plane.y = plane.y + 0.01
  -- end
  -- if(btn(5)) then
  --   plane.y = plane.y - 0.01
  -- end
end

function draw_wall_column(x, dist, cell)
  -- correct fish eye effect by scaling the distance
  dist = dist * cos(fov/128 * abs(x - 64))
  local ch = wall_height / dist
  line(x, 64 - ch, x, 64 + ch, cell)
end

function cast_ray(px, py, v, step, dist, draw)
  draw = draw or false
  local hit = {}
  hit.dist = dist
  hit.cell = 0
  hit.x = -1
  hit.y = -1

  local t = 0
  while t < dist do
    t = t + step
    local x = px + v.x * t
    local y = py + v.y * t
    if(draw) then
      pset(x*bsize, y*bsize, 11)
    end

    if mget(x, y) != 0 then
      hit.dist = t
      hit.cell = mget(flr(x), flr(y))
      hit.x = x
      hit.y = y
      return hit
    end
  end

  return hit
end

function draw_square(x, y, w, c)
  w = w - 1
  rectfill(x, y, x + w, y + w, c)
  rect(x, y, x + w, y + w, 10)
end
__gfx__
00000000111111112222222233333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000111111112222222233333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700111111112222222233333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000111111112222222233333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000111111112222222233333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700111111112222222233333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000111111112222222233333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000111111112222222233333333000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000080000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000008000000000000080008000080000800000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000800000000000808808000080008000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000080000000000800088000800008000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000080000000000800008888000080000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000008800000008000080000000800000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000088000008000080000008000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000880008000800008880000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000008888888888880000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000008008000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000008880000000000000000000000000000000000000000000000000000000000000000000
__map__
0101030103010301020303030303030100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000003000300000101010100000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0300000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000002000101010100000101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0300020000000200000000000200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000000000000000000030200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0100000000000000000000020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000003000100010200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000100010200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000300000000000000010200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000003000100010200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000100010200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0200000000000000000100010200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020102020200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
