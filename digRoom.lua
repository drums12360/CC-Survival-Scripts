local tArgs = {...}
local api = require("apis")
for i=1,#tArgs do
  tArgs[i] = tonumber(tArgs[i])
end

function mineSquence(width,length)
  api.move.forward()
  api.tools.dig("down")
  api.move.forward()
  api.move.turnLeft()
  api.move.forward(math.floor(width / 2))
  api.move.turnRight()
  for x=1,width do
    for y=1,(length - 1) do
      api.move.forward()
      api.tools.dig("up")
      api.tools.dig("down")
    end
    if x ~= width then
      if x % 2 == 0 then
        api.move.turnLeft()
        api.move.forward()
        api.tools.dig("up")
        api.tools.dig("down")
        api.move.turnLeft()
      else
        api.move.turnRight()
        api.move.forward()
        api.tools.dig("up")
        api.tools.dig("down")
        api.move.turnRight()
      end
    end
  end
end

if #tArgs == 2 and type(tArgs[1]) and type(tArgs[2]) == "number" then
  mineSquence(tArgs[1], tArgs[2])
else
  error(string.format("Usage: %s 5 5", shell.getRunningProgram()),0)
end