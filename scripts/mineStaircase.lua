--[[local data = require("dataAPI")
local move = require("moveAPI")
local tools = require("toolsAPI")--]]
local library = require("library/init")
local tArgs = {...}

local function mineSquence(steps, direction)
	for i=1, steps do
		if direction == "up" then
			while turtle.detectUp() do
				library.tools.dig("up")
			end
			library.move.forward()
			library.move.up()
		elseif direction == "down" then
			while turtle.detectUp() do
				library.tools.dig("up")
			end
			library.move.forward()
			library.move.down()
		end
	end
end

if type(tonumber(tArgs[1])) ~= "number" and type(tostring(tArgs[1])) ~= "string" then
	term.clear()
	term.setCursorPos(1,1)
	error("Define step amount and direction! (Example: '10 up') [10 steps, upwards]")
end

local start = library.data.copyTable(library.data.coords)
library.data.saveData("/.save", "/start_pos", start)
mineSquence(tonumber(tArgs[1]), tostring(tArgs[2]))
fs.delete("/.save")