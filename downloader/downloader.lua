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
			os.sleep(3)
		end
		term.clear()  
		print("Downloaded and saved ", filename)
	end
end

term.clear()
print("Downloading APIs and programs!")
download("https://raw.githubusercontent.com/Keigun-Spark/CC-Survival-Scripts/main/apis/dataAPI.lua")
download("https://raw.githubusercontent.com/Keigun-Spark/CC-Survival-Scripts/main/apis/toolsAPI.lua")
download("https://raw.githubusercontent.com/Keigun-Spark/CC-Survival-Scripts/main/apis/moveAPI.lua")
download("https://raw.githubusercontent.com/Keigun-Spark/CC-Survival-Scripts/main/apis/storageAPI.lua")
download("https://raw.githubusercontent.com/Keigun-Spark/CC-Survival-Scripts/main/apis/digAPI.lua")
download("https://raw.githubusercontent.com/Keigun-Spark/CC-Survival-Scripts/main/stripTunnel.lua")
download("https://raw.githubusercontent.com/Keigun-Spark/CC-Survival-Scripts/main/mineTunnel.lua")
download("https://raw.githubusercontent.com/Keigun-Spark/CC-Survival-Scripts/main/downloader/downloader.lua")
term.clear()  
print("API and program download finished.")