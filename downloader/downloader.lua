local repUrl = "https://raw.githubusercontent.com/Keigun-Spark/CC-Survival-Scripts/main/"
local urls = {
	"https://raw.githubusercontent.com/Keigun-Spark/CC-Survival-Scripts/main/standalone/refuel.lua",
	"https://raw.githubusercontent.com/Keigun-Spark/CC-Survival-Scripts/main/downloader/downloader.lua",
}

local apis = {
	"init.lua",
	"dataAPI.lua",
	"toolsAPI.lua",
	"moveAPI.lua",
	"storageAPI.lua",
	"digAPI.lua",
}

local progs = {
	"stripTunnel.lua",
	"mineTunnel.lua",
	"stripMine.lua",
	"mineCuboid.lua",
	"mineVert.lua",
	"mineStaircase.lua"
}

local refuel = 

function download(url)
	local content = http.get(url).readAll()
	local filename = url:match( "([^/]+)$" )
	if not content then
		term.clear()
		term.setCursorPos(1,1)
		error("Could not connect to website ", url)
	else
		term.clear()
		term.setCursorPos(1,1)
		print("Downloaded", filename)
		fs.delete(filename)
		file = fs.open(filename, "wb")
		file.write(content)
		file.close()
		if filename == "downloader.lua" then
			fs.delete("startup/autoupdate.lua")
			fs.move(filename, "startup/autoupdate.lua")
			print("Installed autoupdate on every turtle startup!")
			os.sleep(1)
		else
		print("Download finished!")
		end
	end
end

function start()
	for index, value in ipairs(urls) do
		download(value)
		os.sleep(0.5)
	end
end

term.clear()
term.setCursorPos(1,1)
print("Downloading / Updating APIs and programs!")
os.sleep(0.5)
start()
term.clear()
term.setCursorPos(1,1)
print("API and program download finished!")
os.sleep(1)
term.clear()
term.setCursorPos(1,1)
