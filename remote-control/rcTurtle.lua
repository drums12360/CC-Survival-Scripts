--[[
this program is controlled by rcRemote.lua
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

-- loads ecc dependency
local eccKeys = {}
local ecc = require("ecc")
do
	local generated = {}
	generated.private, generated.public = ecc.keypair(os.epoch())
	eccKeys[turtleID] =  {
			private = generated.private,
			public = generated.public,
		}
end

-- send encrypted and signed messages
function send(msg, filter)
	local toSend ={}
	if type(msg) == "table" then
		msg = textutils.serialise(msg)
	end
	toSend[1] = tostring(ecc.encrypt(msg, eccKeys[controllerID].shared))
	toSend.sig = tostring(ecc.sign(eccKeys[turtleID].private, toSend[1]))
	return rednet.send(controllerID, toSend, filter)
end

-- receive decrypt and verify messages
function receive(filter, timeout)
	local id, msg = rednet.receive(filter, timeout)
	if id == controllerID then
		if msg.sig then
			msg[1] = {string.byte(msg[1], 1, -1)}
			msg.sig = {string.byte(msg.sig, 1, -1)}
			if ecc.verify(eccKeys[id].public, msg[1], msg.sig) then
				msg = ecc.decrypt(msg[1], eccKeys[id].shared)
				msg = textutils.unserialise(tostring(msg))
				return id, msg
			end
		else
			return id, msg
		end
	end
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

-- tranfers files to and from the controller
local function scp(action, fFile, tFile)
	local fileBlacklist = {
		shell.getRunningProgram(),
		fs.getDir(shell.getRunningProgram()).."/ecc.lua",
	}
	for i = 1, #fileBlacklist do
		if fFile == fileBlacklist[i] or tFile == fileBlacklist[i] then
			return false ,"Not Allowed to transfer ".. fileBlacklist[i]
		end
	end
	if action == "get" then
		if fs.exists(fFile) then
			local file = fs.open(fFile, "r")
			local msg = file.readAll()
			file.close()
			send(msg, cFilter)
			return true, "Sent File "..fFile
		end
		return false, "File not found"
	elseif action == "put" then
		local file = fs.open(tFile, "w")
		file.write(fFile)
		file.close()
		return true, "Saved file to "..tFile
	end
end

-- makes sure that we are talking to a verified controller
local function checkController(checkID)
	local tbl = {rednet.lookup(hFilter)}
	for _,id in pairs(tbl) do
		if id == checkID then
			return true
		end
	end
	return false
end

-- checks program against blacklist then runs the program
local function run(program, ...)
	local progBlackList = {
		shell.getRunningProgram(),
		fs.getDir(shell.getRunningProgram()).."/ecc.lua"
	}
	for i = 1, #progBlackList do
		if program == progBlackList[i] then
			return false, "Not allowed to run "..progBlackList[i]
		end
	end
	return shell.execute(program, ...)
end

-- disconnects from current session
local function disconnect()
	rednet.send(controllerID, reply.done, cFilter)
	eccKeys[controllerID] = nil
	controllerID = nil
end

-- provides status updates from the turtle
local function status()
	sleep(1)
	while true do
		rednet.send(controllerID, {status = currentStatus}, sFilter)
		local sID,msg = rednet.receive(sFilter, 3)
		if not sID or not msg == reply.done then
			disconnect()
			return
		end
		sleep(3)
	end
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
	["run"] = run,
}


local lastCMD, lastID
-- starts session with controller
local function connect()
	currentStatus = reply.ready
	while true do
		local id,command
		id,command = receive(cFilter)
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
		end
	end
end

-- main loop
while true do
	local id,command = rednet.receive(cFilter)
	print(command[1])
	if command[1] == "connect" and command.key then
		if checkController(id) then
		controllerID = id
		eccKeys[controllerID] = {}
		eccKeys[controllerID].public = {string.byte(command.key, 1, -1)}
		rednet.send(id, {key = tostring(eccKeys[turtleID].public)}, cFilter)
		eccKeys[controllerID].shared = ecc.exchange(eccKeys[turtleID].private, eccKeys[controllerID].public)
		rednet.send(controllerID, reply.done, cFilter)
		parallel.waitForAny(connect, status)
		end
	end
end
