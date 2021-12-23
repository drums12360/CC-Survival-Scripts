local api = {
  timeout = 5,
  maxSlots = 16,
  slot = tonumber(turtle.getSelectedSlot()),
  d = 0,
  hasWireless = false,
  direction = {[0] = "north", "east", "south", "west"},
  coords = {x = 0, y = 0, z = 0},
}
local tArgs = {...}
local stack = {}
local inverter = {
  ["forward"] = api.backward,
  ["back"] = api.forward,
  ["turnLeft"] = api.turnRight,
  ["turnRight"] = api.turnLeft,
  ["up"] = api.down,
  ["down"] = api.up,
}
local converter = {
  ["forward"] = api.forward,
  ["back"] = api.backward,
  ["turnLeft"] = api.turnLeft,
  ["turnRight"] = api.turnRight,
  ["up"] = api.up,
  ["down"] = api.down,
}
local oreList = {
  "minecraft:iron_ore",
  "minecraft:coal_ore",
  "minecraft:gold_ore",
  "minecraft:diamond_ore",
  "minecraft:emerald_ore",
  "minecraft:copper_ore",
  "minecraft:deepslate_iron_ore",
  "minecraft:deepslate_coal_ore",
  "minecraft:deepslate_gold_ore",
  "minecraft:deepslate_diamond_ore",
  "minecraft:deepslate_emerald_ore",
  "minecraft:deepslate_copper_ore",
  "minecraft:nether_gold_ore",
  "minecraft:nether_quartz_ore",
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
    end
  else
    error("the type of 'direction' is not of type number, string or is invalid")
  end
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

function stackPop()
  local func = inverter[stack[#stack]]
  table.remove(stack)
  return func()
end

function checkOreTable(tbl)
  if type(tbl) ~= "table" then
    error("'tbl' is not of type table",2)
  end
  if tbl[1] == true then
    for k,v in pairs(oreList) do
      if tbl[2].name == oreList[k] then
        return true
      end
    end
    return false
  else
    return false
  end
end

function veinMine(lastFunc)
  if type(lastFunc) == "function" or "string" then
    if type(lastFunc) == "function" then
      for k,v in pairs(converter) do
        if v == lastFunc then
          table.insert(stack, k)
          break
        end
      end
    end
    if checkOreTable({turtle.inspectUp()}) then
      api.up()
      return veinMine(api.up)
    elseif checkOreTable({turtle.inspectDown()}) then
      api.down()
      return veinMine(api.down)
    end
    for i=1,4 do
      if checkOreTable({turtle.inspect()}) then
        if i == 1 then
          api.forward()
          return veinMine(api.forward)
        elseif i == 2 then
          return veinMine(api.turnLeft)
        elseif i == 3 then
          table.insert(stack, "turnLeft")
          return veinMine(api.turnLeft)
        elseif i == 4 then
          return veinMine(api.turnRight)
        end
      end
      api.turnLeft()
    end
    if stack[#stack] == "turnLeft" then
      if stack[#stack] == stack[#stack-1] then
        stackPop()
        stackPop()
        lastFunc = stack[#stack]
        if #stack > 0 then
          return veinMine(lastFunc)
        end
        return
      else
        stackPop()
        lastFunc = stack[#stack]
        if #stack > 0 then
          return veinMine(lastFunc)
        end
        return
      end
    else
      stackPop()
      lastFunc = stack[#stack]
      if #stack > 0 then
        return veinMine(lastFunc)
      end
      return
    end
  else
    error("'lastFunc' is not of type function or string", 2)
  end
end

function checkForOre()
  if checkOreTable({turtle.inspectUp()}) then
    api.up()
    veinMine(api.up)
  end
  if checkOreTable({turtle.inspectDown()}) then
    api.down()
    veinMine(api.down)
  end
  api.turnLeft()
  if checkOreTable({turtle.inspect()}) then
    api.forward()
    veinMine(api.forward)
  end
  api.turnAround()
  if checkOreTable({turtle.inspect()}) then
    api.forward()
    veinMine(api.forward)
  end
  api.turnLeft()
end

function mineSquence(amount)
  for i=1, amount do
    api.forward()
    checkForOre()
  end
  if checkOreTable({turtle.inspect()}) then
    api.forward()
    veinMine(api.forward)
  end
end

if type(tArgs[1]) ~= "number" then
  error(("Usage: %s 10"):format(fs.getName(shell.getRunningProgram())))
end
tArgs[1] = tonumber(tArgs[1])
local start = api.copyTable(api.coords)
mineSquence(tArgs[1])
api.moveto(start.x, start.y, start.z)

