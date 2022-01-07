--[[
this program is controlled by remote.lua

todo:
status update corroutine start on connect and end on disconect
]]
-- finds a modem or errors
if peripheral.find("modem") then
	peripheral.find("modem", rednet.open)
else
	error("Modem not found.",0)
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

-- parse strings with spaces to a table with strings numbers and bools
local function parse(str)
	local tbl = {}
	for word in string.gmatch(str, "([^ ]+)") do
		word = tonumber(word) or word
		if word == "true" or word == "false" then
			word = textutils.unserialise(word)
		end
		table.insert(tbl,word)
	end
	return tbl
end

-- sets that label of the turtle
local function setAlias(name)
	if name == "nil" then name = nil end
	os.setComputerLabel(name)
	alias = name
	return true
end

-- gets the label of the turtle
local function getAlias()
	local name = nil
	if not alias then
		name = "nil"
	else
		name = alias
	end
	rednet.send(controllerID, name)
	return true
end

-- not implemented
local function status()
	
end

-- disconnects from current session
local function disconnect()
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

-- starts session with controller
local function connect()
	local id,command
	rednet.send(controllerID, reply.done)
	while true do
		id,command = rednet.receive()
		if controllerID == id then
			print(command)
			command = parse(command)
			if command[1] == "disconnect" then
				disconnect()
				return
			elseif converter[command[1]] then
				local success,err
				if #command > 1 then
					success,err = converter[command[1]](command[2])
				else
					success,err = converter[command[1]]()
				end
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
