--// sable example - baut das UI aus deinem Screenshot nach
local Sable = loadstring(game:HttpGet("https://raw.githubusercontent.com/Valox321/Custom-UI/refs/heads/main/SableLib.lua"))()
-- lokal testen: local Sable = loadstring(readfile("SableLib.lua"))()

local Window = Sable:CreateWindow({
	Name = "sable",
	ToggleKey = Enum.KeyCode.RightShift,
})

-- BOTTOM NAV (wie im Bild unten) - mit Lucide Icons
-- Alle Lucide Namen gehen, z.B. "house", "crosshair", "gem", "user", "map-pin", "eye", "bell", "settings"
-- Übersicht: https://lucide.dev/icons
local Main = Window:CreateTab({ Name = "Main", Icon = "house" })
Window:CreateTab({ Name = "", Icon = "crosshair", IconOnly = true })
Window:CreateTab({ Name = "", Icon = "gem", IconOnly = true })
Window:CreateTab({ Name = "", Icon = "user", IconOnly = true })
Window:CreateTab({ Name = "", Icon = "map-pin", IconOnly = true })
Window:CreateTab({ Name = "", Icon = "eye", IconOnly = true })
Window:CreateTab({ Name = "", Icon = "bell", IconOnly = true })
Window:CreateTab({ Name = "", Icon = "settings", IconOnly = true })

-- TOP PILLS (wie im Bild oben) - mit Lucide Icons
local LevelUp = Main:CreatePage({ Name = "Level Up", Icon = "trending-up" })
local Mobs = Main:CreatePage({ Name = "Mobs", Icon = "skull" })
local Bosses = Main:CreatePage({ Name = "Bosses", Icon = "crown" })

-- CONTENT: Level Up Seite
LevelUp:AddToggle({
	Name = "1 Click Level Up",
	Description = "Takes the best quest, kills what it asks for, hands it in, repeats.",
	Default = false,
	Callback = function(v) print("1 Click Level Up:", v) end,
})

LevelUp:AddToggle({
	Name = "Auto Quest",
	Description = "Accepts the quest picked below and hunts its targets. Teleports to the quest giver by itself.",
	Default = false,
	Callback = function(v) print("Auto Quest:", v) end,
})

LevelUp:AddDropdown({
	Name = "Quest",
	Description = "Which quest Auto Quest takes. Best for my level always picks the highest one you qualify...",
	Options = { "Best for my level", "Bandits", "Monkeys", "Gorillas" },
	Default = "Best for my level",
	Callback = function(v) print("Quest:", v) end,
})

LevelUp:AddButton({
	Name = "Refresh Quests",
	Description = "Rebuilds the quest list from the game.",
	Text = "Click",
	Callback = function()
		Window:Notify({ Title = "sable", Description = "Quest list refreshed." })
	end,
})

local questLabel = LevelUp:AddLabel({
	Name = "Quest",
	Description = "The quest you are on right now.",
	Value = "Ill take 3 bandits",
})

local prog = LevelUp:AddProgress({ Name = "Progress", Value = 0.35 })
-- Beispiel: prog:Set(0.7)
-- Beispiel: questLabel:Set("Neuer Text")

-- CONTENT: andere Seiten (Beispiel) - alle Elements aus deinem Bild
Mobs:AddSection({ Name = "Farming" })

Mobs:AddParagraph({
	Title = "How it works",
	Body = "Auto Farm nimmt die Mobs aus der Liste unten und farmt sie der Reihe nach ab.",
})

Mobs:AddToggle({
	Name = "Auto Farm Mobs",
	Description = "Farms all nearby mobs automatically.",
	Default = false,
	Callback = function(v) print(v) end,
})

Mobs:AddSlider({
	Name = "Farm Distance",
	Min = 0,
	Max = 200,
	Default = 80,
	Callback = function(v) print(v) end,
})

Mobs:AddDropdown({
	Name = "Mob",
	Description = "Which mob to farm.",
	Options = { "Bandit", "Monkey", "Gorilla" },
	Default = "Bandit",
	Callback = function(v) print(v) end,
})

Mobs:AddInput({
	Name = "Webhook",
	Description = "Discord webhook for notifications.",
	Placeholder = "https://discord.com/api/...",
	Default = "",
	Callback = function(v) print("input:", v) end,
})

Mobs:AddKeybind({
	Name = "Farm Key",
	Description = "Press to toggle farming.",
	Default = Enum.KeyCode.F,
	Callback = function(k) print("key:", k) end,
})

Mobs:AddColorpicker({
	Name = "ESP Color",
	Description = "Color for mob ESP.",
	Default = Color3.fromRGB(242, 226, 184),
	Callback = function(c) print(c) end,
})

Mobs:AddCode({
	Title = "Config",
	Code = "getgenv().Farm = true\n-- edit me",
})

Bosses:AddSection({ Name = "Bosses" })

Bosses:AddToggle({
	Name = "Auto Boss",
	Description = "Teleports to boss and attacks.",
	Default = false,
	Callback = function(v) print(v) end,
})

Bosses:AddButton({
	Name = "Kill All Bosses",
	Description = "One-shot test button.",
	Text = "Kill",
	Callback = function() Window:Notify({ Title = "sable", Description = "done" }) end,
})
