local urls = {
	"https://raw.githubusercontent.com/Keigun-Spark/CC-Survival-Scripts/main/apis/dataAPI.lua",
	"https://raw.githubusercontent.com/Keigun-Spark/CC-Survival-Scripts/main/apis/toolsAPI.lua",
	"https://raw.githubusercontent.com/Keigun-Spark/CC-Survival-Scripts/main/apis/moveAPI.lua",
	"https://raw.githubusercontent.com/Keigun-Spark/CC-Survival-Scripts/main/apis/storageAPI.lua",
	"https://raw.githubusercontent.com/Keigun-Spark/CC-Survival-Scripts/main/apis/digAPI.lua",
	"https://raw.githubusercontent.com/Keigun-Spark/CC-Survival-Scripts/main/stripTunnel.lua",
	"https://raw.githubusercontent.com/Keigun-Spark/CC-Survival-Scripts/main/mineTunnel.lua",
	"https://raw.githubusercontent.com/Keigun-Spark/CC-Survival-Scripts/main/stripMine.lua",
	"https://raw.githubusercontent.com/Keigun-Spark/CC-Survival-Scripts/main/standalone/refuel.lua",
	"https://raw.githubusercontent.com/Keigun-Spark/CC-Survival-Scripts/main/downloader/downloader.lua",
}

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