local tArgs = {...}

function refuel(secs)
	if secs == replace then
		fs.move("refuelSA.lua", "refuel.lua")
		term.clear()
		term.setCursorPos(1,1)
		print("Replaced standard 'refuel' script. Delete 'refuel' to revert it!")
	elseif type(tonumber(secs)) == "number" then
		if secs == nil then
			secs = tonumber(120)
			print("Max fuel level: "..turtle.getFuelLimit())
			print("Old fuel level: "..turtle.getFuelLevel())
			if turtle.getFuelLevel() == turtle.getFuelLimit() then
				term.clear()
				term.setCursorPos(1,1)
				print("Turtle is fully refuled!")
			else
				term.clear()
				term.setCursorPos(1,1)
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
				term.clear()
				term.setCursorPos(1,1)
				print("New fuel level: "..turtle.getFuelLevel())
			end
		else
			term.clear()
			term.setCursorPos(1,1)
			error("Please insert a valid time in seconds!")
		end
	end
end

refuel(tostring(tArgs[1]))
os.sleep(5)