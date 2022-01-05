local data = require("library/dataLib")
local dig = require("library/digLib")
local move = require("library/moveLib")
local storage = require("library/storageLib")
local tools = require("library/toolsLib")

local library = {
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

return library