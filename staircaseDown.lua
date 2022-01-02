local move = require("moveAPI")
move.coord.y = 12
local endY = 0

local function mineSequence()
  turtle.digDown()
  move.forward()
  while turtle.detectUp() do
    turtle.digUp()
    sleep(0.5)
  end
  move.down()
  turtle.digDown()
end

if arg[1] ~= nil then
  endY = tonumber(arg[1])
  for i = move.coord.y - 2, endY, -1 do
    mineSequence()
  end
else
  error("Needs an end Y pos",0)
end