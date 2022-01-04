local tArgs = {...}

function refuel(secs, repl)
	if repl == replace then
		fs.move("refuelSA.lua", "refuel.lua")
		term.clear()
		term.setCursorPos(1,1)
		print("Replaced standard 'refuel' script. Delete 'refuel' to revert it!")
		return
	end
	if secs == "nil" then
		secs = 120
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
				print("Turtle is now fully refuled!")
				break
			end
		end
		print("New fuel level: "..turtle.getFuelLevel())
	end
end

if type(tArgs[1]) ~= "number" and type(tostring(tArgs[1])) ~= "replace" then
	if type(tArgs[1]) ~= "nil" then
		term.clear()
		term.setCursorPos(1,1)
		error("Value was not a number, define time in seconds!")
	end
end

refuel(tostring(tArgs[1]), tostring(tArgs[2]))
term.clear()
term.setCursorPos(1,1)
os.sleep(5)