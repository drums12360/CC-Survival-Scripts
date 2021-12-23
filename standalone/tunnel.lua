local expect = require("cc.expect").expect
local slot = tonumber(turtle.getSelectedSlot())
local direction = {[0] = "north", "east", "south", "west"}
local d = 0
local maxSlots = 16
local coords = {x = 0, y = 0, z = 0}
local start = {}
local length = tonumber(arg[1])
local fuelList = {
  "minecraft:coal",
  "minecraft:coal_block",
  "minecraft:charcoal",
  "minecraft:lava_bucket",
}
local whitelistedItems = {
  "minecraft:torch",
  "minecraft:coal",
  "minecraft:coal_block",
  "minecraft:charcoal",
  "minecraft:lava_bucket",
}

function findItem(name)
  for i=1,maxSlots do
    local item = turtle.getItemDetail(i)
    if item ~= nil then
      if item.name == name then
        turtle.select(i)
        slot = tonumber(i)
        return true
      end
    end
  end
  return false
end

function refuel(skip)
  if skip ~= true then
    skip = false
  end
  if turtle.getFuelLevel() <= 10 or skip then
    for i=1,#fuelList do
      if findItem(fuelList[i]) then
        turtle.refuel(1)
        return true
      end
    end
    return false, turtle.getFuelLevel()
  else
    return false, turtle.getFuelLevel()
  end
end

function face(dir)
  if dir == "north" or "east" or "south" or "west" then
    for k,v in pairs(direction) do
      if v == dir then
      dir = k
      break
      end
    end
  end
  if dir == (d + 2) % 4 then
    turnAround()
  elseif dir == (d - 1) % 4 then
    turnLeft()
  elseif dir == (d + 1) % 4 then
    turnRight()
  end
end

function turnLeft()
  turtle.turnLeft()
  d = (d - 1) % 4
end

function turnRight()
  turtle.turnRight()
  d = (d + 1) % 4
end

function turnAround()
  turtle.turnRight()
  turtle.turnRight()
  d = (d + 2) % 4
end

function forward(times)
  times = times or 1
  if times < 0 then
    backward(-times)
  end
  for i=1,times do
    refuel()
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
    if d == 0 then
      coords.z = coords.z - 1
    elseif d == 1 then
      coords.x = coords.x + 1
    elseif d == 2 then
      coords.z = coords.z + 1
    elseif d == 3 then
      coords.x = coords.x - 1
    end
  end
  return true
end

function backward(times)
  times = times or 1
  if times < 0 then
    forward(-times)
  end
  for i=1,times do
    refuel()
    turtle.back()
    if d == 0 then
      coords.z = coords.z + 1
    elseif d == 1 then
      coords.x = coords.x - 1
    elseif d == 2 then
      coords.z = coords.z - 1
    elseif d == 3 then
      coords.x = coords.x + 1
    end
  end
end

function up(times)
  times = times or 1
  if times < 0 then
    down(-times)
  end
  for i=1,times do
    refuel()
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
    coords.y = coords.y + 1
  end
  return true
end

function down(times)
  times = times or 1
  if times < 0 then
    up(-times)
  end
  for i=1,times do
    refuel()
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
    coords.y = coords.y - 1
  end
  return true
end

function moveTo(x, y, z)
  if x == "~" then
    x = coords.x
  end
  if y == "~" then
    y = coords.y
  end
  if z == "~" then
    z = coords.z
  end
  if y > coords.y then
    up(y - coords.y)
  end
  if x < coords.x then
    face(3)
    forward(coords.x - x)
  elseif x > coords.x then
    face(1)
    forward(x - coords.x)
  end
  if z < coords.z then
    face(0)
    forward(coords.z - z)
  elseif z > coords.z then
    face(2)
    forward(z - coords.z)
  end
  if y < coords.y then
    down(coords.y - y)
  end
end

local hasTorches = true
function placeTorch()
  if findItem("minecraft:torch") then
    turtle.place()
  else
    hasTorches = false
  end
end

function inventoryToChest(ignore)
  if type(ignore) ~= "boolean" then
    ignore = false
  end
  if ignore == false then
    for i=1,maxSlots do
      local item = turtle.getItemDetail(i)
      if item ~= nil then
        for j=1, #whitelistedItems do
          if item.name ~= whitelistedItems[j] then
            turtle.select(i)
            slot = i
            turtle.drop()
          end      
        end
      end
    end
  else
    for i=1,maxSlots do
      turtle.select(i)
      slot = i
      turtle.drop()
    end
  end
  turtle.select(1)
  slot = 1
end

function copyTable(tbl)
  local rtbl = {}
  for k,v in pairs(tbl) do
    rtbl[k] = v
  end
  return rtbl
end

function checkInventory()
  if turtle.getItemCount(maxSlots) >= 1 then
    local current = copyTable(coords)
    moveTo(start.x, start.y, start.z)
    inventoryToChest()
    moveTo(current.x, current.y, current.z)
  end
end

function mineSquence(amount)
  for x=1,amount do
    forward()
    turnRight()
    turtle.dig()
    if x % 8 == 0 then
      if hasTorches then
        placeTorch()
      end
    end
    turnAround()
    turtle.dig()
    if (x + 4) % 8 == 0 then
      if hasTorches then
        placeTorch()
      end
    end
    if x % 2 == 0 then
      down()
    else
      up()
    end
    turtle.dig()
    turnAround()
    turtle.dig()
    turnLeft()
    checkInventory()
  end
  moveTo(start.x, start.y, start.z)
  inventoryToChest()
end

if type(length) ~= "number" then
  printError("Usage: "..shell.getRunningProgram().." 42")
  expect(1, length, "number")
end
local _, level = refuel()
if length * 2 <= level then
  start = copyTable(coords)
  mineSquence(length)
else
  error("Not enough Fuel to start",0)
end
