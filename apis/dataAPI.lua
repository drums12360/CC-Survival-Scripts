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

return data