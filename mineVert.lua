local move = require("moveAPI")
if peripheral.isPresent("modem") then
    modem = peripheral.find("modem")
end
  move.coords.y = 64
  startY = move.coords.y
local oreList = {
	"minecraft:iron_ore",
  "minecraft:coal_ore",
  "minecraft:gold_ore",
  "minecraft:diamond_ore",
  "minecraft:emerald_ore",
  "minecraft:copper_ore",
  "minecraft:lapis_ore",
  "minecraft:redstone_ore",
  "minecraft:deepslate_iron_ore",
  "minecraft:deepslate_coal_ore",
  "minecraft:deepslate_gold_ore",
  "minecraft:deepslate_diamond_ore",
  "minecraft:deepslate_emerald_ore",
  "minecraft:deepslate_copper_ore",
  "minecraft:deepslate_lapis_ore",
  "minecraft:deepslate_redstone_ore",
  "minecraft:nether_gold_ore",
  "minecraft:nether_quartz_ore",
  "minecraft:obsidian",
}

function hasWireless()
  if modem == nil then
    move.hasWireless = false
  else
    move.hasWireless = true
    modem.open(tonumber(os.getComputerID()))
    modem.open(rednet.CHANNEL_BROADCAST)
    rednet.broadcast("Program Start Up")
  end
end

function inspectBlock()
  local inspect = {turtle.inspect()}
  for k,v in pairs(oreList) do
    if v == inspect[2].name then
      turtle.dig()
      if move.hasWireless then
        rednet.broadcast("Found "..inspect[2].name.." at Y: "..move.coord.y)
      end
      break
    end
  end
end

function inspectLayer()
  for i=3,0,-1 do
    move.face(i)
    inspectBlock()
  end
end

hasWireless()
while move.down() do
  if startY - 2 == move.coord.y then
    if move.findItem("minecraft:cobblestone") then
      turtle.placeUp()
    elseif move.findItem("minecraft:dirt") then
      turtle.placeUp()
    end
  end
  inspectLayer()
end
if move.hasWireless then
  rednet.broadcast("Found Bedrock at Y: "..move.coord.y-1)
  rednet.broadcast("Returning to the Surface")
end
local y = startY - move.coord.y
for i=1,y do
  move.up()
  if i == y then
    move.findItem("minecraft:cobblestone")
    turtle.placeDown()
  end
end
