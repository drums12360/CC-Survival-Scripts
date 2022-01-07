# Remote Control v0.1.5

Remote CC:T Command `wget https://raw.githubusercontent.com/drums12360/CC-Survival-Scripts/dev/remote-control/remote.lua`

Turtle CC:T Command `wget https://raw.githubusercontent.com/drums12360/CC-Survival-Scripts/dev/remote-control/turtle.lua`

## Features

- Turtle remembers current Controller ID for security purposes
- History and Auto Complete
- Works with ender modems if desired

## Commands

| Command | Description |
| --- | --- |
| `exit` | Can be used at anytime to exit the script safely. `ctl + t` is ill advised may brick turtle from further control. |
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
| remote.lua | As the file name implies it controls the other script via the rednet api |
| turtle.lua | Controlled by the remote via the rednet api |
