--[[
This program controls the program turtle.lua via the rednet API

todo:
start status update corroutine on connect and end on disconnect
]]
local complete = require("cc.completion")

-- find modem and open rednet or error
if peripheral.find("modem") then
	peripheral.find("modem", rednet.open)
else
	error("Modem not found.",0)
end

-- color pallet
local bColor = colors.black
local pColor = colors.white
local cColor = colors.white
local uColor = colors.white
if term.isColor() then
	pColor = colors.blue
	cColor = colors.green
	uColor = colors.white
end

-- set up rednet protocols and rednet lookup
local cFilter = "rcCommand"
local hFilter = "rcDNS"
local sFilter = "rcStatus"

local hostID = os.getComputerID()
local currentID = nil
local currentStatus = nil
rednet.host(hFilter,os.getComputerLabel() or tostring(hostID))
local aliases = {}
local standardReplys = {
	ready = "ready",
	busy = "busy",
	running = "running",
	done = "done",
}

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
		tbl = textutils.serialise(tbl)
		return tbl
	end
	return false
end

-- takes a string and splits it at a space and returns it in a table as strings and numbers
local function parse(str)
	local tbl = {}
	for word in string.gmatch(str, "([^ ]+)") do
		word = tonumber(word) or word
		table.insert(tbl,word)
	end
	return tbl
end

-- waits for a response from specified id
local function waitForResponse(id,filter)
	local rID,response
	for i=1,3 do
		rID,response = rednet.receive(filter,2)
		if rID == id then
			return response
		end
	end
end

-- clears the screen
local function clear()
	term.clear()
	term.setCursorPos(1,1)
end

-- list of commands available
local function help()
	if currentID then
		print("discconect")
		print("turtle <command>")
		print("setAlias <name>")
		print("getAlias")
	else
		print("connect <id/name>")
	end
	print("exit")
	print("clear")
end

-- sets the alias and label of the connected turtle
local function setAlias(name)
	rednet.send(currentID, "setAlias "..name, cFilter)
	local recipt = waitForResponse(currentID, cFilter)
	if recipt ~= standardReplys.done then
		return
	end
	aliases[name] = currentID
	saveData("/.save", "/aliases", aliases)
end

-- gets the label and sets the alias of the connected turtle
local function getAlias()
	rednet.send(currentID, "getAlias", cFilter)
	local msg = waitForResponse(currentID, cFilter)
	if msg == "nil" then
		msg = nil
	else
		aliases[msg] = currentID
		saveData("/.save", "/aliases", aliases)
	end
	return msg
end

-- standard world actions for the connected turtle
local function sendCommand(com)
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
	}
	if not com then
		return comList
	else
		for i = 1, #comList do
			if com == comList[i] then
				rednet.send(currentID, com, cFilter)
				local response = waitForResponse(currentID, cFilter)
				if response ~= standardReplys.done then
					term.setTextColor(pColor)
					print(response)
				end
				return
			end
		end
		printError("Not a command")
	end
end

-- disconnects from the connected turtle
local function disconnect()
	rednet.send(currentID, "disconnect", cFilter)
	local response = waitForResponse(currentID, cFilter)
	if response == standardReplys.done then
		currentID = nil
	end
end

-- will keep the session alive once implemented
local function status()
	while true do
		if currentID then
			rednet.send(currentID, "status", sFilter)
			repeat
				local id,msg = rednet.receive(sFilter, 2)
				if not id or not msg then
					disconnect()
					print("Disconnected")
					return
				end
				currentStatus = status
			until id == currentID
		end
		print(currentStatus)
		sleep(2)
	end
end

-- connects to turtle and intiates session
local function connect(id)
	local hCommand = {}
	local commandList = {
		"clear",
		"disconnect",
		"exit",
		"getAlias",
		"help",
		"setAlias ",
		"turtle ",
	}
	local converter = {
		["clear"] = clear,
		["disconnect"] = disconnect,
		["getAlias"] = getAlias,
		["help"] = help,
		["setAlias"] = setAlias,
		["turtle"] = sendCommand,
	}
	if id == nil then return end
	if type(id) == "string" then
		if aliases[id] then
			id = aliases[id]
		else
			printError("Alias isn't registered.")
			return
		end
	end
	rednet.send(id, "connect", cFilter)
	local response = waitForResponse(id, cFilter)
	if response == standardReplys.done then
		currentID = id
	end
	local name = getAlias()
	while currentID do
		term.setTextColor(cColor)
		if name then
			term.write(name.."> ")
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
			if command[1] == "exit" then
				disconnect()
				return true
			elseif converter[command[1]] then
				if #command > 1 then
					converter[command[1]](command[2])
				else
					converter[command[1]]()
				end
			end
		end
	end
end

local hConnect = {}

aliases = loadData("/.save", "/aliases") or {}

local lUpdate = true
local ids

-- main loop
while true do
	local converter = {
		["connect"] = connect,
		["help"] = help,
		["clear"] = clear
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
		elseif converter[command[1]] then
			local exit
			if #command > 1 then
				exit = converter[command[1]](command[2])
			else
				exit = converter[command[1]]()
			end
			if exit then
				rednet.close()
				return
			end
		end
	end
end
