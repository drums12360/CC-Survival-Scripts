local tArgs = {...}
local failedLoads = 0

local repUrl = "https://raw.githubusercontent.com/drums12360/CC-Survival-Scripts/main/remote-control/"

-- file names
local turtle = "rcTurtle.lua"
local remote = "rcRemote.lua"
local loader = "rcInstaller.lua"
local libs = {
	"ecc.lua",
}

local function dlscript(script)
	for index, filename in ipairs(libs) do
		local content = http.get(repUrl..filename).readAll()
		if not content then
			term.clear()
			term.setCursorPos(1,1)
			print("Could not connect to website ", repUrl..filename)
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
	local content = http.get(repUrl..script).readAll()
	if not content then
		term.clear()
		term.setCursorPos(1,1)
		print("Could not connect to website ", repUrl..script)
		failedLoads = failedLoads + 1
		os.sleep(5)
	else
		fs.delete(script)
		file = fs.open(script, "wb")
		file.write(content)
		file.close()
		term.clear()
		term.setCursorPos(1,1)
		print("Downloaded "..script.."!")
		os.sleep(0.25)
	end
end

local function dlloader(uptrue)
	local content = http.get(repUrl..loader).readAll()
	if not content then
		term.clear()
		term.setCursorPos(1,1)
		print("Could not connect to website ", repUrl..loader)
		failedLoads = failedLoads + 1
		os.sleep(5)
	else
		if uptrue then
			fs.delete("startup/autoupdater.lua")
			file = fs.open("startup/autoupdater.lua", "wb")
			file.write(content)
			file.close()
			term.clear()
			term.setCursorPos(1,1)
			print("Downloaded "..loader.."!")
			print("Autoupdater will update on each startup!")
			print("New scripts will download with new autoupdater.")
			os.sleep(1)
		else
			fs.delete(loader)
			file = fs.open(loader, "wb")
			file.write(content)
			file.close()
			term.clear()
			term.setCursorPos(1,1)
			print("Downloaded new "..loader.."!")
			print("Execute "..loader.." to update!")
			os.sleep(1)
		end
	end
end

local function endstats()
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

local function download(vers, uptrue)
	if uptrue == "true" then
		uptrue = true
	else
		uptrue = false
	end
	if uptrue then
		local file = fs.open("/.save/installer", "w")
		file.write(textutils.serialise({vers,uptrue}))
		file.close()
	end
	if shell.getRunningProgram() == "startup/autoupdater.lua" then
		local file = fs.open("/.save/installer", "r")
		local info = file.readAll()
		file.close()
		info = textutils.unserialise(info)
		vers = info[1]
		uptrue = info[2]
	end
	if vers == "turtle" then
		term.clear()
		term.setCursorPos(1,1)
 		print("Downloading / updating scripts with autoupdate!")
		os.sleep(0.5)
		dlscript(turtle)
		dlloader(uptrue)
		endstats()
	elseif vers == "remote" then
		term.clear()
		term.setCursorPos(1,1)
 		print("Downloading / updating scripts with autoupdate!")
		os.sleep(0.5)
		dlscript(remote)
		dlloader(uptrue)
		endstats()
	else
		term.clear()
		term.setCursorPos(1,1)
		error("Please provide a correct argument!")
	end
end

download(tostring(tArgs[1]), tostring(tArgs[2]))
