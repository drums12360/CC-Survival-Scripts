local data = require("dataAPI")
local dig = require("digAPI")
local move = require("moveAPI")
local storage = require("storageAPI")
local tools = require("toolsAPI")

local api = {
  data = data,
  dig = dig,
  move = move,
  storage = storage,
  tools = tools,
  timeout = data.timeout,
	d = data.d,
	hasWireless = data.hasWireless,
	direction = data.direction,
	coords = data.coords,
  maxSlots = tools.maxSlots,
  slot = tools.slot,
}

return api