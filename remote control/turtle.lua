if peripheral.find("modem") then
	peripheral.find("modem", rednet.open)
else
	return
end
local controllerID = nil
local turtleID = os.getComputerID()
local currentStatus = nil
local alias = os.getComputerLabel()
local reply = {
	busy = "busy",
	done = "done",
	ready = "ready",
	running = "running",
}

function getAlias()
	
end

function setAlias()
	
end

function connect()

end

function disconnect()
	
end

local converter = {
	["forward"] = turtle.forward,
	["back"] = turtle.backward,
	["turnLeft"] = turtle.turnLeft,
	["turnRight"] = turtle.turnRight,
	["up"] = turtle.up,
	["down"] = turtle.down,
	["dig"] = turtle.dig,
	["digUp"] = turtle.digUp,
	["digDown"] = turtle.digDown,
	["place"] = turtle.place,
	["placeUp"] = turtle.placeUp,
	["placeDown"] = turtle.placeDown,
	["getAlias"] = getAlias,
	["setAlias"] = setAlias,
	["connect"] = connect,
	["disconnect"] = disconnect,
	["status"] = status,
}

while true do
	local id,command = rednet.receive()
	print(command)
	if command == "connect" then
		controllerID = id
		connect()
		rednet.send(controllerID, reply.done)
	else
		local success,err = converter[command]()
		if success then
			rednet.send(controllerID,"done")
		else
			rednet.send(controllerID,err)
		end
	end
end