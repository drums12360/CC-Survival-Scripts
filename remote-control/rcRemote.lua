--[[
This program controls the program rcTurtle.lua via the rednet API
]]
local tArgs = {...}
local complete = require("cc.completion")

-- find modem and open rednet or error
if peripheral.find("modem") then
	peripheral.find("modem", rednet.open)
else
	error("Modem not found.",0)
end

-- clears the screen
local function clear()
	term.clear()
	term.setCursorPos(1,1)
end

clear()

-- gets current screen size
local tx,ty = term.getSize()

-- init windows for status and cli
local tWin = term.current()
local statusWin = window.create(tWin, 1, 1, tx, 1)
local cliWin = window.create(tWin, 1, 2, tx, ty-1)
term.redirect(cliWin)

-- color pallet
local isColor = term.isColor()
local bColor = colors.black
local pColor = colors.lightGray
local cColor = colors.gray
local uColor = colors.white
if isColor then
	pColor = colors.blue
	cColor = colors.green
end

-- set up rednet protocols and rednet lookup
local cFilter = "rcCommand"
local hFilter = "rcDNS"
local sFilter = "rcStatus"

-- important declarations
local hostID = os.getComputerID()
local currentID = nil
local currentStatus = nil
local currentName = nil
local aliases = {}
local standardReplys = {
	ready = "ready",
	busy = "busy",
	running = "running",
	done = "done",
}

-- add itself to the dns
rednet.host(hFilter, os.getComputerLabel() or tostring(hostID))

-- loads ecc dependency
local eccKeys = {}
local ecc = require("ecc")
do
	local generated = {}
	generated.private, generated.public = ecc.keypair(os.epoch())
	eccKeys[hostID] =  {
			private = generated.private,
			public = generated.public,
		}
end

-- sends encrypted and signed messages
local function send(msg, filter)
	local toSend = {}
	if type(msg) == "table" then
		msg = textutils.serialise(msg)
	end
	toSend[1] = tostring(ecc.encrypt(msg, eccKeys[currentID].shared))
	toSend.sig = tostring(ecc.sign(eccKeys[hostID].private, toSend[1]))
	return rednet.send(currentID, toSend, filter)
end

-- receives decrypts and verifys messages
local function receive(filter, timeout)
	local id, msg = rednet.receive(filter, timeout)
	if id == currentID then
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

-- save table data to a file
local function saveData(dir, file, tbl)
	if type(tbl) ~= "table" then
		print("Wrong data type.")
		return
	end
	if not fs.exists(dir) then
		fs.makeDir(dir)
	end
	local handle = fs.open(dir..file, "w")
	tbl = textutils.serialise(tbl)
	handle.write(tbl)
	handle.close()
end

-- load table data from a file
local function loadData(dir, file)
	if fs.exists(dir..file) then
		local handle = fs.open(dir..file, "r")
		local tbl = handle.readAll()
		handle.close()
		tbl = textutils.unserialise(tbl)
		return tbl
	end
	return false
end

-- takes a string and splits it at a space and returns it in a table as strings numbers and bools
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

-- waits for a response from specified id
local function waitForResponse(id,filter)
	local rID,response
	for i=1,3 do
		rID,response = receive(filter,2)
		if rID == id then
			return response
		end
	end
end

-- list of commands available
local function help()
	if currentID then
		print("run <program/path> <arg1> <arg2> ...")
		print("disconnect")
		print("turtle <command>")
		print("setAlias <name>")
		print("getAlias")
		print("file get|put </from/file/path> </to/file/path>")
	else
		print("connect <id/name>")
		print("lUpdate")
	end
	print("exit")
	print("clear")
end

-- sets the alias and label of the connected turtle
local function setAlias(...)
	local args = {...}
	local label
	if #args > 1 then
		label = table.concat(args, " ")
	else
		label = args[1]
	end
	rednet.send(currentID, {"setAlias", argNum = 1 ,args = {label}}, cFilter)
	local recipt = waitForResponse(currentID, cFilter)
	if recipt.status ~= standardReplys.done then
		return
	end
	if label == nil or label == "nil" then
		label = nil
	end
	if currentName then
		aliases[currentName] = nil
	end
	if label then
		aliases[label] = currentID
	end
	saveData("/.save", "/aliases", aliases)
	currentName = label
end

-- gets the label and sets the alias of the connected turtle
local function getAlias()
	rednet.send(currentID, {"getAlias", argNum = 0}, cFilter)
	local msg = waitForResponse(currentID, cFilter)
	if msg == "nil" then
		msg = nil
	else
		aliases[msg] = currentID
		saveData("/.save", "/aliases", aliases)
	end
	currentName = msg
end

-- transfers files to and from the turtle
local function scp(action, fFile, tFile)
	local fileBlacklist = {
		shell.getRunningProgram(),
		fs.getDir(shell.getRunningProgram()).."/ecc.lua", 
	}
	for i = 1, #fileBlacklist do
		if fFile == fileBlacklist[i] or tFile == fileBlacklist[i] then
			print("Not Allowed to transfer ".. fileBlacklist[i])
			return
		end
	end
	if action == "get" then
		send({"file", args = {"get", fFile, tFile},argNum = 3}, cFilter)
		local response = waitForResponse(currentID, cFilter)
		local file = fs.open(tFile, "w")
		file.write(response)
		file.close()
		response = waitForResponse(currentID, cFilter)
		return response.output
	elseif action == "put" then
		local file = fs.open(fFile, "r")
		fFile = file.readAll()
		file.close()
		send({"file", args = {"put", fFile, tFile},argNum = 3}, cFilter)
		local response = waitForResponse(currentID, cFilter)
		return response.output
	else
		term.setTextColor(pColor)
		print("Invalid Args.")
	end
end

-- standard actions for the connected turtle
local function sendCommand(com, ...)
	local args = {...}
	local comList = {
		"forward",
		"back",
		"turnLeft",
		"turnRight",
		"up",
		"down",
		"dig",
		"digUp",
		"digDown",
		"place",
		"placeUp",
		"placeDown",
		"select",
		"getSelectedSlot",
		"getItemDetail",
		"inspect",
		"inspectUp",
		"inspectDown",
	}
	if not com then
		return comList
	else
		for i = 1, #comList do
			if com == comList[i] then
				rednet.send(currentID, {com, argNum = #args, args = args}, cFilter)
				local response = waitForResponse(currentID, cFilter)
				if response.status ~= standardReplys.done then
					term.setTextColor(pColor)
					print(textutils.serialise(response.output))
				end
				if type(response.output[2]) == "string" then
					if com == "forward" then
						rednet.send(currentID, {"inspect", argNum = 0, args = {}}, cFilter)
						local extra = waitForResponse(currentID, cFilter)
						response.output[3] = extra.output[2].name
					elseif com == "up" then
						rednet.send(currentID, {"inspectUp", argNum = 0, args = {}}, cFilter)
						local extra = waitForResponse(currentID, cFilter)
						response.output[3] = extra.output[2].name
					elseif com == "down" then
						rednet.send(currentID, {"inspectDown", argNum = 0, args = {}}, cFilter)
						local extra = waitForResponse(currentID, cFilter)
						response.output[3] = extra.output[2].name
					end
				end
				return response.output
			end
		end
		printError("Not a command")
	end
end

local function run(...)
	local args = {...}
	for i = 1, #args do
		args[i] = tostring(args[i])
	end
	send({"run", args = args, argNum = #args}, cFilter)

end

-- disconnects from the connected turtle
local function disconnect()
	rednet.send(currentID, {"disconnect", argNum = 0}, cFilter)
	local response = waitForResponse(currentID, cFilter)
	eccKeys[currentID] = nil
	currentID = nil
end

-- will keep the session alive
local function status()
	while true do
		repeat
			local id,msg = rednet.receive(sFilter, 6)
			if not id or not msg.status then
				disconnect()
				printError("Disconnected")
				return
			end
			rednet.send(currentID, standardReplys.done, sFilter)
			currentStatus = msg.status
		until id == currentID
		os.queueEvent("update")
	end
end

-- independent update function
local function statusUpdate()
	local statusColor = {
		[standardReplys.ready] = colors.green,
		[standardReplys.running] = colors.yellow,
	}
	while true do
		os.pullEvent("update")
		local cx,cy = term.getCursorPos()
		local cWin = term.current()
		term.redirect(statusWin)
		term.setCursorPos(1,1)
		term.clearLine()
		term.write("Status: ")
		if isColor then
			local tColor = term.getTextColor()
			term.setTextColor(statusColor[currentStatus])
			term.write(currentStatus)
			term.setTextColor(tColor)
		else
			term.write(currentStatus)
		end
		term.redirect(cWin)
		term.setCursorPos(cx,cy)
	end
end

local exit
-- wrapper function for connect
local function connection()
	local hCommand = {}
	local converter = {
		["clear"] = clear,
		["disconnect"] = disconnect,
		["getAlias"] = getAlias,
		["help"] = help,
		["setAlias"] = setAlias,
		["turtle"] = sendCommand,
		["file"] = scp,
		["run"] = run,
	}
	while currentID do
		local commandList = {
			"clear",
			"disconnect",
			"exit",
			"getAlias",
			"help",
			"setAlias ",
			"turtle ",
			"file ",
			"file get ",
			"file put ",
			"run ",
		}
		term.setTextColor(cColor)
		if currentName then
			term.write(currentName.."> ")
		else
			term.write(tostring(currentID).."> ")
		end
		term.setTextColor(uColor)
		local command = read(nil,hCommand,
			function(text)
				if text ~= "" then
					local tbl = sendCommand()
					for i = 1, #tbl do
						table.insert(commandList,"turtle "..tbl[i])
					end
					local list = parse(text)
					local fileStub = list[#list]
					local fList = fs.find(fileStub.."*")
					if #fList > 0 then
						for i = 1, #fList do
							table.insert(commandList, "file put "..fList[i])
						end
					else
						fList = fs.list("*")
						for i = 1, #fList do
							table.insert(commandList, "file put "..fList[i])
						end
					end
					return complete.choice(text,commandList)
				end
			end)
		if command == "" then
			command = nil
		end
		if hCommand[#hCommand] ~= command and command then
			table.insert(hCommand,command)
		end
		if command then
			command = parse(command)
			local output
			if command[1] == "exit" then
				disconnect()
				exit = true
			elseif converter[command[1]] then
				if #command > 1 then
					output = converter[command[1]](unpack(command, 2, #command))
				else
					output = converter[command[1]]()
				end
			end
			if output then
				if type(output) == "table" then
					term.setTextColor(pColor)
					print(textutils.serialise(output))
				else
					term.setTextColor(pColor)
					print(output)
				end
			end
		end
	end
end

-- connects to turtle and intiates session
local function connect(id,func)
	if id == nil then return end
	if type(id) == "string" then
		if aliases[id] then
			id = aliases[id]
		else
			printError("Alias isn't registered.")
			return
		end
	end
	rednet.send(id, {"connect", key = tostring(eccKeys[hostID].public)}, cFilter)
	local cID, response = rednet.receive(cFilter,3)
	if id == cID then
		currentID = id
	else
		return
	end
	eccKeys[currentID] = {}
	eccKeys[currentID].public = {string.byte(response.key, 1, -1)}
	eccKeys[currentID].shared = ecc.exchange(eccKeys[hostID].private, eccKeys[currentID].public)
	waitForResponse(id, cFilter)
	getAlias()
	parallel.waitForAny(func, status, statusUpdate)
	if currentID then
		disconnect()
	end
end

local hConnect = {}

aliases = loadData("/.save", "/aliases") or {}

local lUpdate = true
local ids

clear()

-- main loop
while true do
	local converter = {
		["connect"] = connect,
		["help"] = help,
		["clear"] = clear,
	}
	local commandList = {
		"clear",
		"connect ",
		"exit",
		"lUpdate",
		"help",
	}
	if lUpdate then
		ids = {rednet.lookup(hFilter)}
		lUpdate = false
		for k,id in pairs(ids) do
			if id == hostID then
				ids[k] = nil
				break
			end
		end
	end
	term.setBackgroundColor(bColor)
	term.setTextColor(pColor)
	term.write("> ")
	term.setTextColor(uColor)
	local command = read(nil,hConnect,
		function(text)
			if text ~= "" then
				for _,v in pairs(ids) do
					table.insert(commandList, "connect "..tostring(v))
				end
				return complete.choice(text,commandList)
			end
		end)
	if command == "" then
		command = nil
	end
	if hConnect[#hConnect] ~= command and command then
		table.insert(hConnect,command)
	end
	if command then
		command = parse(command)
		if command[1] == "exit" then
			rednet.close()
			return
		elseif command[1] == "lUpdate" then
			lUpdate = true
		elseif command[1] == "connect" then
			connect(command[2],connection)
		elseif converter[command[1]] then
			if #command > 1 then
				converter[command[1]](unpack(command, 2, #command))
			else
				converter[command[1]]()
			end
		end
		if exit then
			rednet.close()
			return
		end
	end
end
