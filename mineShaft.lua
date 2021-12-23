local api = require("customAPI")
local start = {}
start = api.copyTable(api.coords)
local height = 0
local width = 0
local depth = 0
local widthMovement = 0
local junkList = {
  "minecraft:cobblestone",
  "minecraft:dirt",
  "minecraft:andesite",
  "minecraft:diorite",
  "minecraft:granite",
  "minecraft:gravel",
}

function startup()
  if #arg == 3 then
    height = tonumber(arg[1])
    width = tonumber(arg[2])
    depth = tonumber(arg[3])
    widthMovement = math.floor(width / 2)
    if width % 2 == 0 then
      print("Width needs to be an odd #")
      return false
    end
    return true
  else
    print("Please enter correct arguments. The height width and depth are required (e.g. mineShaft 5 5 10)")
    return false
  end
end

function checkFuelLevel()
  local requiredFuelLevel = math.ceil((height * width * depth) + (((height - 1) * 2) + (widthMovement * 2) + depth))
  local currentFuelLevel = tonumber(turtle.getFuelLevel())
  while currentFuelLevel < requiredFuelLevel do
    if not api.refuel(true) then
      print("Not enough Fuel. "..currentFuelLevel.."/"..requiredFuelLevel)
      return false
    end
    currentFuelLevel = tonumber(turtle.getFuelLevel())
  end
  return true
end

function inventorySort()
  for i=1,api.maxSlots do
    local item = turtle.getItemDetail(i)
    if item ~= nil then
      if item.count ~= 64 then
        turtle.select(i)
        api.slot = tonumber(i)
        for j=i,api.maxSlots do
          if turtle.compareTo(j) then
            turtle.select(j)
            turtle.transferTo(i)
            turtle.select(i)
          end
        end
      end
    end
  end
  turtle.select(1)
  api.slot = 1
end

function dropJunk()
  for i=1,api.maxSlots do
    local item = turtle.getItemDetail(i)
    if item ~= nil then
      local isJunk = false
      for j=1,#junkList do
        if item.name == junkList[j] then
          isJunk = true
          break
        end
      end
      if isJunk then
        turtle.select(i)
        api.slot = tonumber(i)
        turtle.dropUp()
      end
    end
  end
  inventorySort()
end

function mineSquence()
  for x=1,depth do
    api.forward()
    for i=1,height do
      if x % 2 == 0 then
        api.turnLeft()
      else
        api.turnRight()
      end
      for y=1,width - 1 do
        if x % 8 == 0 then
          if i == 2 then
            if y == widthMovement + 1 then
              if api.findItem("minecraft:torch") then
                turtle.placeDown()
              end
            end
          end
        end
        api.forward()
      end
      if i ~= height then
        if x % 2 == 0 then
          api.turnLeft()
          api.up()
        else
          api.turnRight()
          api.down()
        end
      end
    end
    if x % 2 == 0 then
      api.turnRight()
    else
      api.turnLeft()
    end
    dropJunk()
  end
  api.moveTo("~",start.y + 1,"~")
  api.moveTo(start.x, start.y, start.z)
end

if startup() then
  if not checkFuelLevel() then
    return
  end
  hasWireless()
  api.turnLeft()
  api.forward(widthMovement)
  api.turnRight()
  api.up(height - 1)
  mineSquence()
end