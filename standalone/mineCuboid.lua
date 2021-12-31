local api = {
  timeout = 5,
  maxSlots = 16,
  slot = tonumber(turtle.getSelectedSlot()),
  d = 0,
  hasWireless = false,
  direction = {[0] = "north", "east", "south", "west"},
  coords = {x = 0, y = 0, z = 0},
}
local fuelList = {
  "minecraft:coal",
  "minecraft:coal_block",
  "minecraft:charcoal",
  "mekanism:block_charcoal",
  "minecraft:lava_bucket",
}

function api.copyTable(tbl)
  if type(tbl) ~= "table" then
    error("The type of 'tbl' is not a table",2)
  end
  local rtbl = {}
  for k,v in pairs(tbl) do
    rtbl[k] = v
  end
  return rtbl
end

function api.findItem(name)
  if type(name) ~= "string" then
    error("The type of 'name' is not a string")
    return false
  end
  local item = turtle.getItemDetail(api.slot)
  if item ~= nil then
    if item.name == name then
      return true
    end
  end
  for i=1,api.maxSlots do
    item = turtle.getItemDetail(i)
    if item ~= nil then
      if item.name == name then
        turtle.select(i)
        api.slot = tonumber(i)
        return true
      end
    end
  end
  return false
end

function api.refuel(skip)
	if skip ~= true then
		skip = false
	end
  if turtle.getFuelLevel() <= 10 or skip then
    for i=1,#fuelList do
      if api.findItem(fuelList[i]) then
        turtle.refuel(1)
        return true
      end
    end
    return false
  else
    return false
  end
end

function api.place(blockName, direction)
  api.findItem(blockName)
  if direction == nil then
    turtle.place()
  elseif direction == "up" then
    turtle.placeUp()
  elseif direction == "down" then
    turtle.placeDown()
  end
end

function api.dig(direction)
  if direction == nil then
    turtle.dig()
  elseif direction == "up" then
    turtle.digUp()
  elseif direction == "down" then
    turtle.digDown()
  end
end

function api.face(direction)
  if type(direction) == "number" or "string" then
    if type(direction) == "string" then
      for k,v in pairs(api.direction) do
        if v == direction then
        direction = k
        break
        end
      end
    end
    if direction == (api.d + 2) % 4 then
      api.turnAround()
      return true
    elseif direction == (api.d - 1) % 4 then
      api.turnLeft()
      return true
    elseif direction == (api.d + 1) % 4 then
      api.turnRight()
      return true
    elseif direction == api.d then
      return true
    end
  end
  error("the type of 'direction' is not of type number, string or is invalid")
end

function api.turnLeft()
  turtle.turnLeft()
  api.d = (api.d - 1) % 4
end

function api.turnRight()
  turtle.turnRight()
  api.d = (api.d + 1) % 4
end

function api.turnAround()
  turtle.turnRight()
  turtle.turnRight()
  api.d = (api.d + 2) % 4
end

function api.forward(times)
  times = times or 1
  if times < 0 then
    api.backward(-times)
  end
  for i=1,times do
    if not api.refuel() and turtle.getFuelLevel() == 0 then
      while not api.refuel() do
        print("Out of Fuel")
        if api.hasWireless then
          rednet.broadcast("Out of Fuel at X: "..api.coords.x.." Y: "..api.coords.y.." Z: "..api.coords.z)
        end
        sleep(api.timeout)
      end
    end
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
    if api.d == 0 then
      api.coords.z = api.coords.z - 1
    elseif api.d == 1 then
      api.coords.x = api.coords.x + 1
    elseif api.d == 2 then
      api.coords.z = api.coords.z + 1
    elseif api.d == 3 then
      api.coords.x = api.coords.x - 1
    end
  end
  return true
end

function api.backward(times)
  times = times or 1
  if times < 0 then
    api.forward(-times)
  end
  for i=1,times do
    while api.refuel() == false and turtle.getFuelLevel() == 0 do
      print("Out of Fuel")
      sleep(api.timeout)
    end
    turtle.back()
    if api.d == 0 then
      api.coords.z = api.coords.z + 1
    elseif api.d == 1 then
      api.coords.x = api.coords.x - 1
    elseif api.d == 2 then
      api.coords.z = api.coords.z - 1
    elseif api.d == 3 then
      api.coords.x = api.coords.x + 1
    end
  end
end

function api.up(times)
  times = times or 1
  if times < 0 then
    api.down(-times)
  end
  for i=1,times do
    while api.refuel() == false and turtle.getFuelLevel() == 0 do
      print("Out of Fuel")
      sleep(api.timeout)
    end
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
    api.coords.y = api.coords.y + 1
  end
  return true
end

function api.down(times)
  times = times or 1
  if times < 0 then
    api.up(-times)
  end
  for i=1,times do
    while api.refuel() == false and turtle.getFuelLevel() == 0 do
      print("Out of Fuel")
      sleep(api.timeout)
    end
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
    api.coords.y = api.coords.y - 1
  end
  return true
end

function api.moveTo(x, y, z)
  if x == "~" then
    x = api.coords.x
  end
  if y == "~" then
    y = api.coords.y
  end
  if z == "~" then
    z = api.coords.z
  end
  if y > api.coords.y then
    api.up(y - api.coords.y)
  end
  if x < api.coords.x then
    api.face(3)
    api.forward(api.coords.x - x)
  elseif x > api.coords.x then
    api.face(1)
    api.forward(x - api.coords.x)
  end
  if z < api.coords.z then
    api.face(0)
    api.forward(api.coords.z - z)
  elseif z > api.coords.z then
    api.face(2)
    api.forward(z - api.coords.z)
  end
  if y < api.coords.y then
    api.down(api.coords.y - y)
  end
end

local start = api.copyTable(api.coords)
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
    if x % 3 == 0 and lastRowCount % 2 == 1 then
      api.turnRight()
    else
      if lastRowCount % 2 == 0 then
        api.turnRight()
      else
        api.turnLeft()
      end
    end
    for z=1,rows do
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
          api.turnAround()
        else
          api.up(3)
          api.dig("up")
          api.turnAround()
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
      end
    end
    if x % 3 == 2 and lastRowCount % 2 == 1 then
      api.turnRight()
    else
      if lastRowCount % 2 == 0 then
        api.turnRight()
      else
        api.turnLeft()
      end
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