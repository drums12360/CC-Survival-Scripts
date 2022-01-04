local data = require("library/dataAPI")
local move = require("library/moveAPI")

local storage = {}

function storage.drop(slots)
	local inspect, datai = turtle.inspect()
	if datai.name == "minecraft:chest" then
		for i=1, slots do
			turtle.select(i)
			turtle.drop()
		end
		turtle.select(1)
	else
		return false
	end
end

function storage.avoidChest()
	local chest = {}
	local inspect, datai = turtle.inspect()
	if datai.name == "minecraft:chest" then
		chest[1] = true
		data.saveData("/.save", "/chest", chest)
		move.turnAround()
	else
		chest[1] = false
		data.saveData("/.save", "/chest", chest)
	end
end

function storage.emptyInv()
	local start = data.loadData("/.save", "/start_pos")
	if turtle.getItemCount(15) > 0 then
		local mining = data.copyTable(data.coords)
		move.moveTo(start.x, start.y, start.z)
		storage.drop(15)
		turtle.select(1)
		move.moveTo(mining.x, mining.y, mining.z)
	end
end

function storage.waitforemptyInv()
	local start = data.loadData("/.save", "/start_pos")
	if turtle.getItemCount(15) > 0 then
		local mining = data.copyTable(data.coords)
		move.moveTo(start.x, start.y, start.z)
		turtle.select(1)
		term.clear()
		term.setCursorPos(1,1)
		print("Press any key after emptying!")
		os.pullEvent("key")
		move.moveTo(mining.x, mining.y, mining.z)
	end
end

return storage
