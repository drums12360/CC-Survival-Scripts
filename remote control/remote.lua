--[[
This program controls the program turtle.lua via the rednet API

things to put in program
  help function
  connect to mutliple sources
  corroutine for receiving confirmation of connection with timeout
]]
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
local converter = {
  ["connect"] = connect,
  ["help"] = help,
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
        if nil == id or status then
          disconnect()
          currentID = nil
          print("Disconnected")
          return
        end
        currentStatus = status
      until id == currentID
    end
    print(currentStatus)
  end
end

function waitForResponse(id)
  local rID,response
  repeat
    rID,response = rednet.receive(nil,2)
  until rID == id
  return response
end

function help()
  print("connect id/name")
  print("exit")
end

---@param id number
---@param alias string
function setAlias(id, alias)
  aliases[alias] = id
  rednet.send(id, "setAlias")
  rednet.send(id, alias)
  local recipt = waitForResponse(id)
  if recipt ~= standardReplys.done then
    return setAlias(id, alias)
  end
end

-- Gets the alias aka label from remote
---@param id number
function getAlias(id)
  rednet.send(id, "getAlias")
  local msg = waitForResponse(id)
  if type(msg) == "table" then
    aliases[msg[1]] = id
  end
end

---@return boolean, number id
function alias(alias)
  for k,v in pairs(aliases) do
    if alias == k then
      local id = v
      return true, id
    end
  end
  return false
end

---@param id number the id#/alias we wish to connect to
function connect(id)
  if type(id) == "string" then
    _,id = alias(id)
  end
  rednet.send(id, "connect")
  local response = waitForResponse(id)
  if response == standardReplys.done then
    currentID = id
  end
end

function disconnect()
  rednet.send(currentID,"disconnect")
  local response = waitForResponse(currentID)
  if response == standardReplys.done then
    currentID = nil
  end
end

while true do
  term.write("> ")
  local command = read()
  if command == "" then
    command = nil
    print("nil")
  end
  if command then
    command = parse(command)
    if command[1] == "exit" then
      rednet.close()
      return
    else
      command[1](command[2])
    end
  end
end
