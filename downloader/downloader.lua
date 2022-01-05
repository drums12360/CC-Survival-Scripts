local tArgs = {...}
local failedLoads = 0

local repUrl = "https://raw.githubusercontent.com/drums12360/CC-Survival-Scripts/main/"

local library = {
	"init.lua",
	"dataLib.lua",
	"toolsLib.lua",
	"moveLib.lua",
	"storageLib.lua",
	"digLib.lua",
}

local scripts = {
	"stripTunnel.lua",
	"mineTunnel.lua",
	"stripMine.lua",
	"mineCuboid.lua",
	"mineVert.lua",
	"mineStaircase.lua",
}

local scriptsSA = {
	"stripTunnelSA.lua",
	"mineTunnelSA.lua",
	"stripMineSA.lua",
	"mineCuboidSA.lua",
	"mineVertSA.lua",
	"mineStaircaseSA.lua",
	"refuelSA.lua",
}

local loader = {
	"downloader.lua",
}

function dlscript()
	for index, filename in ipairs(library) do
		local content = http.get(repUrl.."library/"..filename).readAll()
		if not content then
			term.clear()
			term.setCursorPos(1,1)
			print("Could not connect to website ", repUrl.."library/"..filename)
			failedLoads = failedLoads + 1
			os.sleep(5)
		else
			fs.delete("library/"..filename)
			file = fs.open("library/"..filename, "wb")
			file.write(content)
			file.close()
			term.clear()
			term.setCursorPos(1,1)
			print("Downloaded "..filename.."!")
			os.sleep(0.25)
		end
	end
	for index, filename in ipairs(scripts) do
		local content = http.get(repUrl.."scripts/"..filename).readAll()
		if not content then
			term.clear()
			term.setCursorPos(1,1)
			print("Could not connect to website ", repUrl.."scripts/"..filename)
			failedLoads = failedLoads + 1
			os.sleep(5)
		else
			fs.delete(filename)
			file = fs.open(filename, "wb")
			file.write(content)
			file.close()
			term.clear()
			term.setCursorPos(1,1)
			print("Downloaded "..filename.."!")
			os.sleep(0.25)
		end
	end
end

function dlstandalone()
	for index, filename in ipairs(scriptsSA) do
		local content = http.get(repUrl.."standalone/"..filename).readAll()
		if not content then
			term.clear()
			term.setCursorPos(1,1)
			print("Could not connect to website ", repUrl.."standalone/"..filename)
			failedLoads = failedLoads + 1
			os.sleep(5)
		else
			fs.delete(filename)
			file = fs.open(filename, "wb")
			file.write(content)
			file.close()
			term.clear()
			term.setCursorPos(1,1)
			print("Downloaded "..filename.."!")
			os.sleep(0.25)
		end
	end
end

function dlloader(uptrue)
	for index, filename in ipairs(loader) do
		local content = http.get(repUrl.."downloader/"..filename).readAll()
		if not content then
			term.clear()
			term.setCursorPos(1,1)
			print("Could not connect to website ", repUrl.."scripts/"..filename)
			failedLoads = failedLoads + 1
			os.sleep(5)
		else
			if uptrue == "no" then
				fs.delete(filename)
				file = fs.open(filename, "wb")
				file.write(content)
				file.close()
				term.clear()
				term.setCursorPos(1,1)
				print("Downloaded new "..filename.."!")
				print("Execute "..filename.." to update!")
				os.sleep(1)
			else
				fs.delete("startup/autoupdater.lua")
				file = fs.open("startup/autoupdater.lua", "wb")
				file.write(content)
				file.close()
				term.clear()
				term.setCursorPos(1,1)
				print("Downloaded "..filename.."!")
				print("Autoupdater will update on each startup!")
				print("New scripts will download with new autoupdater.")
				os.sleep(1)
			end
		end
	end
end

function endstats()
	if failedLoads > 0 then
		term.clear()
		term.setCursorPos(1,1)
		print("Download finished with "..failedLoads.." failed downloads!")
		term.setCursorPos(2,1)
		os.sleep(5)
	else
		term.clear()
		term.setCursorPos(1,1)
		print("Downloads finished!")
		term.setCursorPos(2,1)
		os.sleep(2)
		term.clear()
		term.setCursorPos(1,1)
	end
end

function download(vers, uptrue)
	if vers == "auto" or vers == "nil" then
		term.clear()
		term.setCursorPos(1,1)
 		print("Downloading / updating scripts with autoupdate!")
		os.sleep(0.5)
		dlscript()
		dlloader(uptrue)
		endstats()
	elseif vers == "sa" then
		term.clear()
		term.setCursorPos(1,1)
 		print("Downloading / updating standalone scripts!")
		os.sleep(0.5)
		dlstandalone()
		dlloader()
		endstats()
	elseif vers == "all" then
		term.clear()
		term.setCursorPos(1,1)
		if uptrue == "no" then
 			print("Downloading / updating normal scripts and standalone scripts!")
		else
			print("Downloading / updating normal scripts and standalone scripts with autoupdate!")
		end
		os.sleep(0.5)
		dlscript()
		dlstandalone()
		dlloader(uptrue)
		endstats()
	else
		term.clear()
		term.setCursorPos(1,1)
		error("Please provide a correct argument!")
		os.sleep(5)
	end
end

download(tostring(tArgs[1]), tostring(tArgs[2]))
