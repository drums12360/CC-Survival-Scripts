local tArgs = {...}

local api = {
	timeout = 5,
	d = 0,
	hasWireless = false,
	direction = {[0] = "north", [1] = "east", [2] = "south", [3] = "west"},
	coords = {x = 0, y = 0,z = 0}
	maxSlots = 16,
	slot = 1,
}

local stack = {}

local inverter = {
	["forward"] = api.backward,
	["back"] = api.forward,
	["turnLeft"] = api.turnRight,
	["turnRight"] = api.turnLeft,
	["up"] = api.down,
	["down"] = api.up,
}

local converter = {
	["forward"] = api.forward,
	["back"] = api.backward,
	["turnLeft"] = api.turnLeft,
	["turnRight"] = api.turnRight,
	["up"] = api.up,
	["down"] = api.down,
}

local oreList = {
	"minecraft:iron_ore",
	"minecraft:coal_ore",
	"minecraft:gold_ore",
	"minecraft:diamond_ore",
	"minecraft:emerald_ore",
	"minecraft:copper_ore",
	"minecraft:lapis_ore",
	"minecraft:redstone_ore",
	"minecraft:deepslate_iron_ore",
	"minecraft:deepslate_coal_ore",
	"minecraft:deepslate_gold_ore",
	"minecraft:deepslate_diamond_ore",
	"minecraft:deepslate_emerald_ore",
	"minecraft:deepslate_copper_ore",
	"minecraft:deepslate_lapis_ore",
	"minecraft:deepslate_redstone_ore",
	"minecraft:nether_gold_ore",
	"minecraft:nether_quartz_ore",
	"minecraft:obsidian",
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

function api.copyTable(tbl)
	if type(tbl) ~= "table" then
		error("The type of 'tbl' is not a table",2)
	end
	local rtbl = {}
	for k,v in pairs(tbl) do
		rtbl[k] = v
	end
	return rtbl
end

function api.saveData(dir, path, tbl)
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

function api.loadData(dir, path)
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

function api.findItem(name)
	for i=1, api.maxSlots do
		if turtle.getItemCount(i) ~= 0 then
			local item = turtle.getItemDetail(i).name
			if item == name then
				turtle.select(i)
				api.slot = tonumber(i)
				return true
			end
		end
	end
	return false
end

function api.inventorySort()
	local inv = {}
	for i=1, api.maxSlots do
		inv[i] = turtle.getItemDetail(i)
	end
	for i=1, api.maxSlots do
		if inv[i] and inv[i].count < 64 then
		for j=(i+1), api.maxSlots do
			if inv[j] and inv[i].name == inv[j].name then
				if turtle.getItemSpace(i) == 0 then
					break
				end
				turtle.select(j)
				api.slot = j
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
	for i=1, api.maxSlots do
		if not inv[i] then
			for j=(i+1), api.maxSlots do
				if inv[j] then
				turtle.select(j)
				api.slot = j
				turtle.transferTo(i)
				inv[i] = api.copyTable(inv[j])
				inv[j] = nil
				break
				end
			end
		end
	end
	turtle.select(1)
	api.slot = 1
end


function api.place(blockName, direction)
	api.findItem(blockName)
	if direction == nil then
		turtle.place()
	elseif direction == "up" then
		turtle.placeUp()
	elseif direction == "down" then
		turtle.placeDown()
	end
end

function api.dig(direction)
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

function api.dropJunk()
	for i=1, api.maxSlots do
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
				api.slot = tonumber(i)
				turtle.dropUp()
			end
		end
	end
	api.inventorySort()
end

function api.findJunk(exclude)
	if exclude == nil then
		exclude = "nothing"
	end
	for i=1, api.maxSlots do
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
				api.slot = tonumber(i)
				return true
			end
		end
	end
	return false
end

function api.refuel()
	for index, value in ipairs(fuelList) do
		if api.findItem(tostring(value)) then
			while turtle.getItemCount(api.slot) >= 1 and turtle.getFuelLevel() < turtle.getFuelLimit() do
				turtle.refuel()
			end
			return true
		end
	end
	return false
end

function api.turnLeft()
	turtle.turnLeft()
	api.d = (api.d - 1) % 4
	api.saveData("/.save", "/face", {d = api.d})
end

function api.turnRight()
	turtle.turnRight()
	api.d = (api.d + 1) % 4
	api.saveData("/.save", "/face", {d = api.d})
end

function api.turnAround()
	turtle.turnRight()
	turtle.turnRight()
	api.d = (api.d + 2) % 4
	api.saveData("/.save", "/face", {d = api.d})
end

function api.face(direction)
	if type(direction) == "number" or "string" then
		if type(direction) == "string" then
			for k,v in pairs(api.direction) do
				if v == direction then
					direction = k
					break
				end
			end
		end
		if direction == (api.d + 2) % 4 then
			api.turnAround()
			return true
		elseif direction == (api.d - 1) % 4 then
			api.turnLeft()
			return true
		elseif direction == (api.d + 1) % 4 then
			api.turnRight()
			return true
		elseif direction == api.d then
			return true
		end
	end
	error("the type of 'direction' is not of type number, string or is invalid")
end

function api.forward(times)
	if times == nil then
		times = 1
	end
	if times < 0 then
		api.backward(-times)
	end
	for i=1, times do
		if not api.refuel() and turtle.getFuelLevel() == 0 then
			while not api.refuel() do
				term.clear()
				term.setCursorPos(1,1)
				print("Out of fuel!")
				if api.hasWireless == true then
					rednet.broadcast("Out of fuel at X: "..api.coords.x.." Y: "..api.coords.y.." Z: "..api.coords.z)
				end
				os.sleep(api.timeout)
			end
		end
		while not turtle.forward() do
			local inspect = {turtle.inspect()}
			if inspect[1] and inspect[2].name == "minecraft:bedrock" then
				return false
			elseif inspect[1] and inspect[2].name ~= "minecraft:bedrock" then
				while turtle.detect() do
					api.dig()
				end
			else
				turtle.attack()
			end
		end
		if api.d == 0 then
			api.coords.z = api.coords.z - 1
		elseif api.d == 1 then
			api.coords.x = api.coords.x + 1
		elseif api.d == 2 then
			api.coords.z = api.coords.z + 1
		elseif api.d == 3 then
			api.coords.x = api.coords.x - 1
		end
		api.saveData("/.save", "/position", api.coords)
	end
	return true
end

function api.left(times)
	api.turnLeft()
	api.forward(times)
	api.turnRight()
end

function api.right(times)
	api.turnRight()
	api.forward(times)
	api.turnLeft()
end

function api.backward(times)
	if times == nil then
		times = 1
	end
	if times < 0 then
		api.forward(-times)
	end
	for i=1, times do
		if not api.refuel() and turtle.getFuelLevel() == 0 then
			while not api.refuel() do
				term.clear()
				term.setCursorPos(1,1)
				print("Out of fuel!")
				if api.hasWireless == true then
					rednet.broadcast("Out of fuel at X: "..api.coords.x.." Y: "..api.coords.y.." Z: "..api.coords.z)
				end
				os.sleep(api.timeout)
			end
		end
		turtle.back()
		if api.d == 0 then
			api.coords.z = api.coords.z + 1
		elseif api.d == 1 then
			api.coords.x = api.coords.x - 1
		elseif api.d == 2 then
			api.coords.z = api.coords.z - 1
		elseif api.d == 3 then
			api.coords.x = api.coords.x + 1
		end
		api.saveData("/.save", "/position", api.coords)
	end
end

function api.up(times)
	if times == nil then
		times = 1
	end
	if times < 0 then
		api.down(-times)
	end
	for i=1, times do
		if not api.refuel() and turtle.getFuelLevel() == 0 then
			while not api.refuel() do
				term.clear()
				term.setCursorPos(1,1)
				print("Out of fuel")
				if api.hasWireless == true then
					rednet.broadcast("Out of fuel at X: "..api.coords.x.." Y: "..api.coords.y.." Z: "..api.coords.z)
				end
				os.sleep(api.timeout)
			end
		end
		while not turtle.up() do
			local inspect = {turtle.inspectUp()}
			if inspect[1] and inspect[2].name == "minecraft:bedrock" then
				return false
			elseif inspect[1] and inspect[2].name ~= "minecraft:bedrock" then
				api.dig("up")
			else
				turtle.attackUp()
			end
		end
		api.coords.y = api.coords.y + 1
		api.saveData("/.save", "/position", api.coords)
	end
	return true
end

function api.down(times)
	if times == nil then
		times = 1
	end
	if times < 0 then
		api.up(-times)
	end
	for i=1, times do
		if not api.refuel() and turtle.getFuelLevel() == 0 then
			while not api.refuel() do
				term.clear()
				term.setCursorPos(1,1)
				print("Out of fuel")
				if api.hasWireless == true then
					rednet.broadcast("Out of fuel at X: "..api.coords.x.." Y: "..api.coords.y.." Z: "..api.coords.z)
				end
				os.sleep(api.timeout)
			end
		end
		while not turtle.down() do
			local inspect = {turtle.inspectDown()}
			if inspect[1] and inspect[2].name == "minecraft:bedrock" then
				return false
			elseif inspect[1] and inspect[2].name ~= "minecraft:bedrock" then
				api.dig("down")
			else
				turtle.attackDown()
			end
		end
		api.coords.y = api.coords.y - 1
		api.saveData("/.save", "/position", api.coords)
	end
	return true
end

function api.moveTo(x, y, z)
	if x == "~" then
		x = api.coords.x
	end
	if y == "~" then
		y = api.coords.y
	end
	if z == "~" then
		z = api.coords.z
	end
	if y > api.coords.y then
		api.up(y - api.coords.y)
	end
	if x < api.coords.x then
		api.face(3)
		api.forward(api.coords.x - x)
	elseif x > api.coords.x then
		api.face(1)
		api.forward(x - api.coords.x)
	end
	if z < api.coords.z then
		api.face(0)
		api.forward(api.coords.z - z)
	elseif z > api.coords.z then
		api.face(2)
		api.forward(z - api.coords.z)
	end
	if y < api.coords.y then
		api.down(api.coords.y - y)
	end
end

function api.drop(slots)
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

function api.avoidChest()
	local chest = {}
	local inspect, datai = turtle.inspect()
	if datai.name == "minecraft:chest" then
		chest[1] = true
		api.saveData("/.save", "/chest", chest)
		api.turnAround()
	else
		chest[1] = false
		api.saveData("/.save", "/chest", chest)
	end
end

function api.emptyInv()
	local start = api.loadData("/.save", "/start_pos")
	if turtle.getItemCount(15) > 0 then
		local mining = api.copyTable(api.coords)
		api.moveTo(start.x, start.y, start.z)
		api.drop(15)
		turtle.select(1)
		api.moveTo(mining.x, mining.y, mining.z)
	end
end

function api.waitforemptyInv()
	local start = api.loadData("/.save", "/start_pos")
	if turtle.getItemCount(15) > 0 then
		local mining = api.copyTable(api.coords)
		api.moveTo(start.x, start.y, start.z)
		turtle.select(1)
		term.clear()
		term.setCursorPos(1,1)
		print("Press any key after emptying!")
		os.pullEvent("key")
		api.moveTo(mining.x, mining.y, mining.z)
	end
end

function api.stackPop()
	local func = inverter[stack[#stack]]
	table.remove(stack)
	return func()
end

function api.checkOreTable(tbl)
	if type(tbl) ~= "table" then
		error("'tbl' is not of type table", 2)
	end
	if tbl[1] == true then
		for k,v in pairs(oreList) do
			if tbl[2].name == oreList[k] then
				return true
			end
		end
	else
		return false
	end
end

function api.veinMine(lastFunc)
	if type(lastFunc) == "function" or "string" then
		if type(lastFunc) == "function" then
			for k,v in pairs(converter) do
				if v == lastFunc then
					table.insert(stack, k)
					break
				end
			end
		end
		if api.checkOreTable({turtle.inspectUp()}) then
			api.up()
			return api.veinMine(api.up)
		elseif api.checkOreTable({turtle.inspectDown()}) then
			api.down()
			return api.veinMine(api.down)
		end
		for i=1, 4 do
			if api.checkOreTable({turtle.inspect()}) then
				if i == 1 then
					api.forward()
					return api.veinMine(api.forward)
				elseif i == 2 then
					return api.veinMine(api.turnLeft)
				elseif i == 3 then
					table.insert(stack, "turnLeft")
					return api.veinMine(api.turnLeft)
				elseif i == 4 then
					return api.veinMine(api.turnRight)
				end
			end
			api.turnLeft()
		end
		if stack[#stack] == "turnLeft" then
			if stack[#stack] == stack[#stack-1] then
				api.stackPop()
				api.stackPop()
				lastFunc = stack[#stack]
				if #stack > 0 then
					return api.veinMine(lastFunc)
				end
				return
			else
				api.stackPop()
				lastFunc = stack[#stack]
				if #stack > 0 then
					return api.veinMine(lastFunc)
				end
				return
			end
		else
			api.stackPop()
			lastFunc = stack[#stack]
			if #stack > 0 then
				return api.veinMine(lastFunc)
			end
			return
		end
	else
		error("'lastFunc' is not of type function or string", 2)
	end
end

function api.checkForOre(value)
	if api.checkOreTable({turtle.inspectUp()}) then
		api.up()
		api.veinMine(api.up)
	end
	if api.checkOreTable({turtle.inspectDown()}) then
		api.down()
		api.veinMine(api.down)
	end
	api.turnLeft()
	if api.checkOreTable({turtle.inspect()}) then
		api.forward()
		api.veinMine(api.forward)
	end
	api.turnAround()
	if api.checkOreTable({turtle.inspect()}) then
		api.forward()
		api.veinMine(api.forward)
	end
	if value == "back_true" then
		api.turnRight()
		if api.checkOreTable({turtle.inspect()}) then
			api.forward()
			api.veinMine(api.forward)
		end
		api.turnAround()
		if api.checkOreTable({turtle.inspect()}) then
			api.forward()
			api.veinMine(api.forward)
		end
	else
		api.turnLeft()
		if api.checkOreTable({turtle.inspect()}) then
			api.forward()
			api.veinMine(api.forward)
		end
	end
	return true
end

function mineSquence(amount)
	for i=1, amount do
		api.forward()
		api.checkForOre()
		api.dig("up")
		if api.loadData("/.save", "/chest")[1] == true then
			api.emptyInv()
		elseif api.loadData("/.save", "/chest")[1] == false then
			api.waitforemptyInv()
		end
	end
end

function returnSquence(amount)
	local moves = amount
	if turtle.getItemCount(16) ~= 0 then
		if turtle.getItemDetail(16).name ~= "minecraft:torch" then
			return false
		elseif turtle.getItemDetail(16).name == "minecraft:torch" and amount >= 4 then
			turtle.select(16)
			api.up()
			api.backward()
			turtle.place()
			moves = moves - 1
			while moves >= 12 and turtle.getItemCount(16) ~= 0 do
				api.turnAround()
				api.forward(12)
				api.turnAround()
				turtle.place()
				moves = moves - 12
			end
		end
	else
		term.clear()
		print("No torches in slot 16!")
	end
end

if type(tonumber(tArgs[1])) ~= "number" then
	term.clear()
	term.setCursorPos(1,1)
	error("Define tunnel lenght! (Example: '10') [10 block long]")
end

local start = api.copyTable(api.coords)
api.saveData("/.save", "/start_pos", start)
api.avoidChest()
mineSquence(tonumber(tArgs[1]))
returnSquence(tonumber(tArgs[1])-1)
api.moveTo(start.x, start.y, start.z)
api.drop(api.maxSlots)
fs.delete("/.save")