local data = require("dataAPI")
local move = require("moveAPI")

local storage = {
<<<<<<< HEAD
  maxSlots = 16,
}

function storage.drop(slots)
  local inspect, datai = turtle.inspect()
  if datai.name == "minecraft:chest" then
    for i=1, storage.maxSlots do
      turtle.select(i)
      turtle.drop()
    end
    turtle.select(1)
  end
=======

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
>>>>>>> bfd0d3893cf12f78e04a29989dcfb7ba4ab9d3e9
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
<<<<<<< HEAD
  local start = data.loadData("/.save", "/start_pos")
  if turtle.getItemCount(15) > 0 then
    local mining = data.copyTable(data.coords)
    move.moveTo(start.x, start.y, start.z)
    turtle.select(1)
    term.clear()
    print("Press any key after emptying.")
    os.pullEvent("key")
    move.moveTo(mining.x, mining.y, mining.z)
  end
=======
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
>>>>>>> bfd0d3893cf12f78e04a29989dcfb7ba4ab9d3e9
end

return storage