local api = require("apis")
local tArgs = {...}
local stack = {}
local inverter = {
  ["forward"] = api.move.backward,
  ["back"] = api.move.forward,
  ["turnLeft"] = api.move.turnRight,
  ["turnRight"] = api.move.turnLeft,
  ["up"] = api.move.down,
  ["down"] = api.move.up,
}
local converter = {
  ["forward"] = api.move.forward,
  ["back"] = api.move.backward,
  ["turnLeft"] = api.move.turnLeft,
  ["turnRight"] = api.move.turnRight,
  ["up"] = api.move.up,
  ["down"] = api.move.down,
}
local oreList = {
  "minecraft:iron_ore",
  "minecraft:coal_ore",
  "minecraft:gold_ore",
  "minecraft:diamond_ore",
  "minecraft:emerald_ore",
  "minecraft:copper_ore",
  "minecraft:lapis_ore",
  "minecraft:redstone_ore",
  "minecraft:deepslate_iron_ore",
  "minecraft:deepslate_coal_ore",
  "minecraft:deepslate_gold_ore",
  "minecraft:deepslate_diamond_ore",
  "minecraft:deepslate_emerald_ore",
  "minecraft:deepslate_copper_ore",
  "minecraft:deepslate_lapis_ore",
  "minecraft:deepslate_redstone_ore",
  "minecraft:nether_gold_ore",
  "minecraft:nether_quartz_ore",
}

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
      api.move.up()
      return veinMine(api.move.up)
    elseif checkOreTable({turtle.inspectDown()}) then
      api.move.down()
      return veinMine(api.move.down)
    end
    for i=1,4 do
      if checkOreTable({turtle.inspect()}) then
        if i == 1 then
          api.move.forward()
          return veinMine(api.move.forward)
        elseif i == 2 then
          return veinMine(api.move.turnLeft)
        elseif i == 3 then
          table.insert(stack, "turnLeft")
          return veinMine(api.move.turnLeft)
        elseif i == 4 then
          return veinMine(api.move.turnRight)
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
    api.move.up()
    veinMine(api.move.up)
  end
  if checkOreTable({turtle.inspectDown()}) then
    api.move.down()
    veinMine(api.move.down)
  end
  api.turnLeft()
  if checkOreTable({turtle.inspect()}) then
    api.move.forward()
    veinMine(api.move.forward)
  end
  api.turnAround()
  if checkOreTable({turtle.inspect()}) then
    api.move.forward()
    veinMine(api.move.forward)
  end
  api.move.turnLeft()
end

function mineSquence(amount)
  for i=1, amount do
    api.move.forward()
    checkForOre()
  end
  if checkOreTable({turtle.inspect()}) then
    api.move.forward()
    veinMine(api.move.forward)
  end
end

if type(tArgs[1]) ~= "number" then
  error(("Usage: %s 10"):format(fs.getName(shell.getRunningProgram())))
end
tArgs[1] = tonumber(tArgs[1])
local start = api.data.copyTable(api.coords)
mineSquence(tArgs[1])
api.move.moveTo(start.x, start.y, start.z)
fs.delete("/.save")
