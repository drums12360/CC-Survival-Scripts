function download(url)
	local content = http.get(url).readAll()
	local filename = url:match( "([^/]+)$" )
	if not content then
		error("Could not connect to website " url)
	else
		print("Download finished from " url)
		file = fs.open(filename, "wb")
		file.write(content)
		file.close()
		print("Downloaded and saved " filename)
	end
end

print("Downloading  programs!")
download("https://raw.githubusercontent.com/Keigun-Spark/CC-Survival-Scripts/main/stripTunnel.lua")
download("https://raw.githubusercontent.com/Keigun-Spark/CC-Survival-Scripts/main/mineTunnel.lua")
print("Program download finished.")