local data = {
	timeout = 5,
	d = 0,
	hasWireless = false,
	direction = {[0] = "north", [1] = "east", [2] = "south", [3] = "west"},
	coords = {x = 0, y = 0,z = 0}
}

function data.copyTable(tbl)
	if type(tbl) ~= "table" then
		error("The type of 'tbl' is not a table",2)
	end
	local rtbl = {}
	for k,v in pairs(tbl) do
		rtbl[k] = v
	end
	return rtbl
end

function data.saveData(dir, path, tbl)
	if type(tbl) ~= "table" then
		error("The type of 'tbl' is not a table",2)
	elseif type(path) ~= "string" or type(dir) ~= "string" then
		error("The type of 'path' or 'dir' is not a string",2)
	end
	if not fs.exists(dir) then
		fs.makeDir(dir)
	end
	local f = fs.open(dir .. path, "w")
	f.write(textutils.serialize(tbl))
	f.close()
end

function data.loadData(dir, path)
	if type(path) ~= "string" or type(dir) ~= "string" then
		error("The type of 'path' or 'dir' is not a string",2)
	end
	if fs.exists(dir) then
		local tbl = {}
		local f = fs.open(dir .. path, "r")
		tbl = f.readAll()
		tbl = textutils.unserialize(tbl)
		f.close()
		return tbl
	end
	return false
end

function data.gpsStart(side)
	if data.hasWireless == true then
		rednet.open(side)
		local Start1 = vector.new(gps.locate(2))
		while not turtle.forward() do
			turtle.turnRight()
		end
		local Start2 = vector.new(gps.locate(2))
		if Start1.x ~= Start2.x then
			if Start1.x - Start2.x == -1 then
			data.d = 3
			elseif Start1.x - Start2.x == 1 then
			data.d = 1
			end
		elseif Start1.z ~= Start2.z then
			if Start1.z - Start2.z == -1 then
				data.d = 0
			elseif Start1.z - Start2.z == 1 then
				data.d = 2
			end
		end
		data.coords.x = Start2.x
		data.coords.y = Start2.y
		data.coords.z = Start2.z
		data.backward()
	end
end

return data