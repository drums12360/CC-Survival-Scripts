--[[
this program is controlled by remote.lua

todo:
check for one connection at a time
status update corroutine start on connect and end on disconect
]]
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

function setAlias(name)
	if name == "nil" then name = nil end
	os.setComputerLabel(name)
	alias = name
	return true
end

function getAlias()
	local name = nil
	if not alias then
		name = "nil"
	else
		name = alias
	end
	rednet.send(controllerID, name)
	return true
end

function status()
	
end

function disconnect()
	rednet.send(controllerID, reply.done)
	controllerID = nil
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
	["status"] = status,
}

function connect()
	local id,command = nil,nil
	rednet.send(controllerID, reply.done)
	while true do
		id,command = rednet.receive()
		if controllerID == id then
			print(command)
			if command == "disconnect" then
				disconnect()
				return
			elseif converter[command] then
				local success,err = converter[command]()
				if success then
					rednet.send(controllerID,"done")
				else
					rednet.send(controllerID,err)
				end
			end
		else
			rednet.send(id,reply.busy)
		end
	end
end

while true do
	local id,command = rednet.receive()
	print(command)
	if command == "connect" then
		controllerID = id
		connect()
	end
end
