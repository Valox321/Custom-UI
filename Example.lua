-- This requires an environment where loadstring and game:HttpGet are enabled.
local LibraryUrl = "https://raw.githubusercontent.com/Valox321/Custom-UI/main/PrestigeLib.lua"
local PrestigeUI = assert(loadstring(game:HttpGet(LibraryUrl)), "Failed to compile PrestigeLib")()

local Window = PrestigeUI.CreateWindow({
	Title = "Prestige Client",
	Subtitle = "UI LIBRARY EXAMPLE",
	Tabs = {},
})

local Combat = Window:AddTab({
	Name = "Combat",
	Icon = "⚔",
	Count = 3,
})

local Targeting = Combat:AddSection("Targeting")

Targeting:AddToggle("Aim Assist", {
	Description = "Example toggle with an enabled-state callback",
	Default = false,
	Callback = function(enabled)
		print("Aim Assist:", enabled)
	end,
})

Targeting:AddToggle("Target Friends", {
	Description = "Include friends in the target filter",
	Default = true,
	Callback = function(enabled)
		print("Target Friends:", enabled)
	end,
})

local Actions = Combat:AddSection("Actions")

Actions:AddButton({
	Name = "Clear Targets",
	Description = "Example action button",
	ButtonText = "Clear",
	Callback = function()
		print("Clear Targets clicked")
	end,
})

local Settings = Window:AddTab({
	Name = "Settings",
	Icon = "⚙",
	Count = 1,
})

local Interface = Settings:AddSection("Interface")

Interface:AddToggle("Show Notifications", {
	Description = "Enable or disable UI notifications",
	Default = true,
	Callback = function(enabled)
		print("Show Notifications:", enabled)
	end,
})
