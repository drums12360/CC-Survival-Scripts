local tArgs = {...}

function refuel(secs, repl)
	if repl == replace then
		fs.move("refuelSA.lua", "refuel.lua")
		term.clear()
		term.setCursorPos(1,1)
		print("Replaced standard 'refuel' script. Delete 'refuel' to revert it!")
	end
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
end

if type(tonumber(tArgs[1])) ~= "number" then
	if type(tonumber(tArgs[1])) ~= "nil" then
		term.clear()
		term.setCursorPos(1,1)
		error("Define step amount and direction! (Example: '10 up') [10 steps, upwards]")
	end
end

refuel(tonumber(tArgs[1]), tostring(tArgs[2]))
os.sleep(5)