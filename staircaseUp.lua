local move = require("customAPI")
move.coord.y = 12
local endY = 0

local function mineSequence()
  while turtle.detectUp() do
    turtle.digUp()
    sleep(0.5)
  end
  move.forward()
  turtle.digDown()
  move.up()
  while turtle.detectUp() do
    turtle.digUp()
    sleep(0.5)
  end
end

if arg[1] ~= nil then
  endY = tonumber(arg[1])
  for i = move.coord.y - 2, endY do
    mineSequence()
  end
else
  error("Needs an end Y pos",0)
end