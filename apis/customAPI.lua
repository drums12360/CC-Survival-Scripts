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

function api.saveData(dir, path, tbl)
  if type(tbl) ~= "table" then
    error("The type of 'tbl' is not a table",2)
  elseif type(path) ~= "string" or type(dir) ~= "string" then
    error("The type of 'path' or 'dir' is not a string",2)
  end
  if not fs.exists(dir) then
    fs.makeDir(dir)
  end
  local f = fs.open(dir .. path, "w")
  f.write(textutils.serialize(tbl))
  f.close()
end

function api.loadData(dir, path)
  if type(path) ~= "string" or type(dir) ~= "string" then
    error("The type of 'path' or 'dir' is not a string",2)
  end
  if fs.exists(dir) then
    local tbl = {}
    local f = fs.open(dir .. path, "r")
    tbl = f.readAll()
    tbl = textutils.unserialize(tbl)
    f.close()
    return tbl
  end
  return false
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

function api.gpsStart(side)
  if api.hasWireless then
    rednet.open(side)
    local Start1 = vector.new(gps.locate(2))
    while not turtle.forward() do
      turtle.turnRight()
    end
    local Start2 = vector.new(gps.locate(2))
    if Start1.x ~= Start2.x then
      if Start1.x - Start2.x == -1 then
        api.d = 3
      elseif Start1.x - Start2.x == 1 then
        api.d = 1
      end
    elseif Start1.z ~= Start2.z then
      if Start1.z - Start2.z == -1 then
        api.d = 0
      elseif Start1.z - Start2.z == 1 then
        api.d = 2
      end
    end
    api.coords.x = Start2.x
    api.coords.y = Start2.y
    api.coords.z = Start2.z
    api.backward()
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
  api.saveData("/.save", "/face", {d = api.d})
end

function api.turnRight()
  turtle.turnRight()
  api.d = (api.d + 1) % 4
  api.saveData("/.save", "/face", {d = api.d})
end

function api.turnAround()
  turtle.turnRight()
  turtle.turnRight()
  api.d = (api.d + 2) % 4
  api.saveData("/.save", "/face", {d = api.d})
end

function api.left(times)
  api.turnLeft()
  api.forward(times)
  api.turnRight()
end

function api.right(times)
  api.turnRight()
  api.forward(times)
  api.turnLeft()
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
		while turtle.detect() do
          turtle.dig()
		  sleep(0.4)
		end
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
    api.saveData("/.save", "/position", api.coords)
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
    api.saveData("/.save", "/position", api.coords)
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
    api.saveData("/.save", "/position", api.coords)
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
    api.saveData("/.save", "/position", api.coords)
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

function api.drop(slots)
  local inspect, data = turtle.inspect()
  if data.name == "minecraft:chest" then
	for i=1, slots do
	  while api.refuel() == false and turtle.getFuelLevel() == 0 do
		print("Out of Fuel")
		sleep(api.timeout)
      end
	  turtle.select(i)
	  turtle.drop()
	end
	turtle.select(1)
  end
end

function api.avoidChest()
  local chest = {}
  local inspect, data = turtle.inspect()
  if data.name == "minecraft:chest" then
	while api.refuel() == false and turtle.getFuelLevel() == 0 do
      print("Out of Fuel")
      sleep(api.timeout)
	end
	chest[1] = true
	api.saveData("/.save", "/chest", chest)
	api.turnAround()
  else
	chest[1] = false
	api.saveData("/.save", "/chest", chest)
  end
end

function api.emptyInv()
local full = false
local start = api.loadData("/.save", "/start_pos")
  if turtle.getItemCount(15) > 0 then
	full = true
  end
  if full == true then
	while api.refuel() == false and turtle.getFuelLevel() == 0 do
      print("Out of Fuel")
      sleep(api.timeout)
	end
	local mining = api.copyTable(api.coords)
	api.moveTo(start.x, start.y, start.z)
	api.drop(15)
	api.moveTo(mining.x, mining.y, mining.z)
	turtle.select(1)
	full = false
  end
end

function api.waitforemptyInv()
local full = false
local start = api.loadData("/.save", "/start_pos")
  while turtle.getItemCount(15) > 0 do
	full = true
  end
  if full == true then
	while api.refuel() == false and turtle.getFuelLevel() == 0 do
      print("Out of Fuel")
      sleep(api.timeout)
	end
	local mining = api.copyTable(api.coords)
	api.moveTo(start.x, start.y, start.z)
  end
  if turtle.getItemCount(15) == 0 then
	api.moveTo(mining.x, mining.y, mining.z)
	turtle.select(1)
	full = false
  end
end

return api
