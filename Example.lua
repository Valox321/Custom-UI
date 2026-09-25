--// sable example - 1:1 wie Referenzbild
local Sable = loadstring(game:HttpGet("https://raw.githubusercontent.com/Valox321/Custom-UI/refs/heads/main/SableLib.lua?" .. tick()))()
print("[sable] lib version:", Sable.Version or "?")

local Window = Sable:CreateWindow({
	Name = "Sabie",
	ToggleKey = Enum.KeyCode.RightShift,
})

local Throwing = Window:CreateTab({ Name = "Throwing", Icon = "pencil-ruler" })
local TimingTab = Window:CreateTab({ Name = "Timing", Icon = "timer" })
local Protection = Window:CreateTab({ Name = "Protection", Icon = "shield" })
local Profile = Window:CreateTab({ Name = "Profile", Icon = "user" })
local Emotes = Window:CreateTab({ Name = "Emotes", Icon = "smile" })
local Settings = Window:CreateTab({ Name = "Settings", Icon = "settings" })

local QB = Throwing:CreatePage({ Name = "QB Aimbot", Icon = "crosshair" })
local Smart = Throwing:CreatePage({ Name = "Smart Fit", Icon = "brain" })
local Reach = Throwing:CreatePage({ Name = "Reach & Timing", Icon = "timer" })

QB:AddToggle({
	Name = "Quarterback Aimbot",
	Description = "Aims and throws for you, the way it always has.",
	Default = false,
	Callback = print,
})
QB:AddToggle({
	Name = "Anti OOB",
	Description = "Stops throws that would land out of bounds.",
	Default = false,
	Callback = print,
})
QB:AddToggle({
	Name = "Auto Angle",
	Description = "Works the throw angle out for you.",
	Default = true,
	Callback = print,
})
QB:AddToggle({
	Name = "Auto Throw Type",
	Description = "Picks the throw type to suit the pass.",
	Default = false,
	Callback = print,
})
QB:AddToggle({
	Name = "Auto Power",
	Description = "Sets the throw power automatically.",
	Default = true,
	Callback = print,
})

Smart:AddToggle({
	Name = "Smart Fit",
	Description = "Fits the throw to your receiver.",
	Default = false,
	Callback = print,
})
Smart:AddToggle({
	Name = "Auto Adjust",
	Description = "Adjusts for wind and distance.",
	Default = false,
	Callback = print,
})

Reach:AddToggle({
	Name = "Reach Assist",
	Description = "Helps you reach further throws.",
	Default = false,
	Callback = print,
})
Reach:AddSlider({
	Name = "Timing Window",
	Min = 0,
	Max = 100,
	Default = 50,
	Callback = print,
})

local TPage = TimingTab:CreatePage({ Name = "Timing", Icon = "timer" })
TPage:AddToggle({ Name = "Perfect Release", Description = "Times your release perfectly.", Default = false, Callback = print })

local PPage = Protection:CreatePage({ Name = "Protection", Icon = "shield" })
PPage:AddToggle({ Name = "Block Shed", Description = "Sheds incoming blocks.", Default = false, Callback = print })

local PrPage = Profile:CreatePage({ Name = "Profile", Icon = "user" })
PrPage:AddToggle({ Name = "Show Stats", Description = "Shows your stats overlay.", Default = false, Callback = print })

local EPage = Emotes:CreatePage({ Name = "Emotes", Icon = "smile" })
EPage:AddToggle({ Name = "Auto Celebration", Description = "Celebrates after touchdowns.", Default = false, Callback = print })

local SPage = Settings:CreatePage({ Name = "Settings", Icon = "settings" })
SPage:AddToggle({ Name = "Notifications", Description = "Shows status notifications.", Default = true, Callback = print })
SPage:AddKeybind({
	Name = "Menu Key",
	Description = "Opens and closes the menu.",
	Default = Enum.KeyCode.RightShift,
	Callback = function(k)
		if not Window.SetToggleKey then return end
		if Window._toggleKey ~= k then
			Window:SetToggleKey(k)
			Window:Notify({ Title = "Sabie", Description = "Menu key: " .. k.Name })
		end
	end,
})
