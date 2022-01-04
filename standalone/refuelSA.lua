local tArgs = {...}

function refuel(secs)
	if type(tonumber(secs)) ~= "number" or secs ~= nil then
		if tostring(secs) == "replace" then
			fs.move("refuelSA.lua", "refuel.lua")
			term.clear()
			term.setCursorPos(1,1)
			print("Replaced standard 'refuel' script. Delete 'refuel' to revert it!")
		end
	else
		if secs == nil then
			secs = tonumber(120)
		end
		print("Max fuel level: "..turtle.getFuelLimit())
		print("Old fuel level: "..turtle.getFuelLevel())
		if turtle.getFuelLevel() == turtle.getFuelLimit() then
			term.clear()
			term.setCursorPos(1,1)
			print("Turtle is fully refuled!")
		else
			print("Turtle will now loop refuel for "..secs.." seconds!")
			for i=1, tonumber(secs) do
				turtle.refuel()
				sleep(.5)
				if turtle.getFuelLevel() == turtle.getFuelLimit() then
					term.clear()
					term.setCursorPos(1,1)
					print("Turtle is now fully refuled!")
					break
				end
			end
			print("New fuel level: "..turtle.getFuelLevel())
		end
	end
end

refuel(tArgs[1])
os.sleep(5)
term.clear()
term.setCursorPos(1,1)