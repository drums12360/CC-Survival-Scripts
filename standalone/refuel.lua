local tArgs = {...}

function refuel(secs)
	if secs == nil then
		secs = 120
	end
	print("Max fuel level: ", turtle.getFuelLimit())
	print("Old fuel level: ", turtle.getFuelLevel())
	if turtle.getFuelLevel() == turtle.getFuelLimit() then
		term.clear()
		term.setCursorPos(1,1)
		print("Turtle is fully refuled!")
	else
		print("Turtle will now loop refuel for", secs, "seconds!")
		for i=1, secs do
			turtle.refuel()
			sleep(.5)
			if turtle.getFuelLevel() == turtle.getFuelLimit() then
				term.clear()
				term.setCursorPos(1,1)
				print("Turtle is now fully refuled!")
				break
			end
		end
		print("New fuel level: ", turtle.getFuelLevel())
	end
end

refuel(tonumber(tArgs[1]))
os.sleep(5)
term.clear()
term.setCursorPos(1,1)