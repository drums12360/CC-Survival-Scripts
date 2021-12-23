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

if #tArgs == 1 then
  tArgs[1] = tonumber(tArgs[1])
  if type(tArgs[1]) ~= "number" then
    error(("Usage: %s 10"):format(fs.getName(shell.getRunningProgram())))
  end
  mineSquence(tArgs[1])
end