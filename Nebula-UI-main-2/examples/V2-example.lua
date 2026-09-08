-- 🌟 NEBULA UI DEMO - ALL FEATURES
local Nebula = loadstring(game:HttpGet("https://raw.githubusercontent.com/lzhenweiDev/Nebula-UI/refs/heads/main/V2.lua"))()

local Window = Nebula.CreateWindow({
    Title = "Nebula UI Demo",
    ShowLoading = true,
    LoadingSteps = {"Loading Nebula...", "Creating UI...", "Setting up theme...", "Done! ✨"},
    LoadingDuration = 3,
})

-- Tabs
local MainTab = Window:CreateTab("🏠 Main", "")
local VisualsTab = Window:CreateTab("👁️ Visuals", "")
local SettingsTab = Window:CreateTab("⚙️ Settings", "")

-- Main Tab
local Section1 = Nebula.CreateSection(MainTab, {Name = "Player"})
Section1:CreateToggle({Name = "God Mode", Default = false, Callback = function(v) print("God Mode:", v) end})
Section1:CreateSlider({Name = "Walk Speed", Min = 16, Max = 200, Default = 16, Suffix = " spd", Callback = function(v) print("Speed:", v) end})
Section1:CreateButton({Name = "Respawn", Callback = function() print("Respawned!") end})

local Section2 = Nebula.CreateSection(MainTab, {Name = "Combat"})
Section2:CreateToggle({Name = "Aimbot", Default = false, Callback = function(v) print("Aimbot:", v) end})
Section2:CreateDropdown({Name = "Target", Options = {"Head", "Torso", "Random"}, Default = "Head", Callback = function(v) print("Target:", v) end})

-- Visuals Tab
local VisSection = Nebula.CreateSection(VisualsTab, {Name = "ESP"})
VisSection:CreateToggle({Name = "ESP", Default = false, Callback = function(v) print("ESP:", v) end})
VisSection:CreateToggle({Name = "Team Check", Default = true, Callback = function(v) print("Team Check:", v) end})
VisSection:CreateColorPicker({Name = "ESP Color", Default = Color3.fromRGB(140, 80, 255), Callback = function(c) print("Color:", c) end})

-- Settings Tab
local SetSection = Nebula.CreateSection(SettingsTab, {Name = "Config"})
SetSection:CreateKeybind({Name = "Toggle Key", Default = "F", Callback = function(k) print("Key:", k) end})
SetSection:CreateTextBox({Name = "Username", Placeholder = "Enter username...", Callback = function(t) print("Text:", t) end})
SetSection:CreateCheckbox({Name = "Auto Save", Default = true, Callback = function(v) print("Auto Save:", v) end})
SetSection:CreateProgressBar({Name = "Loading", Value = 65, Max = 100})

Window:Notify({Title = "🌟 Welcome!", Content = "Nebula UI v3.0 Loaded!", Type = "success", Duration = 5})
