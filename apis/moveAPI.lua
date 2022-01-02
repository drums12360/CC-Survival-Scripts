local data = require("dataAPI")
local tools = require("toolsAPI")

local move = {
	
}

function move.turnLeft()
	turtle.turnLeft()
	data.d = (data.d - 1) % 4
	data.saveData("/.save", "/face", {d = data.d})
end

function move.turnRight()
	turtle.turnRight()
	data.d = (data.d + 1) % 4
	data.saveData("/.save", "/face", {d = data.d})
end

function move.turnAround()
	turtle.turnRight()
	turtle.turnRight()
	data.d = (data.d + 2) % 4
	data.saveData("/.save", "/face", {d = data.d})
end

function move.face(direction)
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
			move.turnAround()
			return true
		elseif direction == (data.d - 1) % 4 then
			move.turnLeft()
			return true
		elseif direction == (data.d + 1) % 4 then
			move.turnRight()
			return true
		elseif direction == data.d then
			return true
		end
	end
	error("the type of 'direction' is not of type number, string or is invalid")
end

function move.forward(times)
	if times == nil then
		times = 1
	end
	if times < 0 then
		move.backward(-times)
	end
	for i=1, times do
		if not tools.refuel() and turtle.getFuelLevel() == 0 then
			while not tools.refuel() do
				term.clear()
				term.setCursorPos(1,1)
				print("Out of fuel!")
				if data.hasWireless == true then
					rednet.broadcast("Out of Fuel at X: "..data.coords.x.." Y: "..data.coords.y.." Z: "..data.coords.z)
				end
				os.sleep(data.timeout)
			end
		elseif turtle.getFuelLevel() <= 10 then
			tools.refuel()
		end
		while not turtle.forward() do
			local inspect = {turtle.inspect()}
			if inspect[1] and inspect[2].name == "minecraft:bedrock" then
				return false
			elseif inspect[1] and inspect[2].name ~= "minecraft:bedrock" then
				while turtle.detect() do
					turtle.dig()
					os.sleep(0.4)
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

function move.left(times)
	move.turnLeft()
	move.forward(times)
	move.turnRight()
end

function move.right(times)
	move.turnRight()
	move.forward(times)
	move.turnLeft()
end

function move.backward(times)
	if times == nil then
		times = 1
	end
	if times < 0 then
		move.forward(-times)
	end
	for i=1, times do
		if not tools.refuel() and turtle.getFuelLevel() == 0 then
			while not tools.refuel() do
				term.clear()
				term.setCursorPos(1,1)
				print("Out of fuel!")
				if data.hasWireless == true then
					rednet.broadcast("Out of Fuel at X: "..data.coords.x.." Y: "..data.coords.y.." Z: "..data.coords.z)
				end
				os.sleep(data.timeout)
			end
		elseif turtle.getFuelLevel() <= 10 then
			tools.refuel()
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

function move.up(times)
	if times == nil then
		times = 1
	end
	if times < 0 then
		data.down(-times)
	end
	for i=1, times do
		if not tools.refuel() and turtle.getFuelLevel() == 0 then
			while not tools.refuel() do
				term.clear()
				term.setCursorPos(1,1)
				print("Out of fuel")
				if data.hasWireless == true then
					rednet.broadcast("Out of Fuel at X: "..data.coords.x.." Y: "..data.coords.y.." Z: "..data.coords.z)
				end
				os.sleep(data.timeout)
			end
		elseif turtle.getFuelLevel() <= 10 then
			tools.refuel()
		end
		while not turtle.up() do 
			local inspect = {turtle.inspectUp()}
			if inspect[1] and inspect[2].name == "minecraft:bedrock" then
				return false
			elseif inspect[1] and inspect[2].name ~= "minecraft:bedrock" then
				turtle.digUp()
			else
				turtle.attackUp()
			end
		end
		data.coords.y = data.coords.y + 1
		data.saveData("/.save", "/position", data.coords)
	end
	return true
end

function move.down(times)
	if times == nil then
		times = 1
	end
	if times < 0 then
		move.up(-times)
	end
	for i=1, times do
		if not tools.refuel() and turtle.getFuelLevel() == 0 then
			while not tools.refuel() do
				term.clear()
				term.setCursorPos(1,1)
				print("Out of fuel")
				if data.hasWireless == true then
					rednet.broadcast("Out of Fuel at X: "..data.coords.x.." Y: "..data.coords.y.." Z: "..data.coords.z)
				end
				os.sleep(data.timeout)
			end
		elseif turtle.getFuelLevel() <= 10 then
			tools.refuel()
		end
		while not turtle.down() do 
			local inspect = {turtle.inspectDown()}
			if inspect[1] and inspect[2].name == "minecraft:bedrock" then
				return false
			elseif inspect[1] and inspect[2].name ~= "minecraft:bedrock" then
				turtle.digDown()
			else
				turtle.attackDown()
			end
		end
		data.coords.y = data.coords.y - 1
		data.saveData("/.save", "/position", data.coords)
	end
	return true
end

function move.moveTo(x, y, z)
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
		move.up(y - data.coords.y)
	end
	if x < data.coords.x then
		move.face(3)
		move.forward(data.coords.x - x)
	elseif x > data.coords.x then
		move.face(1)
		move.forward(x - data.coords.x)
	end
	if z < data.coords.z then
		move.face(0)
		move.forward(data.coords.z - z)
	elseif z > data.coords.z then
		move.face(2)
		move.forward(z - data.coords.z)
	end
	if y < data.coords.y then
		move.down(data.coords.y - y)
	end
end

return move