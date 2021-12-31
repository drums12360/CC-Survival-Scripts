local api = require("customAPI")
local start = {}
start = api.copyTable(api.coords)
local height = 0
local width = 0
local depth = 0
local widthMovement = 0
local junkList = {
  "minecraft:cobbled_deepslate",
  "minecraft:tuff",
  "minecraft:cobblestone",
  "minecraft:dirt",
  "minecraft:andesite",
  "minecraft:diorite",
  "minecraft:granite",
  "minecraft:gravel",
}

function startup()
  if #arg == 3 then
    width = tonumber(arg[1])
    height = tonumber(arg[2])
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
  local requiredFuelLevel = math.ceil(((height * width * depth) / 3) + (height * depth) + ((widthMovement * 2) + depth + height))
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
  local rows = math.floor(height / 3)
  local offset = height % 3
  local lastRowCount = 0
  for x=1,depth do
    api.forward()
    api.dig("up")
    api.dig("down")
    for z=1,rows do
      if lastRowCount % 2 == 0 then
        api.turnRight()
      else
        api.turnLeft()
      end
      for y=1,width - 1 do
        api.forward()
        api.dig("up")
        api.dig("down")
      end
      lastRowCount = z
      if z ~= rows then
        if x % 2 == 0 then
          api.down(3)
          api.dig("down")
        else
          api.up(3)
          api.dig("up")
        end
        if lastRowCount % 2 == 0 then
          api.turnRight()
        else
          api.turnLeft()
        end
      elseif offset ~= 0 then
        if x % 2 == 0 then
          api.down(offset)
          api.dig("down")
          api.turnAround()
        else
          api.up(offset)
          api.dig("up")
          api.turnAround()
        end
        for y=1,width - 1 do
          api.forward()
          if x % 2 == 0 then
            api.dig("down")
          else
            api.dig("up")
          end
        end
        lastRowCount = z + 1
        if lastRowCount % 2 == 0 then
          api.turnAround()
        end
      elseif z == rows and z % 2 == 0 then
        api.turnAround()
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
  api.turnLeft()
  api.forward(widthMovement)
  api.turnRight()
  api.up()
  mineSquence()
end