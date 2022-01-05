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

function getAlias()
	
end

function setAlias()
	
end

while true do
	local id,command = rednet.receive()
	print(command)
	-- converter[command]()
	rednet.send(id,"done")
end