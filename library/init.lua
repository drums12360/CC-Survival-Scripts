local data = require("library/dataAPI")
local dig = require("library/digAPI")
local move = require("library/moveAPI")
local storage = require("library/storageAPI")
local tools = require("library/toolsAPI")

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