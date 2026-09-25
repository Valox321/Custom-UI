--// sable example (SableLib 1.13-lucide)
--// Icons: Lucide-Namen (https://lucide.dev), z.B. "settings", "swords", "eye"
local Sable = loadstring(game:HttpGet("https://raw.githubusercontent.com/Valox321/Custom-UI/refs/heads/main/SableLib.lua"))()
print("[sable] lib version:", Sable.Version or "?")

local Window = Sable:CreateWindow({
	Name = "My Client",
	ToggleKey = Enum.KeyCode.RightShift,
})

-- Tabs (Icon = Lucide-Name, rbxassetid oder Text/Emoji als Fallback)
local Combat = Window:CreateTab({ Name = "Combat", Icon = "swords" })
local Visual = Window:CreateTab({ Name = "Visual", Icon = "eye" })
local Settings = Window:CreateTab({ Name = "Settings", Icon = "settings" })

-- Pages
local Main = Combat:CreatePage({ Name = "Main", Icon = "zap" })
local Aim = Combat:CreatePage({ Name = "Aimbot", Icon = "crosshair" })
local ESP = Visual:CreatePage({ Name = "ESP", Icon = "scan-eye" })

-- Toggle
Main:AddToggle({
	Name = "Auto Crystal",
	Description = "Automatically places and explodes crystals.",
	Default = false,
	Callback = function(v) print("AutoCrystal:", v) end,
})

-- Slider
Main:AddSlider({
	Name = "Delay",
	Min = 0, Max = 500, Default = 100,
	Callback = function(v) print("Delay:", v) end,
})

-- Dropdown (Single-Select)
Main:AddDropdown({
	Name = "Mode",
	Description = "Select a mode.",
	Options = { "Normal", "Legit", "Rage" },
	Default = "Normal",
	Callback = function(v) print("Mode:", v) end,
})

-- Button
Main:AddButton({
	Name = "Reset Settings",
	Description = "Reset all settings.",
	Text = "Reset",
	Callback = function()
		Window:Notify({ Title = "Reset", Description = "Settings reset.", Duration = 2 })
	end,
})

-- Label (mit live-setzbarem Wert rechts)
local status = Aim:AddLabel({ Name = "Status", Description = "Aktueller Modus.", Value = "idle" })
Aim:AddToggle({
	Name = "Aimbot Enabled",
	Description = "Aims for you.",
	Default = true,
	Callback = function(v) status:Set(v and "active" or "idle") end,
})

-- Input (Callback feuert bei Enter)
Aim:AddInput({
	Name = "Target",
	Description = "Player name to target.",
	Default = "",
	Placeholder = "Enter username...",
	Callback = function(v) print("Target:", v) end,
})

-- Keybind (Klick -> Taste druecken, Callback feuert bei Druck)
Aim:AddKeybind({
	Name = "Toggle Aim",
	Description = "Hold-key for aim assist.",
	Default = Enum.KeyCode.E,
	Callback = function(k) print("Aim key:", k) end,
})

-- Colorpicker
ESP:AddColorpicker({
	Name = "ESP Color",
	Description = "Box outline color.",
	Default = Color3.fromRGB(130, 100, 255),
	Callback = function(c) print("ESP color:", c) end,
})
ESP:AddToggle({
	Name = "Boxes",
	Description = "Draw 2D boxes around players.",
	Default = true,
	Callback = function(v) print("Boxes:", v) end,
})

-- Notify
Window:Notify({ Title = "My Client", Description = "UI geladen. RightShift = ein-/ausblenden.", Duration = 3 })
