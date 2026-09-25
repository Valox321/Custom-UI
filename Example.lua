--// sable example - jedes Feature hat ein eigenes Bottom-Tab
local Sable = loadstring(game:HttpGet("https://raw.githubusercontent.com/Valox321/Custom-UI/refs/heads/main/SableLib.lua?" .. tick()))()
-- lokal testen: local Sable = loadstring(readfile("SableLib.lua"))()

local Window = Sable:CreateWindow({
	Name = "sable",
	ToggleKey = Enum.KeyCode.RightShift,
})

-- BOTTOM NAV: pro Feature ein Tab (Lucide-Namen, Übersicht: https://lucide.dev/icons)
local Main = Window:CreateTab({ Name = "Main", Icon = "house" })
local BtnTab = Window:CreateTab({ Name = "Button", Icon = "mouse-pointer-click" })
local ToggleTab = Window:CreateTab({ Name = "Toggle", Icon = "toggle-left" })
local SliderTab = Window:CreateTab({ Name = "Slider", Icon = "sliders-horizontal" })
local DropTab = Window:CreateTab({ Name = "Dropdown", Icon = "list" })
local InputTab = Window:CreateTab({ Name = "Input", Icon = "keyboard" })
local KeyTab = Window:CreateTab({ Name = "Keybind", Icon = "command" })
local ColorTab = Window:CreateTab({ Name = "Color", Icon = "palette" })
local CodeTab = Window:CreateTab({ Name = "Code", Icon = "code" })
local TextTab = Window:CreateTab({ Name = "Text", Icon = "type" })

-- MAIN: Screenshot-Demo mit Top-Pills
local LevelUp = Main:CreatePage({ Name = "Level Up", Icon = "trending-up" })
local Mobs = Main:CreatePage({ Name = "Mobs", Icon = "skull" })
local Bosses = Main:CreatePage({ Name = "Bosses", Icon = "crown" })

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

LevelUp:AddLabel({
	Name = "Quest",
	Description = "The quest you are on right now.",
	Value = "Ill take 3 bandits",
})

LevelUp:AddProgress({ Name = "Progress", Value = 0.35 })

Mobs:AddSection({ Name = "Farming" })
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

Bosses:AddSection({ Name = "Bosses" })
Bosses:AddToggle({
	Name = "Auto Boss",
	Description = "Teleports to boss and attacks.",
	Default = false,
	Callback = function(v) print(v) end,
})

-- JEDE FEATURE-SEITE
local P1 = BtnTab:CreatePage({ Name = "Buttons", Icon = "mouse-pointer-click" })
P1:AddSection({ Name = "Button" })
P1:AddButton({ Name = "Refresh Quests", Description = "Beispiel aus Main.", Text = "Click", Callback = function() Window:Notify({ Title = "sable", Description = "clicked" }) end })
P1:AddButton({ Name = "Kill All Bosses", Description = "Zweiter Button.", Text = "Kill", Callback = function() print("kill") end })

local P2 = ToggleTab:CreatePage({ Name = "Toggles", Icon = "toggle-left" })
P2:AddSection({ Name = "Toggle" })
P2:AddToggle({ Name = "1 Click Level Up", Description = "Toggle an/aus.", Default = false, Callback = print })
P2:AddToggle({ Name = "Auto Quest", Description = "Zweites Toggle.", Default = true, Callback = print })

local P3 = SliderTab:CreatePage({ Name = "Sliders", Icon = "sliders-horizontal" })
P3:AddSection({ Name = "Slider" })
P3:AddSlider({ Name = "Farm Distance", Min = 0, Max = 200, Default = 80, Callback = print })
P3:AddSlider({ Name = "Speed", Min = 16, Max = 200, Default = 16, Callback = print })

local P4 = DropTab:CreatePage({ Name = "Dropdowns", Icon = "list" })
P4:AddSection({ Name = "Dropdown" })
P4:AddDropdown({ Name = "Quest", Description = "Eigene Dropdown-Seite.", Options = { "Best for my level", "Bandits", "Monkeys", "Gorillas" }, Default = "Best for my level", Callback = print })
P4:AddDropdown({ Name = "Mob", Description = "Zweites Dropdown.", Options = { "Bandit", "Monkey", "Gorilla" }, Default = "Bandit", Callback = print })

local P5 = InputTab:CreatePage({ Name = "Inputs", Icon = "keyboard" })
P5:AddSection({ Name = "Input" })
P5:AddInput({ Name = "Webhook", Description = "Enter drücken zum Übernehmen.", Placeholder = "https://discord.com/api/...", Default = "", Callback = print })
P5:AddInput({ Name = "Name", Description = "Zweites Input.", Placeholder = "Type here...", Default = "Valox", Callback = print })

local P6 = KeyTab:CreatePage({ Name = "Keybinds", Icon = "command" })
P6:AddSection({ Name = "Keybind" })
P6:AddKeybind({ Name = "Farm Key", Description = "Klick auf Taste, dann neue Taste drücken.", Default = Enum.KeyCode.F, Callback = print })
P6:AddKeybind({ Name = "Menu Key", Description = "Zweiter Keybind.", Default = Enum.KeyCode.RightShift, Callback = print })

local P7 = ColorTab:CreatePage({ Name = "Colors", Icon = "palette" })
P7:AddSection({ Name = "Colorpicker" })
P7:AddColorpicker({ Name = "ESP Color", Description = "WindUI-Style mit SV + Hex/RGB + Apply.", Default = Color3.fromRGB(48, 255, 106), Callback = print })
P7:AddColorpicker({ Name = "Accent", Description = "Zweiter Picker.", Default = Color3.fromRGB(242, 226, 184), Callback = print })

local P8 = CodeTab:CreatePage({ Name = "Code", Icon = "code" })
P8:AddSection({ Name = "Code" })
P8:AddCode({ Title = "Config", Code = "getgenv().Farm = true\n-- edit me" })
P8:AddCode({ Title = "Script", Code = "print('hello')" })

local P9 = TextTab:CreatePage({ Name = "Text", Icon = "type" })
P9:AddSection({ Name = "Section + Paragraph + Label" })
P9:AddParagraph({ Title = "How it works", Body = "Paragraph für längere Erklärungen. Section oben trennt Gruppen." })
P9:AddLabel({ Name = "Quest", Description = "Label mit Wert rechts.", Value = "Ill take 3 bandits" })
P9:AddProgress({ Name = "Progress", Value = 0.6 })
