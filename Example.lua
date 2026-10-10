-- Put PrestigeUI.luau in ReplicatedStorage as a ModuleScript named PrestigeUI,
-- then run this file as a LocalScript in StarterPlayerScripts.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PrestigeUI = require(ReplicatedStorage:WaitForChild("PrestigeUI"))

local Window = PrestigeUI:CreateWindow({
	Title = "Prestige Client",
	Footer = "BETA RELEASE 4.3.0",
	Size = UDim2.fromOffset(1040, 700),
	Center = true,
	AutoShow = true,
	ToggleKeybind = Enum.KeyCode.RightControl,
	Theme = {
		AccentColor = Color3.fromRGB(132, 116, 255),
	},
})

local Combat = Window:AddTab("Combat", "⚔", "Combat interface controls")
local Visual = Window:AddTab("Visual", "◉", "Overlay appearance")
local Settings = Window:AddTab("Settings", "⚙", "Library settings")

local basics = Combat:AddLeftGroupbox("Basic Controls")
local enabled = basics:AddToggle("OverlayEnabled", {
	Text = "Enable overlay",
	Description = "Turns the sample overlay on or off.",
	Default = true,
	Callback = function(value)
		print("Overlay enabled:", value)
	end,
})

enabled:AddKeyPicker("OverlayKey", {
	Default = Enum.KeyCode.G,
	Mode = "Toggle",
	Text = "Overlay key",
	SyncToggleState = true,
})

basics:AddSlider("Opacity", {
	Text = "Opacity",
	Description = "Adjusts the overlay opacity.",
	Min = 0,
	Max = 100,
	Default = 75,
	Rounding = 0,
	Suffix = "%",
	Callback = function(value)
		print("Opacity:", value)
	end,
})

basics:AddDropdown("DisplayMode", {
	Text = "Display mode",
	Description = "Select how the interface is displayed.",
	Values = { "Compact", "Comfortable", "Expanded" },
	Default = 2,
	Callback = function(value)
		print("Display mode:", value)
	end,
})

basics:AddInput("ProfileName", {
	Text = "Profile name",
	Description = "A name for your local UI preset.",
	Placeholder = "My profile",
	Default = "Prestige",
	Finished = true,
	Callback = function(value)
		print("Profile:", value)
	end,
})

basics:AddButton({
	Text = "Show notification",
	ButtonText = "Notify",
	Func = function()
		Window:Notify("Your settings are ready.", 3)
	end,
})

local extra = Combat:AddRightGroupbox("Advanced")
extra:AddToggle("ShowHints", {
	Text = "Show hints",
	Description = "Displays short tips beside controls.",
	Default = false,
	Callback = function(value)
		print("Hints:", value)
	end,
})
extra:AddSlider("AnimationSpeed", {
	Text = "Animation speed",
	Min = 0.1,
	Max = 1,
	Default = 0.35,
	Rounding = 2,
	Suffix = " s",
})
extra:AddLabel({ Text = "Controls can be grouped into either column.", DoesWrap = true })

local appearance = Visual:AddLeftGroupbox("Appearance")
appearance:AddColorPicker("Accent", {
	Text = "Accent color",
	Description = "Pick a color from the palette.",
	Default = Color3.fromRGB(132, 116, 255),
	Callback = function(color)
		Window:SetAccent(color)
	end,
})

appearance:AddSlider("Scale", {
	Text = "UI scale",
	Min = 80,
	Max = 120,
	Default = 100,
	Suffix = "%",
	Rounding = 0,
	Callback = function(value)
		print("UI scale:", value)
	end,
})

local librarySettings = Settings:AddLeftGroupbox("Library")
librarySettings:AddLabel({
	Text = "Press Right Control to show or hide this window.",
	DoesWrap = true,
})
librarySettings:AddDivider()
librarySettings:AddKeybind("QuickAction", {
	Text = "Quick action",
	Description = "Choose a key to trigger the callback.",
	Default = Enum.KeyCode.H,
	Mode = "Toggle",
	Callback = function()
		Window:Notify("Quick action triggered.", 2)
	end,
})

