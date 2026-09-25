--// sable example: Elements-Galerie (SableLib 1.19+)
--// Je ein Tab pro Control-Typ in der Section "ELEMENTS"
--// WICHTIG: immer DIESE Datei ausfuehren (Repo-Stand), keine alte Kopie!
--// Lib-URL ist auf den Commit gepinnt (immer exakt diese Version, kein CDN-Lag)
local URL = "https://cdn.jsdelivr.net/gh/Valox321/Custom-UI@7c944aeaca3ab1db64d01a62df807ae556dd80b6/SableLib.lua"
local src = game:HttpGet(URL, true)
print("[sable] bytes:", #src, "| 1.28 drin:", src:find('Version = "1.28"', 1, true) ~= nil)
local Sable = loadstring(src)()
print("[sable] lib version:", Sable.Version or "?")

local Window = Sable:CreateWindow({
	Name = "Valox Alpha",
	Version = "BETA RELEASE 4.3.0",
	Icon = "121040200759967",
	ToggleKey = Enum.KeyCode.RightShift,
	SearchPlaceholder = "Search modules",
})

-- ELEMENTS: je ein Tab pro Control-Typ
Window:CreateSection("Elements")

local TglTab = Window:CreateTab({ Name = "Toggle", Icon = "toggle-right", Section = "Elements" })
local TglPage = TglTab:CreatePage({ Name = "Toggle" })
TglPage:AddToggle({ Name = "Enabled", Description = "Schaltet etwas an/aus.", Default = false, Callback = print })
TglPage:AddToggle({ Name = "Checkbox", Description = "Type = checkbox statt Switch.", Default = true, Type = "checkbox", Callback = print })

local SldTab = Window:CreateTab({ Name = "Slider", Icon = "sliders-horizontal", Section = "Elements" })
local SldPage = SldTab:CreatePage({ Name = "Slider" })
SldPage:AddSlider({ Name = "Volume", Min = 0, Max = 100, Default = 50, Callback = function(v) print("Volume:", v) end })
SldPage:AddSlider({ Name = "Delay", Min = 0, Max = 500, Default = 100, Callback = function(v) print("Delay:", v) end })

local RngTab = Window:CreateTab({ Name = "Range", Icon = "ruler", Section = "Elements" })
local RngPage = RngTab:CreatePage({ Name = "RangeSlider" })
RngPage:AddRangeSlider({ Name = "Delay", Description = "Zwei Knobs, ein Callback.", Min = 0, Max = 500, MinDefault = 30, MaxDefault = 130, Decimals = 1, Callback = function(a, b) print("Range:", a, b) end })

local DrpTab = Window:CreateTab({ Name = "Dropdown", Icon = "chevron-down", Section = "Elements" })
local DrpPage = DrpTab:CreatePage({ Name = "Dropdown" })
DrpPage:AddDropdown({ Name = "Mode", Description = "Single-Select mit Suche.", Options = { "Normal", "Legit", "Rage" }, Default = "Normal", Callback = function(v) print("Mode:", v) end })

local BtnTab = Window:CreateTab({ Name = "Button", Icon = "plus", Section = "Elements" })
local BtnPage = BtnTab:CreatePage({ Name = "Button" })
BtnPage:AddButton({ Name = "Klick mich", Description = "Feuert den Callback.", Text = "Click", Callback = function() Window:Notify({ Title = "Button", Description = "Geklickt!", Duration = 2 }) end })

local InpTab = Window:CreateTab({ Name = "Input", Icon = "type", Section = "Elements" })
local InpPage = InpTab:CreatePage({ Name = "Input" })
InpPage:AddInput({ Name = "Username", Description = "Callback bei Enter.", Default = "", Placeholder = "Enter username...", Callback = function(v) print("Input:", v) end })

local KeyTab = Window:CreateTab({ Name = "Keybind", Icon = "zap", Section = "Elements" })
local KeyPage = KeyTab:CreatePage({ Name = "Keybind" })
KeyPage:AddKeybind({ Name = "Toggle UI", Description = "Klick, dann Taste druecken.", Default = Enum.KeyCode.RightShift, Callback = function(k) print("Key:", k) end })

local ColTab = Window:CreateTab({ Name = "Color", Icon = "paintbrush", Section = "Elements" })
local ColPage = ColTab:CreatePage({ Name = "Colorpicker" })
ColPage:AddColorpicker({ Name = "Accent", Description = "Hex + Regler im Popup.", Default = Color3.fromRGB(124, 106, 255), Callback = function(c) print("Color:", c) end })
ColPage:AddLabel({ Name = "Hinweis", Description = "So sieht ein Label aus.", Value = "rechts" })

Window:Notify({ Title = "Prestige Client", Description = "UI geladen. RightShift = ein-/ausblenden.", Duration = 3 })
