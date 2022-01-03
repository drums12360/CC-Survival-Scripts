local data = require ("dataAPI")
local move = require("moveAPI")
local dig = require ("digAPI")
local tools = require("toolsAPI")
local tArgs = {...}

function mineSquence(depth, start)
	for i=1, depth do
		move.down()
		if start - 2 == data.coords.y then
			if tools.findJunk() then
				turtle.placeUp()
			end
		end
		dig.checkForOre(tostring("back_true"))
		local tbl = {turtle.inspectUp()}
		if tbl[2].name == "minecraft:bedrock" then
			term.clear()
			term.setCursorPos(1,1)
			print("Found Bedrock at Y: "..data.coords.y-1)
			print("Returning to the Surface")
			if data.hasWireless then
				rednet.broadcast("Found Bedrock at Y: "..data.coords.y-1)
				rednet.broadcast("Returning to the Surface")
			end
			local y = start - data.coords.y
			for j=1, y do
				move.up()
				if j == y then
					if tools.findJunk() then
						turtle.placeDown()
					end
				end
			end
		elseif start - depth == data.coords.y then
			for j=1, y do
				move.up()
				if j == y then
					if tools.findJunk() then
						turtle.placeDown()
					end
				end
			end
		end
		if turtle.getItemCount(16) >= 1 then
			tools.dropJunk()
		end
	end
end

if type(tonumber(tArgs[1])) ~= "number" then
	term.clear()
	term.setCursorPos(1,1)
	error("Define depth down! (Example: '10') [10 blocks down]")
end

local start = data.copyTable(data.coords)
data.saveData("/.save", "/start_pos", start)
mineSquence(tonumber(tArgs[1]), start.y)
move.moveTo(start.x, start.y, start.z)
fs.delete("/.save")