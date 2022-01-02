local api = require("apis")
local tArgs = {...}

function mineSquence(Shaft_Amount, Shaft_Width, Shaft_Distance)
  for i=1, Shaft_Amount do
    for j=1, Shaft_Distance do
      api.move.forward()
      api.dig.checkForOre()
      turtle.digUp()
    end
    api.move.turnLeft()
    for j=1, Shaft_Width do
      api.move.forward()
      api.dig.checkForOre()
      turtle.digUp()
    end
    api.move.turnAround()
    api.move.forward(Shaft_Width)
    for j=1, Shaft_Width do
      api.move.forward()
      api.dig.checkForOre()
      turtle.digUp()
    end
    api.move.turnAround()
    api.move.forward(Shaft_Width)
    api.move.turnRight()
    if api.data.loadData("/.save", "/chest")[1] == true then
      api.storage.emptyInv()
    elseif api.data.loadData("/.save", "/chest")[1] == false then
      api.storage.waitforemptyInv()
    end
  end
end

if type(tonumber(tArgs[1])) ~= "number" then
  error(("Usage: %s Define shaft amount, shaft width and shaft distance. (Example: '10 20 3' [10 deep, 20 to each side, and every 3 blocks]"):format(fs.getName(shell.getRunningProgram())))
end

local start = api.data.copyTable(api.coords)
api.data.saveData("/.save", "/start_pos", start)
api.storage.avoidChest()
mineSquence(tonumber(tArgs[1]), tonumber(tArgs[2]), tonumber(tArgs[3]))
api.move.moveTo(start.x, start.y, start.z)
api.storage.drop(api.maxSlots)
fs.delete("/.save")