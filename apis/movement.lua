local move = {
  maxSlots = 16,
  slot = tonumber(turtle.getSelectedSlot()),
  d = 0,
  hasWireless = false,
  direction = {[0] = "north", [1] = "east", [2] = "south", [3] = "west"},
  coords = {x = 0, y = 0,z = 0}
}
local fuelList = {
  "minecraft:coal",
  "minecraft:coal_block",
  "minecraft:charcoal",
  "mekanism:block_charcoal",
  "minecraft:lava_bucket",
}

function move.findItem(name)
  for i=1,move.maxSlots do
    local item = turtle.getItemDetail(i)
    if item ~= nil then
      if item.name == name then
        turtle.select(i)
        move.slot = tonumber(i)
        return true
      end
    end
  end
  return false
end

-- call at start of program
function move.refuel(skip)
	if skip ~= true then
		skip = false
	end
  if turtle.getFuelLevel() <= 10 or skip then
    for i=1,#fuelList do
      if move.findItem(fuelList[i]) then
        turtle.refuel(1)
        return true
      end
    end
    return false
  else
    return false
  end
end

function move.face(direction)
  if direction == "north" or "east" or "south" or "west" then
    for k,v in pairs(move.direction) do
      if v == arg then
      direction = k
      break
      end
    end
  end
  if direction == (move.d + 2) % 4 then
    move.turnAround()
  elseif direction == (move.d - 1) % 4 then
    move.turnLeft()
  elseif direction == (move.d + 1) % 4 then
    move.turnRight()
  end
end

function move.turnLeft()
  turtle.turnLeft()
  move.d = (move.d - 1) % 4
end

function move.turnRight()
  turtle.turnRight()
  move.d = (move.d + 1) % 4
end

function move.turnAround()
  turtle.turnRight()
  turtle.turnRight()
  move.d = (move.d + 2) % 4
end

function move.forward(times)
  if times == nil then
    times = 1
  end
  if times < 0 then
    move.backward(-times)
  end
  for i=1,times do
    move.refuel()
    while not turtle.forward() do
      local inspect = {turtle.inspect()}
      if inspect[1] and inspect[2].name == "minecraft:bedrock" then
        return false
      elseif inspect[1] and inspect[2].name ~= "minecraft:bedrock" then
        turtle.dig()
      else
        turtle.attack()
      end
    end
    if move.d == 0 then
      move.coords.z = move.coords.z - 1
    elseif move.d == 1 then
      move.coords.x = move.coords.x + 1
    elseif move.d == 2 then
      move.coords.z = move.coords.z + 1
    elseif move.d == 3 then
      move.coords.x = move.coords.x - 1
    end
  end
  return true
end

function move.backward(times)
  if times == nil then
    times = 1
  end
  if times < 0 then
    move.forward(-times)
  end
  for i=1,times do
    move.refuel()
    turtle.back()
    if move.d == 0 then
      move.coords.z = move.coords.z + 1
    elseif move.d == 1 then
      move.coords.x = move.coords.x - 1
    elseif move.d == 2 then
      move.coords.z = move.coords.z - 1
    elseif move.d == 3 then
      move.coords.x = move.coords.x + 1
    end
  end
end

function move.up(times)
  if times == nil then
    times = 1
  end
  if times < 0 then
    move.down(-times)
  end
  for i=1,times do
    move.refuel()
    while not turtle.up() do 
      local inspect = {turtle.inspectUp()}
      if inspect[1] and inspect[2].name == "minecraft:bedrock" then
        return false
      elseif inspect[1] and inspect[2].name ~= "minecraft:bedrock" then
        turtle.digUp()
      else
        turtle.attackUp()
      end
    end
    move.coords.y = move.coords.y + 1
  end
  return true
end

function move.down(times)
  if times == nil then
    times = 1
  end
  if times < 0 then
    move.up(-times)
  end
  for i=1,times do
    move.refuel()
    while not turtle.down() do 
      local inspect = {turtle.inspectDown()}
      if inspect[1] and inspect[2].name == "minecraft:bedrock" then
        return false
      elseif inspect[1] and inspect[2].name ~= "minecraft:bedrock" then
        turtle.digDown()
      else
        turtle.attackDown()
      end
    end
    move.coords.y = move.coords.y - 1
  end
  return true
end

function move.moveTo(x, y, z)
  if x == "~" then
    x = move.coords.x
  end
  if y == "~" then
    y = move.coords.y
  end
  if z == "~" then
    z = move.coords.z
  end
  if y > move.coords.y then
    move.up(y - move.coords.y)
  end
  if x < move.coords.x then
    move.face(3)
    move.forward(move.coords.x - x)
  elseif x > move.coords.x then
    move.face(1)
    move.forward(x - move.coords.x)
  end
  if z < move.coords.z then
    move.face(0)
    move.forward(move.coords.z - z)
  elseif z > move.coords.z then
    move.face(2)
    move.forward(z - move.coords.z)
  end
  if y < move.coords.y then
    move.down(move.coords.y - y)
  end
end

return move