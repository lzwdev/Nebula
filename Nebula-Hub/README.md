 NebulaHub

NebulaHub is a Roblox script hub loader that detects the current game and loads a matching script from this repository. If a game is not supported, it can optionally load a universal admin script.

## Quick Start

Run this loader in your Roblox executor:

```lua
loadstring(game:HttpGet("https://lzhenweidev.github.io/NebulaHub/main.luau"))()
```

## Repository Structure

- `/main.luau` - Main hub UI, game detection, and script loading logic.
- `/Scripts/` - Game-specific and universal scripts.
- `/index.html` - Simple page containing the loader snippet.

## Supported Scripts

Current scripts listed in the hub:

- Murder Mystery 2 (`Scripts/MM2.lua`)
- Airstrikes NPCs (`Scripts/GamepassFree.lua`)
- Natural Disaster Survival (`Scripts/Natural-Disaster-Survival.lua`)
- Red VS Blue Plane Wars (`Scripts/RedVSBlue-PlaneWars.lua`)
- Army Tycoon (`Scripts/Army-Tycoon.lua`)
- Universal Admin fallback (`Scripts/admin.lua`)

## Notes

- Script mappings are defined in `main.luau` under `ScriptDatabase`.
- Add new game support by creating a script in `Scripts/` and adding its `PlaceId` entry in `ScriptDatabase`.
README.md

copilot/add-readme-file
Send message

- FOR EDUCATIONAL Purposes
