local tArgs = {...}

local lib = {
	timeout = 5,
	d = 0,
	hasWireless = false,
	direction = {[0] = "north", [1] = "east", [2] = "south", [3] = "west"},
	coords = {x = 0, y = 0,z = 0},
	maxSlots = 16,
	slot = 1,
}

local junkList = {
	"minecraft:dirt",
	"minecraft:gravel",
	"minecraft:cobblestone",
	"minecraft:cobbled_deepslate",
	"minecraft:tuff",
	"minecraft:andesite",
	"minecraft:diorite",
	"minecraft:granite",
}

local fuelList = {
	"minecraft:coal",
	"minecraft:coal_block",
	"minecraft:charcoal",
	"mekanism:block_charcoal",
	"minecraft:lava_bucket",
}

function lib.copyTable(tbl)
	if type(tbl) ~= "table" then
		error("The type of 'tbl' is not a table",2)
	end
	local rtbl = {}
	for k,v in pairs(tbl) do
		rtbl[k] = v
	end
	return rtbl
end

function lib.saveData(dir, path, tbl)
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

function lib.loadData(dir, path)
	if type(path) ~= "string" or type(dir) ~= "string" then
		error("The type of 'path' or 'dir' is not a string",2)
	end
	if fs.exists(dir) then
		local tbl = {}
		local f = fs.open(dir .. path, "r")
		tbl = f.readAll()
		tbl = textutils.unserialize(tbl)
		f.close()
		return tbl
	end
	return false
end

function lib.findItem(name)
	for i=1, lib.maxSlots do
		if turtle.getItemCount(i) ~= 0 then
			local item = turtle.getItemDetail(i).name
			if item == name then
				turtle.select(i)
				lib.slot = tonumber(i)
				return true
			end
		end
	end
	return false
end

function lib.inventorySort()
	local inv = {}
	for i=1, lib.maxSlots do
		inv[i] = turtle.getItemDetail(i)
	end
	for i=1, lib.maxSlots do
		if inv[i] and inv[i].count < 64 then
		for j=(i+1), lib.maxSlots do
			if inv[j] and inv[i].name == inv[j].name then
				if turtle.getItemSpace(i) == 0 then
					break
				end
				turtle.select(j)
				lib.slot = j
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
	for i=1, lib.maxSlots do
		if not inv[i] then
			for j=(i+1), lib.maxSlots do
				if inv[j] then
				turtle.select(j)
				lib.slot = j
				turtle.transferTo(i)
				inv[i] = lib.copyTable(inv[j])
				inv[j] = nil
				break
				end
			end
		end
	end
	turtle.select(1)
	lib.slot = 1
end


function lib.place(blockName, direction)
	lib.findItem(blockName)
	if direction == nil then
		turtle.place()
	elseif direction == "up" then
		turtle.placeUp()
	elseif direction == "down" then
		turtle.placeDown()
	end
end

function lib.dig(direction)
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

function lib.dropJunk()
	for i=1, lib.maxSlots do
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
				lib.slot = tonumber(i)
				turtle.dropUp()
			end
		end
	end
	lib.inventorySort()
end

function lib.findJunk(exclude)
	if exclude == nil then
		exclude = "nothing"
	end
	for i=1, lib.maxSlots do
		if turtle.getItemCount(i) ~= 0 then
			local item = turtle.getItemDetail(i).name
			local isJunk = false
			for index, value in ipairs(junkList) do
				if item == value and item ~= exclude then
					isJunk = true
					break
				end
			end
			if isJunk then
				turtle.select(i)
				lib.slot = tonumber(i)
				return true
			end
		end
	end
	return false
end

function lib.refuel()
	for index, value in ipairs(fuelList) do
		if lib.findItem(tostring(value)) then
			while turtle.getItemCount(lib.slot) >= 1 and turtle.getFuelLevel() < turtle.getFuelLimit() do
				turtle.refuel()
			end
			return true
		end
	end
	return false
end

function lib.turnLeft()
	turtle.turnLeft()
	lib.d = (lib.d - 1) % 4
	lib.saveData("/.save", "/face", {d = lib.d})
end

function lib.turnRight()
	turtle.turnRight()
	lib.d = (lib.d + 1) % 4
	lib.saveData("/.save", "/face", {d = lib.d})
end

function lib.turnAround()
	turtle.turnRight()
	turtle.turnRight()
	lib.d = (lib.d + 2) % 4
	lib.saveData("/.save", "/face", {d = lib.d})
end

function lib.face(direction)
	if type(direction) == "number" or "string" then
		if type(direction) == "string" then
			for k,v in pairs(lib.direction) do
				if v == direction then
					direction = k
					break
				end
			end
		end
		if direction == (lib.d + 2) % 4 then
			lib.turnAround()
			return true
		elseif direction == (lib.d - 1) % 4 then
			lib.turnLeft()
			return true
		elseif direction == (lib.d + 1) % 4 then
			lib.turnRight()
			return true
		elseif direction == lib.d then
			return true
		end
	end
	error("the type of 'direction' is not of type number, string or is invalid")
end

function lib.forward(times)
	if times == nil then
		times = 1
	end
	if times < 0 then
		lib.backward(-times)
	end
	for i=1, times do
		if not lib.refuel() and turtle.getFuelLevel() == 0 then
			while not lib.refuel() do
				term.clear()
				term.setCursorPos(1,1)
				print("Out of fuel!")
				if lib.hasWireless == true then
					rednet.broadcast("Out of fuel at X: "..lib.coords.x.." Y: "..lib.coords.y.." Z: "..lib.coords.z)
				end
				os.sleep(lib.timeout)
			end
		end
		while not turtle.forward() do
			local inspect = {turtle.inspect()}
			if inspect[1] and inspect[2].name == "minecraft:bedrock" then
				return false
			elseif inspect[1] and inspect[2].name ~= "minecraft:bedrock" then
				while turtle.detect() do
					lib.dig()
				end
			else
				turtle.attack()
			end
		end
		if lib.d == 0 then
			lib.coords.z = lib.coords.z - 1
		elseif lib.d == 1 then
			lib.coords.x = lib.coords.x + 1
		elseif lib.d == 2 then
			lib.coords.z = lib.coords.z + 1
		elseif lib.d == 3 then
			lib.coords.x = lib.coords.x - 1
		end
		lib.saveData("/.save", "/position", lib.coords)
	end
	return true
end

function lib.left(times)
	lib.turnLeft()
	lib.forward(times)
	lib.turnRight()
end

function lib.right(times)
	lib.turnRight()
	lib.forward(times)
	lib.turnLeft()
end

function lib.backward(times)
	if times == nil then
		times = 1
	end
	if times < 0 then
		lib.forward(-times)
	end
	for i=1, times do
		if not lib.refuel() and turtle.getFuelLevel() == 0 then
			while not lib.refuel() do
				term.clear()
				term.setCursorPos(1,1)
				print("Out of fuel!")
				if lib.hasWireless == true then
					rednet.broadcast("Out of fuel at X: "..lib.coords.x.." Y: "..lib.coords.y.." Z: "..lib.coords.z)
				end
				os.sleep(lib.timeout)
			end
		end
		turtle.back()
		if lib.d == 0 then
			lib.coords.z = lib.coords.z + 1
		elseif lib.d == 1 then
			lib.coords.x = lib.coords.x - 1
		elseif lib.d == 2 then
			lib.coords.z = lib.coords.z - 1
		elseif lib.d == 3 then
			lib.coords.x = lib.coords.x + 1
		end
		lib.saveData("/.save", "/position", lib.coords)
	end
end

function lib.up(times)
	if times == nil then
		times = 1
	end
	if times < 0 then
		lib.down(-times)
	end
	for i=1, times do
		if not lib.refuel() and turtle.getFuelLevel() == 0 then
			while not lib.refuel() do
				term.clear()
				term.setCursorPos(1,1)
				print("Out of fuel")
				if lib.hasWireless == true then
					rednet.broadcast("Out of fuel at X: "..lib.coords.x.." Y: "..lib.coords.y.." Z: "..lib.coords.z)
				end
				os.sleep(lib.timeout)
			end
		end
		while not turtle.up() do
			local inspect = {turtle.inspectUp()}
			if inspect[1] and inspect[2].name == "minecraft:bedrock" then
				return false
			elseif inspect[1] and inspect[2].name ~= "minecraft:bedrock" then
				lib.dig("up")
			else
				turtle.attackUp()
			end
		end
		lib.coords.y = lib.coords.y + 1
		lib.saveData("/.save", "/position", lib.coords)
	end
	return true
end

function lib.down(times)
	if times == nil then
		times = 1
	end
	if times < 0 then
		lib.up(-times)
	end
	for i=1, times do
		if not lib.refuel() and turtle.getFuelLevel() == 0 then
			while not lib.refuel() do
				term.clear()
				term.setCursorPos(1,1)
				print("Out of fuel")
				if lib.hasWireless == true then
					rednet.broadcast("Out of fuel at X: "..lib.coords.x.." Y: "..lib.coords.y.." Z: "..lib.coords.z)
				end
				os.sleep(lib.timeout)
			end
		end
		while not turtle.down() do
			local inspect = {turtle.inspectDown()}
			if inspect[1] and inspect[2].name == "minecraft:bedrock" then
				return false
			elseif inspect[1] and inspect[2].name ~= "minecraft:bedrock" then
				lib.dig("down")
			else
				turtle.attackDown()
			end
		end
		lib.coords.y = lib.coords.y - 1
		lib.saveData("/.save", "/position", lib.coords)
	end
	return true
end

function lib.moveTo(x, y, z)
	if x == "~" then
		x = lib.coords.x
	end
	if y == "~" then
		y = lib.coords.y
	end
	if z == "~" then
		z = lib.coords.z
	end
	if y > lib.coords.y then
		lib.up(y - lib.coords.y)
	end
	if x < lib.coords.x then
		lib.face(3)
		lib.forward(lib.coords.x - x)
	elseif x > lib.coords.x then
		lib.face(1)
		lib.forward(x - lib.coords.x)
	end
	if z < lib.coords.z then
		lib.face(0)
		lib.forward(lib.coords.z - z)
	elseif z > lib.coords.z then
		lib.face(2)
		lib.forward(z - lib.coords.z)
	end
	if y < lib.coords.y then
		lib.down(lib.coords.y - y)
	end
end

function lib.drop(slots)
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

function lib.avoidChest()
	local chest = {}
	local inspect, datai = turtle.inspect()
	if datai.name == "minecraft:chest" then
		chest[1] = true
		lib.saveData("/.save", "/chest", chest)
		lib.turnAround()
	else
		chest[1] = false
		lib.saveData("/.save", "/chest", chest)
	end
end

function lib.emptyInv()
	local start = lib.loadData("/.save", "/start_pos")
	if turtle.getItemCount(15) > 0 then
		local mining = lib.copyTable(lib.coords)
		lib.moveTo(start.x, start.y, start.z)
		lib.drop(15)
		turtle.select(1)
		lib.moveTo(mining.x, mining.y, mining.z)
	end
end

function lib.waitforemptyInv()
	local start = lib.loadData("/.save", "/start_pos")
	if turtle.getItemCount(15) > 0 then
		local mining = lib.copyTable(lib.coords)
		lib.moveTo(start.x, start.y, start.z)
		turtle.select(1)
		term.clear()
		term.setCursorPos(1,1)
		print("Press any key after emptying!")
		os.pullEvent("key")
		lib.moveTo(mining.x, mining.y, mining.z)
	end
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
	if not lib.refuel() and currentFuelLevel < requiredFuelLevel then
		while not lib.refuel() do
			term.clear()
			term.setCursorPos(1,1)
			print("Not enough Fuel! "..currentFuelLevel.."/"..requiredFuelLevel)
			print("Place fuel into inventory!")
			os.sleep(lib.timeout)
		end
		term.clear()
		term.setCursorPos(1,1)
	end
	if side == "left" or side == tostring(nil) then
		lib.up()
		for x=1, depth do
			lib.forward()
			lib.dig("up")
			lib.dig("down")
		if x % 3 == 0 and lastRowCount % 2 == 1 then
			lib.turnLeft()
		else
		if lastRowCount % 2 == 0 then
			lib.turnLeft()
		else
			lib.turnRight()
		end
		end
		for z=1, rows do
			for y=1, width - 1 do
				lib.forward()
				lib.dig("up")
				lib.dig("down")
			end
			lastRowCount = z
			if z ~= rows then
				if x % 2 == 0 then
					lib.down(3)
					lib.dig("down")
					lib.turnAround()
				else
					lib.up(3)
					lib.dig("up")
					lib.turnAround()
				end
			elseif offset ~= 0 then
				if x % 2 == 0 then
					lib.down(offset)
					lib.dig("down")
					lib.turnAround()
				else
					lib.up(offset)
					lib.dig("up")
					lib.turnAround()
				end
				for y=1, width - 1 do
					lib.forward()
					if x % 2 == 0 then
						lib.dig("down")
					else
						lib.dig("up")
					end
				end
				lastRowCount = z + 1
			end
		end
		if x % 3 == 2 and lastRowCount % 2 == 1 then
			lib.turnLeft()
		else
			if lastRowCount % 2 == 0 then
				lib.turnLeft()
			else
				lib.turnRight()
			end
		end
		lib.dropJunk()
		end
	elseif side == "right" then
		lib.up()
		for x=1, depth do
			lib.forward()
			lib.dig("up")
			lib.dig("down")
		if x % 3 == 0 and lastRowCount % 2 == 1 then
			lib.turnRight()
		else
		if lastRowCount % 2 == 0 then
			lib.turnRight()
		else
			lib.turnLeft()
		end
		end
		for z=1, rows do
			for y=1, width - 1 do
				lib.forward()
				lib.dig("up")
				lib.dig("down")
			end
			lastRowCount = z
			if z ~= rows then
				if x % 2 == 0 then
					lib.down(3)
					lib.dig("down")
					lib.turnAround()
				else
					lib.up(3)
					lib.dig("up")
					lib.turnAround()
				end
			elseif offset ~= 0 then
				if x % 2 == 0 then
					lib.down(offset)
					lib.dig("down")
					lib.turnAround()
				else
					lib.up(offset)
					lib.dig("up")
						lib.turnAround()
				end
				for y=1, width - 1 do
					lib.forward()
					if x % 2 == 0 then
						lib.dig("down")
					else
						lib.dig("up")
					end
				end
				lastRowCount = z + 1
			end
		end
		if x % 3 == 2 and lastRowCount % 2 == 1 then
			lib.turnRight()
		else
			if lastRowCount % 2 == 0 then
				lib.turnRight()
			else
				lib.turnLeft()
			end
		end
		lib.dropJunk()
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

local start = lib.copyTable(lib.coords)
lib.saveData("/.save", "/start_pos", start)
mineSquence(tonumber(tArgs[1]), tonumber(tArgs[2]), tonumber(tArgs[3]), (tostring(tArgs[4])))
lib.moveTo("~",start.y + 1,"~")
lib.moveTo(start.x, start.y, start.z)
lib.drop(lib.maxSlots)
fs.delete("/.save")