--[[
This program controls the program turtle.lua via the rednet API

todo:
start status update corroutine on connect and end on disconnect
]]
local complete = require("cc.completion")
if peripheral.find("modem") then
	peripheral.find("modem", rednet.open)
else
	return
end
local currentID = nil
local currentStatus = nil
local aliases = {}
local standardReplys = {
	ready = "ready",
	busy = "busy",
	running = "running",
	done = "done",
}

function saveData(dir, file, tbl)
	if type(tbl) ~= "table" then
		print("Wrong data type")
		return
	end
	if not fs.exists(dir) then
		fs.makeDir(dir)
	end
	local handle = fs.open(dir..file, "w")
	tbl = textutils.unserialise(tbl)
end

function loadData(dir, file)
	if fs.exists(dir..file) then
		local handle = fs.open(dir..file, "r")
		local tbl = handle.readAll()
		tbl = textutils.serialise(tbl)
		return tbl
	end
	return false
end

function parse(str)
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

function status()
	while true do
		if currentID then
			rednet.send(currentID,"status")
			repeat
				local id,status = rednet.receive(nil,2)
				if not id or not status then
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

function waitForResponse(id)
	local rID,response
	for i=1,3 do
		rID,response = rednet.receive(nil,2)
		if rID == id then
			return response
		end
	end
end

function clear()
	term.clear()
	term.setCursorPos(1,1)
end

function help()
	print("connect id/name")
	print("exit")
	print("clear")
end

function setAlias(name)
	rednet.send(currentID, "setAlias "..name)
	local recipt = waitForResponse(currentID)
	if recipt ~= standardReplys.done then
		return
	end
	aliases[name] = currentID
end

function getAlias()
	rednet.send(currentID, "getAlias")
	local msg = waitForResponse(currentID)
	if msg == "nil" then
		msg = nil
	else
		aliases[msg] = currentID
	end
	return msg
end

function alias(alias)
	for k,v in pairs(aliases) do
		if alias == k then
			local id = v
			return true, id
		end
	end
	return false
end

function sendCommand(com)
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
	for i = 1, #comList do
		if com == comList[i] then
			rednet.send(currentID, com)
			local response = waitForResponse(currentID)
			if response ~= standardReplys.done then
				print(response)
			end
			return
		end
	end
	printError("Not a command")
end

function disconnect()
	rednet.send(currentID,"disconnect")
	local response = waitForResponse(currentID)
	if response == standardReplys.done then
		currentID = nil
	end
end

function connect(id)
	local hCommand = {}
	local commandList = {
		"clear",
		"disconnect",
		"getAlias",
		"help",
		"setAlias",
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
	if type(id) == "string" then
		_,id = alias(id)
	end
	rednet.send(id, "connect")
	local response = waitForResponse(id)
	if response == standardReplys.done then
		currentID = id
	end
	local name = getAlias()
	while currentID do
		if name then
			term.write(name.."> ")
		else
			term.write(tostring(currentID).."> ")
		end
		local command = read(nil,hCommand,function(text) if text ~= "" then return complete.choice(text,commandList) end end)
		if command == "" then
			command = nil
			print("nil")
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

while true do
	local converter = {
		["connect"] = connect,
		["help"] = help,
		["clear"] = clear
	}
	local commandList = {
		"clear",
		"connect ",
		"help",
	}
	term.write("> ")
	local command = read(nil,hConnect,function(text) if text ~= "" then return complete.choice(text,commandList) end end)
	if command == "" then
		command = nil
		print("nil")
	end
	if hConnect[#hConnect] ~= command and command then
		table.insert(hConnect,command)
	end
	if command then
		command = parse(command)
		if command[1] == "exit" then
			rednet.close()
			return
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
