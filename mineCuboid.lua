local data = require("dataAPI")
local move = require("moveAPI")
local storage = require("storageAPI")
local tools = require("toolsAPI")
local tArgs = {...}

function checkFuelLevel(width, height, depth)
	local requiredFuelLevel = math.ceil(((height * width * depth) / 3) + (height * depth) + ((width * 2) + depth + height))
	local currentFuelLevel = tonumber(turtle.getFuelLevel())
	if currentFuelLevel < requiredFuelLevel then
		while not move.refuel() and currentFuelLevel < requiredFuelLevel do
			term.clear()
			term.setCursorPos(1,1)
			print("Not enough Fuel! "..currentFuelLevel.."/"..requiredFuelLevel)
			print("Place fuel into inventory!")
		end
	else
		return true
	end
end

function mineSquence(width, height, depth)
	local rows = math.floor(height / 3)
	local offset = height % 3
	local lastRowCount = 0
	if width % 2 == 0 then
		term.clear()
		term.setCursorPos(1,1)
		error("Width needs to be an odd #!")
	elseif not checkFuelLevel(width, height, depth) then
		return
	end
	move.turnLeft()
	move.forward(width)
	move.turnRight()
	move.up()
	for x=1,depth do
		move.forward()
		tools.dig("up")
		tools.dig("down")
		if x % 3 == 0 and lastRowCount % 2 == 1 then
		move.turnRight()
		else
		if lastRowCount % 2 == 0 then
			move.turnRight()
		else
			move.turnLeft()
		end
		end
		for z=1,rows do
			for y=1,width - 1 do
				move.forward()
				tools.dig("up")
				tools.dig("down")
			end
			lastRowCount = z
			if z ~= rows then
				if x % 2 == 0 then
					move.down(3)
					tools.dig("down")
					tools.turnAround()
				else
					move.up(3)
					tools.dig("up")
					move.turnAround()
				end
			elseif offset ~= 0 then
				if x % 2 == 0 then
					move.down(offset)
					tools.dig("down")
					move.turnAround()
			else
				move.up(offset)
				tools.dig("up")
				move.turnAround()
			end
			for y=1,width - 1 do
				move.forward()
				if x % 2 == 0 then
					tools.dig("down")
				else
					tools.dig("up")
				end
			end
			lastRowCount = z + 1
		end
	end
	if x % 3 == 2 and lastRowCount % 2 == 1 then
		move.turnRight()
	else
		if lastRowCount % 2 == 0 then
			move.turnRight()
		else
			move.turnLeft()
		end
	end
	tools.dropJunk()
	end
	move.moveTo("~",start.y + 1,"~")
end

if type(tonumber(tArgs[1])) and type(tonumber(tArgs[2])) and type(tonumber(tArgs[3])) ~= "number" then
	term.clear()
	term.setCursorPos(1,1)
	error("Width, height and depth are required (Example: '5 5 10') [5 blocks wide, 5 block heigh and 10 blocks deep]")
end

local start = data.copyTable(data.coords)
data.saveData("/.save", "/start_pos", start)
mineSquence(tonumber(tArgs[1]), tonumber(tArgs[2]), tonumber(tArgs[3]))
move.moveTo(start.x, start.y, start.z)
storage.drop(tools.maxSlots)
fs.delete("/.save")