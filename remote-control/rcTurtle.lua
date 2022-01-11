--[[
this program is controlled by rcRemote.lua
]]
-- finds a modem or errors
if peripheral.find("modem") then
	peripheral.find("modem", rednet.open)
else
	error("Modem not found.",0)
end

-- load ecc dependency
local vericode = require("ecc")
local key = vericode.loadKey("rckey.key.pub")

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

-- tranfers files to and from the controller
local function scp(action, fFile, tFile)
	if action == "get" then
		if fs.exists(fFile) then
			local file = fs.open(fFile, "r")
			local msg = file.readAll()
			file.close()
			vericode.send(controllerID, msg, key, cFilter)
			return true, "Sent File "..fFile
		end
		return false, "File not found"
	elseif action == "put" then
		local output = vericode.receive(false, cFilter, 2)
		local file = fs.open(tFile, "w")
		file.write(output)
		file.close()
		return true, "Saved file to "..tFile
	end
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
		if msg.status == "status" then
			rednet.send(controllerID, {status = currentStatus}, sFilter)
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

-- all the commands allowed to run
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
	["select"] = turtle.select,
	["getItemDetail"] = turtle.getItemDetail,
	["getSelectedSlot"] = turtle.getSelectedSlot,
	["inspect"] = turtle.inspect,
	["inspectUp"] = turtle.inspectUp,
	["inspectDown"] = turtle.inspectDown,
	["getAlias"] = getAlias,
	["setAlias"] = setAlias,
	["file"] = scp,
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
			print(textutils.serialise(command))
			if command[1] == "disconnect" then
				disconnect()
				return
			elseif converter[command[1]] then
				currentStatus = reply.running
				local output
				if command.argNum > 0 then
					output = {converter[command[1]](unpack(command.args))}
				else
					output = {converter[command[1]]()}
				end
				if #output ~= 0 then
					rednet.send(controllerID, {output = output, status = "done"}, cFilter)
				else
					rednet.send(controllerID, "error",  cFilter)
				end
				currentStatus = reply.ready
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
