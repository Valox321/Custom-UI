--// sable example: Referenz-Screenshot 1:1 (SableLib 1.14-shot)
--// Tabs = Sidebar (MODULES / GENERAL), Pages = Sections im Content
local Sable = loadstring(game:HttpGet("https://raw.githubusercontent.com/Valox321/Custom-UI/refs/heads/main/SableLib.lua?x=" .. tick()))()
print("[sable] lib version:", Sable.Version or "?")

local Window = Sable:CreateWindow({
	Name = "Prestige Client",
	Version = "BETA RELEASE 4.3.0",
	Icon = "121040200759967",
	ToggleKey = Enum.KeyCode.RightShift,
	SearchPlaceholder = "Search modules",
})

-- MODULES (Sidebar oben, mit Counts wie im Screenshot)
Window:CreateSection("Modules")
local Combat = Window:CreateTab({ Name = "Combat", Title = "Combat Modules", Icon = "swords", Count = 39 })
Window:CreateTab({ Name = "Mace", Icon = "hammer", Count = 13 })
Window:CreateTab({ Name = "Misc", Icon = "wrench", Count = 26 })
Window:CreateTab({ Name = "Movement", Icon = "movement", Count = 11 })
Window:CreateTab({ Name = "Spear", Icon = "sword", Count = 4 })
Window:CreateTab({ Name = "Visual", Icon = "eye", Count = 24 })

-- GENERAL (Sidebar unten)
Window:CreateTab({ Name = "Settings", Icon = "menu", Group = "GENERAL" })
Window:CreateTab({ Name = "Theme", Icon = "palette", Group = "GENERAL" })
Window:CreateTab({ Name = "Configs", Icon = "folder", Group = "GENERAL" })
Window:CreateTab({ Name = "Socials", Icon = "users", Group = "GENERAL" })
Window:CreateTab({ Name = "Keybinds", Icon = "keyboard", Group = "GENERAL" })

-- Eigene Section statt MODULES/GENERAL (String oder Handle)
local Farm = Window:CreateSection("Auto Farm")
local Money = Window:CreateTab({ Name = "Money", Title = "Money Modules", Icon = "coins", Count = 8, Section = Farm })
Window:CreateTab({ Name = "Crops", Icon = "wheat", Count = 5, Section = "Auto Farm" })

local MoneyPage = Money:CreatePage({ Name = "Auto Farm" })
MoneyPage:AddToggle({
	Name = "Auto Collect",
	Description = "Collects money automatically.",
	Default = true,
	Callback = print,
})
MoneyPage:AddSlider({
	Name = "Radius",
	Min = 0, Max = 100, Default = 25,
	Callback = function(v) print("Radius:", v) end,
})

-- Combat-Module (Rows wie im Screenshot)
local AutoCrystal = Combat:CreatePage({ Name = "Auto Crystal" })

AutoCrystal:AddToggle({
	Name = "Auto Crystal",
	Description = "Automatically places and explodes crystals.",
	Default = false,
	Callback = print,
})
AutoCrystal:AddToggle({
	Name = "Damage Tick",
	Description = "Breaks crystals only when they deal damage.",
	Default = false,
	Callback = print,
})
AutoCrystal:AddToggle({
	Name = "Pause On Kill",
	Description = "Pauses while a dead body is nearby.",
	Default = true,
	Callback = print,
})
AutoCrystal:AddRangeSlider({
	Name = "Delay",
	Description = "Waits a random time in this range between actions (ms).",
	Min = 0, Max = 500, MinDefault = 30, MaxDefault = 130,
	Decimals = 1,
	Callback = function(a, b) print("Delay:", a, b) end,
})
AutoCrystal:AddToggle({
	Name = "Switch",
	Description = "Switches to crystals when the module enables.",
	Default = false,
	Callback = print,
})
AutoCrystal:AddToggle({
	Name = "Head Bob",
	Description = "Updates your pitch server-side to break crystals above or below.",
	Default = false,
	Callback = print,
})
AutoCrystal:AddToggle({
	Name = "Render",
	Description = "Outlines the crystal being targeted.",
	Default = true,
	Callback = print,
})
AutoCrystal:AddColorpicker({
	Name = "Color",
	Description = "Sets the crystal outline color.",
	Default = Color3.fromRGB(124, 106, 255),
	Callback = print,
})
AutoCrystal:AddToggle({
	Name = "Always Break Last",
	Description = "When disabled, finishes breaking the crystal under your crosshair before turning off.",
	Default = true,
	Callback = print,
})

Window:Notify({ Title = "Prestige Client", Description = "UI geladen. RightShift = ein-/ausblenden.", Duration = 3 })
