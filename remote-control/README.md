# Remote Control v0.3.3

Remote CC:T Command `wget https://raw.githubusercontent.com/drums12360/CC-Survival-Scripts/main/remote-control/rcRemote.lua`

Turtle CC:T Command `wget https://raw.githubusercontent.com/drums12360/CC-Survival-Scripts/main/remote-control/rcTurtle.lua`

## Features

- Turtle remembers current Controller ID for security purposes
- History and Auto Complete
- Works with ender modems if desired
- Keep Alive and Status Updates

## Commands

| Command | Description |
| --- | --- |
| `lUpdate` | Can't be used if already connected to a turtle. Updates the `rednet.lookup` table. This will take about 2 seconds to complete. |
| `exit` | Can be used at anytime to exit the script safely. `ctl + t` is ill advised as it might brick the `turtle` from further control. |
| `clear` | Can be used at anytime to clear the screen. |
| `connect <id/alias>` | Can't be used if already connected to a turtle. Connects to the turtle via Rednet. |
| `help` | Can be used at anytime. It's a help command simple enough. |
| `disconnect` | Can only be used while connected to a turtle. Closes the Rednet connection to the turtle. |
| `turtle <command>` | Can only be used while connected to a turtle. Controls the turtle's movement and whether to dig or place blocks. |
| `getAlias` | Can only be used while connected to a turtle. Gets the `label` and uses it as the alias. |
| `setAlias <name/nil>` | Can only be used while connected to a turtle. Sets the `label` and uses it as the alias. |

## Files

File names are subject to change

| File | Description |
| --- | --- |
| rcRemote.lua | As the file name implies it controls rcTurtle via the rednet api |
| rcTurtle.lua | Controlled by rcRemote via the rednet api |
