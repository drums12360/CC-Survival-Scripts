local library = require("library/init")
local tArgs = {...}

function mineSquence(width, height, depth, side)
	local requiredFuelLevel = math.ceil(((height * width * depth) / 3) + (height * depth) + (width + depth + height))
	local currentFuelLevel = tonumber(turtle.getFuelLevel())
	local rows = math.floor(height / 3)
	local offset = height % 3
	local lastRowCount = 0
	if width % 2 == 0 then
		term.clear()
		term.setCursorPos(1,1)
		error("Width needs to be an odd #!")
	end
	if not library.move.refuel() and currentFuelLevel < requiredFuelLevel then
		while not library.move.refuel() do
			term.clear()
			term.setCursorPos(1,1)
			print("Not enough Fuel! "..currentFuelLevel.."/"..requiredFuelLevel)
			print("Place fuel into inventory!")
			os.sleep(library.data.timeout)
		end
		term.clear()
		term.setCursorPos(1,1)
	end
	if side == "left" or side == tostring(nil) then
		library.move.up()
		for x=1, depth do
			library.move.forward()
			library.tools.dig("up")
			library.tools.dig("down")
		if x % 3 == 0 and lastRowCount % 2 == 1 then
			library.move.turnLeft()
		else
		if lastRowCount % 2 == 0 then
			library.move.turnLeft()
		else
			library.move.turnRight()
		end
		end
		for z=1, rows do
			for y=1, width - 1 do
				library.move.forward()
				library.tools.dig("up")
				library.tools.dig("down")
			end
			lastRowCount = z
			if z ~= rows then
				if x % 2 == 0 then
					library.move.down(3)
					library.tools.dig("down")
					library.move.turnAround()
				else
					library.move.up(3)
					library.tools.dig("up")
					library.move.turnAround()
				end
			elseif offset ~= 0 then
				if x % 2 == 0 then
					library.move.down(offset)
					library.tools.dig("down")
					library.move.turnAround()
				else
					library.move.up(offset)
					library.tools.dig("up")
					library.move.turnAround()
				end
				for y=1, width - 1 do
					library.move.forward()
					if x % 2 == 0 then
						library.tools.dig("down")
					else
						library.tools.dig("up")
					end
				end
				lastRowCount = z + 1
			end
		end
		if x % 3 == 2 and lastRowCount % 2 == 1 then
			library.move.turnLeft()
		else
			if lastRowCount % 2 == 0 then
				library.move.turnLeft()
			else
				library.move.turnRight()
			end
		end
		library.tools.dropJunk()
		end
	elseif side == "right" then
		library.move.up()
		for x=1, depth do
			library.move.forward()
			library.tools.dig("up")
			library.tools.dig("down")
		if x % 3 == 0 and lastRowCount % 2 == 1 then
			library.move.turnRight()
		else
		if lastRowCount % 2 == 0 then
			library.move.turnRight()
		else
			library.move.turnLeft()
		end
		end
		for z=1, rows do
			for y=1, width - 1 do
				library.move.forward()
				library.tools.dig("up")
				library.tools.dig("down")
			end
			lastRowCount = z
			if z ~= rows then
				if x % 2 == 0 then
					library.move.down(3)
					library.tools.dig("down")
					library.move.turnAround()
				else
					library.move.up(3)
					library.tools.dig("up")
					library.move.turnAround()
				end
			elseif offset ~= 0 then
				if x % 2 == 0 then
					library.move.down(offset)
					library.tools.dig("down")
					library.move.turnAround()
				else
					library.move.up(offset)
					library.tools.dig("up")
						library.move.turnAround()
				end
				for y=1, width - 1 do
					library.move.forward()
					if x % 2 == 0 then
						library.tools.dig("down")
					else
						library.tools.dig("up")
					end
				end
				lastRowCount = z + 1
			end
		end
		if x % 3 == 2 and lastRowCount % 2 == 1 then
			library.move.turnRight()
		else
			if lastRowCount % 2 == 0 then
				library.move.turnRight()
			else
				library.move.turnLeft()
			end
		end
		library.tools.dropJunk()
		end
	elseif side ~= "left" or side ~= "right" or side ~= tostring(nil) then
		term.clear()
		term.setCursorPos(1,1)
		error("That is not a valid direction! (Possible directions are 'left', 'right' or none to use left as default)")
	end
end

if type(tonumber(tArgs[1])) and type(tonumber(tArgs[2])) and type(tonumber(tArgs[3])) ~= "number" then
	term.clear()
	term.setCursorPos(1,1)
	error("Width, height and depth are required! (Example: '5 5 10 right') [5 blocks wide, 5 block heigh, 10 blocks deep and to the right of turtle]")
end

local start = library.data.copyTable(library.data.coords)
library.data.saveData("/.save", "/start_pos", start)
mineSquence(tonumber(tArgs[1]), tonumber(tArgs[2]), tonumber(tArgs[3]), (tostring(tArgs[4])))
library.move.moveTo("~",start.y + 1,"~")
library.move.moveTo(start.x, start.y, start.z)
library.storage.drop(library.tools.maxSlots)
fs.delete("/.save")