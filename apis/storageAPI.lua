local data = require("dataAPI")
local move = require("moveAPI")

local storage = {
	maxSlots = 16,
	slot = 1
}

function storage.drop(slots)
	local inspect, datai = turtle.inspect()
	if datai.name == "minecraft:chest" then
		for i=1, slots do
			turtle.select(i)
			turtle.drop()
		end
		turtle.select(1)
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
		print("Press any key after emptying.")
		os.pullEvent("key")
		move.moveTo(mining.x, mining.y, mining.z)
	end
end

function storage.inventorySort()
	local inv = {}
	for i=1, storage.maxSlots do
		inv[i] = turtle.getItemDetail(i)
	end
	for i=1, storage.maxSlots do
		if inv[i] and inv[i].count < 64 then
		for j=(i+1), storage.maxSlots do
			if inv[j] and inv[i].name == inv[j].name then
			if turtle.getItemSpace(i) == 0 then
				break
			end
			turtle.select(j)
			storage.slot = j
			local count = turtle.getItemSpace(i)
			if count > inv[j].count then
				count = inv[j].count
			end
			turtle.transferTo(i, count)
			inv[i].count = inv[i].count + count
			inv[j].count = inv[j].count - count
			if inv[j].count <= 0 then
				inv[j] = nil
			end
			end
		end
		end
	end
	for i=1, storage.maxSlots do
		if not inv[i] then
		for j=(i+1), storage.maxSlots do
			if inv[j] then
			turtle.select(j)
			storage.slot = j
			turtle.transferTo(i)
			inv[i] = data.copyTable(inv[j])
			inv[j] = nil
			break
			end
		end
		end
	end
	turtle.select(1)
	storage.slot = 1
end

return storage