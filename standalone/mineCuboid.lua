local timeout = 5
local hasWireless = false
local coords = {x = 0, y = 0,z = 0}
local maxSlots = 16
local slot = 1
local tArgs = {...}

local fuelList = {
	"minecraft:coal",
	"minecraft:coal_block",
	"minecraft:charcoal",
	"mekanism:block_charcoal",
	"minecraft:lava_bucket",
}

function copyTable(tbl)
	if type(tbl) ~= "table" then
		error("The type of 'tbl' is not a table",2)
	end
	local rtbl = {}
	for k,v in pairs(tbl) do
		rtbl[k] = v
	end
	return rtbl
end

function saveData(dir, path, tbl)
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

function refuel()
	for index, value in ipairs(fuelList) do
		if findItem(tostring(value)) then
			while turtle.getItemCount(slot) >= 1 and turtle.getFuelLevel() < turtle.getFuelLimit() do
				turtle.refuel()
			end
			return true
		end
	end
	return false
end

function turnLeft()
	turtle.turnLeft()
	data.d = (data.d - 1) % 4
	data.saveData("/.save", "/face", {d = data.d})
end

function turnRight()
	turtle.turnRight()
	data.d = (data.d + 1) % 4
	data.saveData("/.save", "/face", {d = data.d})
end

function turnAround()
	turtle.turnRight()
	turtle.turnRight()
	data.d = (data.d + 2) % 4
	data.saveData("/.save", "/face", {d = data.d})
end

function face(direction)
	if type(direction) == "number" or "string" then
		if type(direction) == "string" then
			for k,v in pairs(data.direction) do
				if v == direction then
					direction = k
					break
				end
			end
		end
		if direction == (data.d + 2) % 4 then
			turnAround()
			return true
		elseif direction == (data.d - 1) % 4 then
			turnLeft()
			return true
		elseif direction == (data.d + 1) % 4 then
			turnRight()
			return true
		elseif direction == data.d then
			return true
		end
	end
	error("the type of 'direction' is not of type number, string or is invalid")
end

function forward(times)
	if times == nil then
		times = 1
	end
	if times < 0 then
		backward(-times)
	end
	for i=1, times do
		if not refuel() and turtle.getFuelLevel() == 0 then
			while not refuel() do
				term.clear()
				term.setCursorPos(1,1)
				print("Out of fuel!")
				if hasWireless == true then
					rednet.broadcast("Out of fuel at X: "..data.coords.x.." Y: "..data.coords.y.." Z: "..data.coords.z)
				end
				os.sleep(timeout)
			end
		end
		while not turtle.forward() do
			local inspect = {turtle.inspect()}
			if inspect[1] and inspect[2].name == "minecraft:bedrock" then
				return false
			elseif inspect[1] and inspect[2].name ~= "minecraft:bedrock" then
				while turtle.detect() do
					dig()
				end
			else
				turtle.attack()
			end
		end
		if data.d == 0 then
			data.coords.z = data.coords.z - 1
		elseif data.d == 1 then
			data.coords.x = data.coords.x + 1
		elseif data.d == 2 then
			data.coords.z = data.coords.z + 1
		elseif data.d == 3 then
			data.coords.x = data.coords.x - 1
		end
		data.saveData("/.save", "/position", data.coords)
	end
	return true
end

function backward(times)
	if times == nil then
		times = 1
	end
	if times < 0 then
		forward(-times)
	end
	for i=1, times do
		if not refuel() and turtle.getFuelLevel() == 0 then
			while not refuel() do
				term.clear()
				term.setCursorPos(1,1)
				print("Out of fuel!")
				if hasWireless == true then
					rednet.broadcast("Out of fuel at X: "..data.coords.x.." Y: "..data.coords.y.." Z: "..data.coords.z)
				end
				os.sleep(timeout)
			end
		end
		turtle.back()
		if data.d == 0 then
			data.coords.z = data.coords.z + 1
		elseif data.d == 1 then
			data.coords.x = data.coords.x - 1
		elseif data.d == 2 then
			data.coords.z = data.coords.z - 1
		elseif data.d == 3 then
			data.coords.x = data.coords.x + 1
		end
		data.saveData("/.save", "/position", data.coords)
	end
end

function up(times)
	if times == nil then
		times = 1
	end
	if times < 0 then
		data.down(-times)
	end
	for i=1, times do
		if not downfuel() and turtle.getFuelLevel() == 0 then
			while not refuel() do
				term.clear()
				term.setCursorPos(1,1)
				print("Out of fuel")
				if data.hasWireless == true then
					rednet.broadcast("Out of fuel at X: "..data.coords.x.." Y: "..data.coords.y.." Z: "..data.coords.z)
				end
				os.sleep(data.timeout)
			end
		end
		while not turtle.up() do
			local inspect = {turtle.inspectUp()}
			if inspect[1] and inspect[2].name == "minecraft:bedrock" then
				return false
			elseif inspect[1] and inspect[2].name ~= "minecraft:bedrock" then
				dig("up")
			else
				turtle.attackUp()
			end
		end
		data.coords.y = data.coords.y + 1
		data.saveData("/.save", "/position", data.coords)
	end
	return true
end

function down(times)
	if times == nil then
		times = 1
	end
	if times < 0 then
		up(-times)
	end
	for i=1, times do
		if not refuel() and turtle.getFuelLevel() == 0 then
			while not refuel() do
				term.clear()
				term.setCursorPos(1,1)
				print("Out of fuel")
				if data.hasWireless == true then
					rednet.broadcast("Out of fuel at X: "..data.coords.x.." Y: "..data.coords.y.." Z: "..data.coords.z)
				end
				os.sleep(data.timeout)
			end
		end
		while not turtle.down() do
			local inspect = {turtle.inspectDown()}
			if inspect[1] and inspect[2].name == "minecraft:bedrock" then
				return false
			elseif inspect[1] and inspect[2].name ~= "minecraft:bedrock" then
				dig("down")
			else
				turtle.attackDown()
			end
		end
		data.coords.y = data.coords.y - 1
		data.saveData("/.save", "/position", data.coords)
	end
	return true
end

function moveTo(x, y, z)
	if x == "~" then
		x = data.coords.x
	end
	if y == "~" then
		y = data.coords.y
	end
	if z == "~" then
		z = data.coords.z
	end
	if y > data.coords.y then
		up(y - data.coords.y)
	end
	if x < data.coords.x then
		face(3)
		forward(data.coords.x - x)
	elseif x > data.coords.x then
		face(1)
		forward(x - data.coords.x)
	end
	if z < data.coords.z then
		face(0)
		forward(data.coords.z - z)
	elseif z > data.coords.z then
		face(2)
		forward(z - data.coords.z)
	end
	if y < data.coords.y then
		down(data.coords.y - y)
	end
end

function drop(slots)
	local inspect, datai = turtle.inspect()
	if datai.name == "minecraft:chest" then
		for i=1, slots do
			turtle.select(i)
			turtle.drop()
		end
		turtle.select(1)
	else
		return false
	end
end

function findItem(name)
	for i=1, maxSlots do
		if turtle.getItemCount(i) ~= 0 then
			local item = turtle.getItemDetail(i).name
			if item == name then
				turtle.select(i)
				slot = tonumber(i)
				return true
			end
		end
	end
	return false
end

function dig(direction)
	if direction == nil then
		turtle.dig()
		os.sleep(0.4)
	elseif direction == "up" then
		turtle.digUp()
		os.sleep(0.4)
	elseif direction == "down" then
		turtle.digDown()
		os.sleep(0.4)
	end
end

function inventorySort()
	local inv = {}
	for i=1, maxSlots do
		inv[i] = turtle.getItemDetail(i)
	end
	for i=1, maxSlots do
		if inv[i] and inv[i].count < 64 then
		for j=(i+1), maxSlots do
			if inv[j] and inv[i].name == inv[j].name then
				if turtle.getItemSpace(i) == 0 then
					break
				end
				turtle.select(j)
				slot = j
				local count = turtle.getItemSpace(i)
				if count > inv[j].count then
					count = inv[j].count
				end
				turtle.transferTo(i, count)
				inv[i].count = inv[i].count + count
				inv[j].count = inv[j].count - count
				if inv[j].count <= 0 then
					inv[j] = nil
			end
			end
		end
		end
	end
	for i=1, maxSlots do
		if not inv[i] then
			for j=(i+1), maxSlots do
				if inv[j] then
				turtle.select(j)
				slot = j
				turtle.transferTo(i)
				inv[i] = data.copyTable(inv[j])
				inv[j] = nil
				break
				end
			end
		end
	end
	turtle.select(1)
	slot = 1
end

function dropJunk()
	for i=1, maxSlots do
		if turtle.getItemCount(i) ~= 0 then
			local item = turtle.getItemDetail(i).name
			local isJunk = false
			for index, value in ipairs(junkList) do
				if item == value then
					isJunk = true
					break
				end
			end
			if isJunk then
				turtle.select(i)
				slot = tonumber(i)
				turtle.dropUp()
			end
		end
	end
	inventorySort()
end

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
	if not refuel() and currentFuelLevel < requiredFuelLevel then
		while not refuel() do
			term.clear()
			term.setCursorPos(1,1)
			print("Not enough Fuel! "..currentFuelLevel.."/"..requiredFuelLevel)
			print("Place fuel into inventory!")
			os.sleep(timeout)
		end
		term.clear()
		term.setCursorPos(1,1)
	end
	if side == "left" or side == tostring(nil) then
		up()
		for x=1, depth do
			forward()
			dig("up")
			dig("down")
		if x % 3 == 0 and lastRowCount % 2 == 1 then
			turnLeft()
		else
		if lastRowCount % 2 == 0 then
			turnLeft()
		else
			turnRight()
		end
		end
		for z=1, rows do
			for y=1, width - 1 do
				forward()
				dig("up")
				dig("down")
			end
			lastRowCount = z
			if z ~= rows then
				if x % 2 == 0 then
					down(3)
					dig("down")
					move.turnAround()
				else
					up(3)
					dig("up")
					turnAround()
				end
			elseif offset ~= 0 then
				if x % 2 == 0 then
					down(offset)
					dig("down")
					turnAround()
				else
					up(offset)
					dig("up")
					turnAround()
				end
				for y=1, width - 1 do
					forward()
					if x % 2 == 0 then
						dig("down")
					else
						dig("up")
					end
				end
				lastRowCount = z + 1
			end
		end
		if x % 3 == 2 and lastRowCount % 2 == 1 then
			turnLeft()
		else
			if lastRowCount % 2 == 0 then
				turnLeft()
			else
				turnRight()
			end
		end
		dropJunk()
		end
	elseif side == "right" then
		up()
		for x=1, depth do
			forward()
			dig("up")
			dig("down")
		if x % 3 == 0 and lastRowCount % 2 == 1 then
			turnRight()
		else
		if lastRowCount % 2 == 0 then
			turnRight()
		else
			turnLeft()
		end
		end
		for z=1, rows do
			for y=1, width - 1 do
				forward()
				dig("up")
				dig("down")
			end
			lastRowCount = z
			if z ~= rows then
				if x % 2 == 0 then
					down(3)
					dig("down")
					move.turnAround()
				else
					up(3)
					dig("up")
					turnAround()
				end
			elseif offset ~= 0 then
				if x % 2 == 0 then
					down(offset)
					dig("down")
					turnAround()
				else
					up(offset)
					dig("up")
						turnAround()
				end
				for y=1, width - 1 do
					forward()
					if x % 2 == 0 then
						dig("down")
					else
						dig("up")
					end
				end
				lastRowCount = z + 1
			end
		end
		if x % 3 == 2 and lastRowCount % 2 == 1 then
			turnRight()
		else
			if lastRowCount % 2 == 0 then
				turnRight()
			else
				turnLeft()
			end
		end
		dropJunk()
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

local start = copyTable(coords)
saveData("/.save", "/start_pos", start)
mineSquence(tonumber(tArgs[1]), tonumber(tArgs[2]), tonumber(tArgs[3]), (tostring(tArgs[4])))
moveTo("~",start.y + 1,"~")
moveTo(start.x, start.y, start.z)
drop(maxSlots)
fs.delete("/.save")