local urls = {
	"https://raw.githubusercontent.com/drums12360/CC-Survival-Scripts/main/apis/dataAPI.lua",
	"https://raw.githubusercontent.com/drums12360/CC-Survival-Scripts/main/apis/toolsAPI.lua",
	"https://raw.githubusercontent.com/drums12360/CC-Survival-Scripts/main/apis/moveAPI.lua",
	"https://raw.githubusercontent.com/drums12360/CC-Survival-Scripts/main/apis/storageAPI.lua",
	"https://raw.githubusercontent.com/drums12360/CC-Survival-Scripts/main/apis/digAPI.lua",
	"https://raw.githubusercontent.com/drums12360/CC-Survival-Scripts/main/stripTunnel.lua",
	"https://raw.githubusercontent.com/drums12360/CC-Survival-Scripts/main/mineTunnel.lua",
	"https://raw.githubusercontent.com/drums12360/CC-Survival-Scripts/main/downloader/downloader.lua",
}

function download(url)
	local content = http.get(url).readAll()
	local filename = url:match( "([^/]+)$" )
	if not content then
		term.clear()
		error("Could not connect to website ", url)
	else
		term.clear()
		print("Download finished from ", url)
		fs.delete(filename)
		file = fs.open(filename, "wb")
		file.write(content)
		file.close()
		if filename == "downloader.lua" then
			fs.delete("startup/autoupdate.lua")
			fs.move(filename, "startup/autoupdate.lua")
			term.clear()  
			print("Installed autoupdate on every turtle startup!")
			os.sleep(5)
		end
		term.clear()  
		print("Downloaded and saved ", filename)
		os.sleep(3)
	end
end

function start()
	for index, value in ipairs(urls) do
		download(value)
	end
end
	
term.clear()
print("Downloading APIs and programs!")
os.sleep(3)
start()
term.clear()  
print("API and program download finished.")
os.sleep(3)
term.clear() 