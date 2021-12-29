local tArgs = {...}
local api = require ("customAPI")
for i=1,#tArgs do
  tArgs[i] = tonumber(tArgs[i])
end

function mineSquence(width,length)
  api.forward()
  api.dig("down")
  api.forward()
  api.turnLeft()
  api.forward(math.floor(width / 2))
  api.turnRight()
  for x=1,width do
    for y=1,(length - 1) do
      api.forward()
      api.dig("up")
      api.dig("down")
    end
    if x ~= width then
      if x % 2 == 0 then
        api.turnLeft()
        api.forward()
        api.dig("up")
        api.dig("down")
        api.turnLeft()
      else
        api.turnRight()
        api.forward()
        api.dig("up")
        api.dig("down")
        api.turnRight()
      end
    end
  end
end

if #tArgs == 2 and type(tArgs[1]) and type(tArgs[2]) == "number" then
  mineSquence(tArgs[1], tArgs[2])
else
  error(string.format("Usage: %s 5 5", shell.getRunningProgram()),0)
end