--[[
this program is controlled by rcRemote.lua

todo:
status update corroutine start on connect and end on disconect
]]
-- finds a modem or errors
if peripheral.find("modem") then
	peripheral.find("modem", rednet.open)
else
	error("Modem not found.",0)
end

-- rednet protocol filters
local cFilter = "rcCommand"
local hFilter = "rcDNS"
local sFilter = "rcStatus"

local controllerID = nil
local turtleID = os.getComputerID()
local currentStatus = nil
local alias = os.getComputerLabel()
rednet.host(hFilter,alias or tostring(turtleID))
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

-- sets the label of the turtle
local function setAlias(name)
	if name == "nil" then name = nil end
	os.setComputerLabel(name)
	alias = name
	rednet.unhost(hFilter)
	rednet.host(hFilter,alias or tostring(turtleID))
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
	rednet.send(controllerID, name, cFilter)
	return true
end

-- makes sure that we are talking to a verified controller
local function checkController()
	local tbl = {rednet.lookup(hFilter)}
	for _,id in pairs(tbl) do
		if id == controllerID then
			return true
		end
	end
	return false
end

-- provides status updates from the turtle
local function status()
	while true do
		local id,msg = rednet.receive(sFilter, 5)
		if not id or not msg then
			controllerID = nil
			return
		end
		msg = parse(msg)
		if msg[1] == "status" then
			rednet.send(controllerID, currentStatus, sFilter)
		else
			controllerID = nil
			return
		end
	end
end

-- disconnects from current session
local function disconnect()
	rednet.send(controllerID, reply.done, cFilter)
	controllerID = nil
end

local converter = {
	["forward"] = turtle.forward,
	["back"] = turtle.back,
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
}

-- starts session with controller
local function connect()
	currentStatus = reply.ready
	if not checkController() then
		controllerID = nil
		return
	end
	rednet.send(controllerID, reply.done, cFilter)
	while true do
		local id,command = rednet.receive(cFilter)
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
					rednet.send(controllerID, "done" , cFilter)
				else
					rednet.send(controllerID, err,  cFilter)
				end
			end
		else
			rednet.send(id,reply.busy)
		end
	end
end

-- main loop
while true do
	local id,command = rednet.receive(cFilter)
	print(command)
	if command == "connect" then
		controllerID = id
		parallel.waitForAny(connect, status)
	end
end
