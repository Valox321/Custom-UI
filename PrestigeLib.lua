-- Prestige-style UI library for Roblox LocalScripts.
-- This library only renders UI; module behavior is supplied by callbacks.
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local PrestigeUI = {}
PrestigeUI.__index = PrestigeUI
local TabMethods = {}
TabMethods.__index = TabMethods
local SectionMethods = {}
SectionMethods.__index = SectionMethods

local COLORS = {
	Window = Color3.fromRGB(7, 9, 24),
	Sidebar = Color3.fromRGB(11, 14, 34),
	Card = Color3.fromRGB(16, 19, 42),
	Input = Color3.fromRGB(9, 12, 30),
	Border = Color3.fromRGB(43, 49, 78),
	Text = Color3.fromRGB(238, 239, 255),
	Secondary = Color3.fromRGB(153, 155, 184),
	Muted = Color3.fromRGB(99, 102, 130),
	Accent = Color3.fromRGB(126, 127, 246),
	AccentDark = Color3.fromRGB(54, 56, 111),
	ToggleOff = Color3.fromRGB(21, 23, 43),
}

local DEFAULT_TABS = {
	{ Name = "Combat", Icon = "⚔", Count = 39 },
	{ Name = "Mace", Icon = "◆", Count = 13 },
	{ Name = "Misc", Icon = "⌕", Count = 26 },
	{ Name = "Movement", Icon = "↗", Count = 11 },
	{ Name = "Spear", Icon = "╱", Count = 4 },
	{ Name = "Visual", Icon = "◉", Count = 24 },
}

local DEFAULT_MODULES = {
	{ Name = "Aim Assist", Description = "Aims at targets" },
	{ Name = "Anchor Exploder", Description = "Automatically explodes respawn anchors for you" },
	{ Name = "Anchor Macro", Description = "Explodes and places anchors automatically" },
	{ Name = "Anchor Placer", Description = "Automatically places respawn anchors for you" },
	{ Name = "Anti Action", Description = "Prevents certain bad actions from interrupting your pvp" },
	{ Name = "Anti Bot", Description = "Removes bots from the game" },
	{ Name = "Auto Crystal", Description = "Automatically places and explodes crystals" },
	{ Name = "Auto Totem", Description = "Automatically moves totems into your offhand" },
	{ Name = "Criticals", Description = "Forces critical hits on every attack" },
	{ Name = "Kill Aura", Description = "Automatically attacks nearby players" },
	{ Name = "Velocity", Description = "Modifies your knockback taken" },
	{ Name = "W-Tap", Description = "Perfectly times your sprint resets for combos" },
}

local function create(className, properties, parent)
	local instance = Instance.new(className)
	for property, value in pairs(properties) do
		instance[property] = value
	end
	instance.Parent = parent
	return instance
end

local function addCorner(parent, radius)
	create("UICorner", { CornerRadius = UDim.new(0, radius) }, parent)
end

local function addStroke(parent, color, transparency)
	return create("UIStroke", {
		Color = color,
		Transparency = transparency or 0,
		Thickness = 1,
	}, parent)
end

local function makeLabel(parent, text, size, color, font, properties)
	local values = {
		BackgroundTransparency = 1,
		Font = font or Enum.Font.Gotham,
		Text = text or "",
		TextColor3 = color or COLORS.Text,
		TextSize = size or 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
	}
	for key, value in pairs(properties or {}) do
		values[key] = value
	end
	return create("TextLabel", values, parent)
end

local function tween(instance, duration, properties)
	local animation = TweenService:Create(
		instance,
		TweenInfo.new(duration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
		properties
	)
	animation:Play()
	return animation
end

local function setToggleVisual(track, knob, enabled, animate)
	local color = enabled and COLORS.Accent or COLORS.ToggleOff
	local position = enabled and UDim2.new(1, -21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
	if animate then
		tween(track, 0.16, { BackgroundColor3 = color })
		tween(knob, 0.2, { Position = position })
	else
		track.BackgroundColor3 = color
		knob.Position = position
	end
end

function PrestigeUI:SelectTab(tab)
	if not tab then
		return
	end
	self.SelectedTab = tab
	self.SearchBox.Text = ""
	self:_renderModules()
	for itemTab, button in pairs(self.TabButtons) do
		local selected = itemTab == tab
		button.BackgroundColor3 = selected and COLORS.AccentDark or COLORS.Sidebar
		button.BackgroundTransparency = selected and 0 or 1
		local labels = self.TabLabels[itemTab]
		if labels then
			labels.Icon.TextColor3 = selected and COLORS.Accent or COLORS.Secondary
			labels.Name.TextColor3 = selected and COLORS.Text or COLORS.Secondary
		end
		local count = self.TabCounts[itemTab]
		if count then
			count.TextColor3 = selected and Color3.fromRGB(188, 190, 255) or COLORS.Muted
		end
	end
end

function PrestigeUI:_renderModules()
	for _, child in ipairs(self.List:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	local query = string.lower(self.SearchBox.Text)
	local shownCount = 0
	local activeSection = nil

	for _, moduleData in ipairs(self.SelectedTab.Modules) do
		local searchable = string.lower(moduleData.Name .. " " .. (moduleData.Description or ""))
		if query == "" or string.find(searchable, query, 1, true) then
			if moduleData.Section and moduleData.Section ~= activeSection then
				activeSection = moduleData.Section
				shownCount = shownCount + 1
				local heading = create("TextLabel", {
					Name = "SectionHeading",
					BackgroundTransparency = 1,
					Font = Enum.Font.GothamMedium,
					Text = activeSection.Name,
					TextColor3 = COLORS.Muted,
					TextSize = 11,
					TextXAlignment = Enum.TextXAlignment.Left,
					Size = UDim2.new(1, -2, 0, 24),
					LayoutOrder = shownCount,
				}, self.List)
			end
			shownCount = shownCount + 1

			local card = create("Frame", {
				Name = "ModuleCard",
				BackgroundColor3 = COLORS.Card,
				BackgroundTransparency = 0.06,
				Size = UDim2.new(1, -2, 0, 80),
				LayoutOrder = shownCount,
			}, self.List)
			addCorner(card, 11)
			addStroke(card, COLORS.Border, 0.32)

			local title = makeLabel(card, moduleData.Name, 16, COLORS.Text, Enum.Font.GothamBold, {
				Position = UDim2.new(0, 18, 0, 16),
				Size = UDim2.new(1, -160, 0, 22),
			})
			title.ZIndex = 2
			local description = makeLabel(card, moduleData.Description or "", 12, COLORS.Muted, Enum.Font.Gotham, {
				Position = UDim2.new(0, 18, 0, 41),
				Size = UDim2.new(1, -160, 0, 18),
				TextTruncate = Enum.TextTruncate.AtEnd,
			})
			description.ZIndex = 2

			local arrow = makeLabel(card, "›", 22, COLORS.Secondary, Enum.Font.Gotham, {
				AnchorPoint = Vector2.new(1, 0.5),
				Position = UDim2.new(1, -72, 0.5, 0),
				Size = UDim2.new(0, 20, 0, 28),
				TextXAlignment = Enum.TextXAlignment.Center,
			})
			arrow.ZIndex = 2

			if moduleData.Kind == "button" then
				local action = create("TextButton", {
					Name = "ActionButton",
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, -16, 0.5, 0),
					Size = UDim2.new(0, 92, 0, 30),
					BackgroundColor3 = COLORS.AccentDark,
					BorderSizePixel = 0,
					Font = Enum.Font.GothamMedium,
					Text = moduleData.ButtonText or "Run",
					TextColor3 = COLORS.Text,
					TextSize = 12,
					AutoButtonColor = false,
				}, card)
				addCorner(action, 8)
				action.Activated:Connect(function()
					if moduleData.Callback then
						moduleData.Callback()
					end
				end)
			else
				local track = create("Frame", {
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, -16, 0.5, 0),
					Size = UDim2.new(0, 44, 0, 24),
					BackgroundColor3 = COLORS.ToggleOff,
					BorderSizePixel = 0,
				}, card)
				addCorner(track, 12)
				addStroke(track, COLORS.Border, 0.38)
				local knob = create("Frame", {
					AnchorPoint = Vector2.new(0, 0.5),
					Position = UDim2.new(0, 3, 0.5, 0),
					Size = UDim2.new(0, 18, 0, 18),
					BackgroundColor3 = COLORS.Text,
					BorderSizePixel = 0,
				}, track)
				addCorner(knob, 9)

				local hitTarget = create("TextButton", {
					Name = "ToggleButton",
					BackgroundTransparency = 1,
					Size = UDim2.new(1, 0, 1, 0),
					Text = "",
					AutoButtonColor = false,
				}, track)
				hitTarget.ZIndex = 3

				moduleData.Enabled = moduleData.Enabled == true
				setToggleVisual(track, knob, moduleData.Enabled, false)
				hitTarget.Activated:Connect(function()
					moduleData.Enabled = not moduleData.Enabled
					setToggleVisual(track, knob, moduleData.Enabled, true)
					self:_updateCount()
					if moduleData.Callback then
						moduleData.Callback(moduleData.Enabled)
					end
				end)
			end

			card.MouseEnter:Connect(function()
				tween(card, 0.14, { BackgroundColor3 = Color3.fromRGB(21, 25, 53) })
			end)
			card.MouseLeave:Connect(function()
				tween(card, 0.14, { BackgroundColor3 = COLORS.Card })
			end)
		end
	end

	self.VisibleCount = shownCount
	self:_updateCount()
end

function PrestigeUI:_updateCount()
	if not self.SelectedTab then
		return
	end
	local enabled = 0
	for _, moduleData in ipairs(self.SelectedTab.Modules) do
		if moduleData.Enabled then
			enabled = enabled + 1
		end
	end
	self.CountLabel.Text = string.format("%s modules · %s enabled", tostring(self.SelectedTab.Count or #self.SelectedTab.Modules), enabled)
end

function PrestigeUI:AddTab(name, options)
	if type(name) == "table" then
		options = name
		name = options.Name
	end
	options = options or {}
	local tab = {
		Library = self,
		Name = name,
		Icon = options.Icon or "•",
		Count = options.Count,
		Modules = {},
		Sections = {},
	}
	setmetatable(tab, TabMethods)

	local button = create("TextButton", {
		Name = name .. "Tab",
		BackgroundColor3 = COLORS.Sidebar,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 42),
		Font = Enum.Font.GothamMedium,
		Text = "",
		AutoButtonColor = false,
	}, self.ModuleNav)
	addCorner(button, 10)

	local icon = makeLabel(button, tab.Icon, 17, COLORS.Secondary, Enum.Font.GothamMedium, {
		Position = UDim2.new(0, 12, 0, 0),
		Size = UDim2.new(0, 22, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Center,
	})
	local nameLabel = makeLabel(button, name, 14, COLORS.Secondary, Enum.Font.GothamMedium, {
		Position = UDim2.new(0, 40, 0, 0),
		Size = UDim2.new(1, -82, 1, 0),
	})
	local count = makeLabel(button, tostring(options.Count or 0), 12, COLORS.Muted, Enum.Font.Gotham, {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -12, 0, 0),
		Size = UDim2.new(0, 28, 1, 0),
		TextXAlignment = Enum.TextXAlignment.Right,
	})

	self.Tabs[#self.Tabs + 1] = tab
	self.TabButtons[tab] = button
	self.TabCounts[tab] = count
	self.TabLabels[tab] = { Icon = icon, Name = nameLabel }

	button.Activated:Connect(function()
		self:SelectTab(tab)
	end)
	button.MouseEnter:Connect(function()
		if self.SelectedTab ~= tab then
			tween(button, 0.12, { BackgroundTransparency = 0.55 })
		end
	end)
	button.MouseLeave:Connect(function()
		if self.SelectedTab ~= tab then
			tween(button, 0.12, { BackgroundTransparency = 1 })
		end
	end)

	return tab
end

function PrestigeUI:AddModule(tab, name, description, callback, options)
	assert(tab and tab.Modules, "AddModule expects a tab returned by AddTab")
	assert(type(name) == "string" and name ~= "", "Module name must be a non-empty string")
	options = options or {}
	local moduleData = {
		Name = name,
		Description = description or "",
		Callback = callback,
		Enabled = false,
		Section = options.Section,
		Kind = options.Kind or "toggle",
		ButtonText = options.ButtonText,
	}
	table.insert(tab.Modules, moduleData)
	if self.TabCounts[tab] then
		self.TabCounts[tab].Text = tostring(tab.Count or #tab.Modules)
	end
	if self.SelectedTab == tab then
		self:_renderModules()
	end
	return moduleData
end

function TabMethods:AddSection(name)
	if type(name) == "table" then
		name = name.Name
	end
	assert(type(name) == "string" and name ~= "", "Section name must be a non-empty string")
	local section = setmetatable({
		Tab = self,
		Name = name,
	}, SectionMethods)
	table.insert(self.Sections, section)
	return section
end

function TabMethods:AddGroupbox(options)
	return self:AddSection(options)
end

function SectionMethods:AddToggle(name, options)
	options = options or {}
	local initial = options.Default == true
	local item = self.Tab.Library:AddModule(
		self.Tab,
		name,
		options.Description or "",
		options.Callback,
		{ Section = self }
	)
	item.Enabled = initial
	if self.Tab.Library.SelectedTab == self.Tab then
		self.Tab.Library:_renderModules()
	end
	return item
end

function SectionMethods:AddButton(options)
	assert(type(options) == "table", "AddButton expects an options table")
	return self.Tab.Library:AddModule(
		self.Tab,
		options.Name or options.Title,
		options.Description or "",
		options.Callback,
		{
			Section = self,
			Kind = "button",
			ButtonText = options.ButtonText or options.Text,
		}
	)
end

function PrestigeUI:Destroy()
	if self.DragInputConnection then
		self.DragInputConnection:Disconnect()
		self.DragInputConnection = nil
	end
	if self.DragEndConnection then
		self.DragEndConnection:Disconnect()
		self.DragEndConnection = nil
	end
	if self.ScreenGui then
		self.ScreenGui:Destroy()
		self.ScreenGui = nil
	end
end

function PrestigeUI.CreateWindow(config)
	config = config or {}
	local player = Players.LocalPlayer
	local parent = config.Parent
	if not parent then
		assert(player, "CreateWindow must run on the client or receive config.Parent")
		parent = player:WaitForChild("PlayerGui")
	end

	local self = setmetatable({
		Tabs = {},
		TabButtons = {},
		TabCounts = {},
		TabLabels = {},
		SelectedTab = nil,
	}, PrestigeUI)

	local screenGui = create("ScreenGui", {
		Name = config.Name or "PrestigeUI",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		IgnoreGuiInset = true,
	}, parent)
	self.ScreenGui = screenGui

	local window = create("Frame", {
		Name = "Window",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.new(0.96, 0, 0.94, 0),
		BackgroundColor3 = COLORS.Window,
		BackgroundTransparency = 0.04,
		BorderSizePixel = 0,
		ClipsDescendants = true,
	}, screenGui)
	addCorner(window, 22)
	addStroke(window, Color3.fromRGB(68, 76, 112), 0.56)
	create("UISizeConstraint", {
		MinSize = Vector2.new(640, 440),
		MaxSize = Vector2.new(1170, 744),
	}, window)
	self.Window = window

	local gradient = create("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(14, 17, 38)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(5, 7, 20)),
		}),
		Rotation = 90,
	}, window)
	local sidebar = create("Frame", {
		Name = "Sidebar",
		Position = UDim2.new(0, 13, 0, 13),
		Size = UDim2.new(0, 245, 1, -26),
		BackgroundColor3 = COLORS.Sidebar,
		BackgroundTransparency = 0.03,
		BorderSizePixel = 0,
		ClipsDescendants = true,
	}, window)
	addCorner(sidebar, 16)
	addStroke(sidebar, Color3.fromRGB(66, 74, 111), 0.62)

	local brandIcon = makeLabel(sidebar, "♛", 17, COLORS.Accent, Enum.Font.GothamBold, {
		Position = UDim2.new(0, 17, 0, 12),
		Size = UDim2.new(0, 20, 0, 25),
		TextXAlignment = Enum.TextXAlignment.Center,
	})
	local brand = makeLabel(sidebar, config.Title or "Prestige Client", 19, COLORS.Text, Enum.Font.GothamBold, {
		Position = UDim2.new(0, 43, 0, 9),
		Size = UDim2.new(1, -54, 0, 25),
	})
	local subtitle = makeLabel(sidebar, config.Subtitle or "BETA RELEASE 4.3.0", 10, COLORS.Muted, Enum.Font.GothamMedium, {
		Position = UDim2.new(0, 43, 0, 33),
		Size = UDim2.new(1, -54, 0, 16),
	})
	brandIcon.ZIndex = 2
	brand.ZIndex = 2
	subtitle.ZIndex = 2

	local modulesCaption = makeLabel(sidebar, "MODULES", 11, COLORS.Muted, Enum.Font.GothamMedium, {
		Position = UDim2.new(0, 22, 0, 78),
		Size = UDim2.new(1, -34, 0, 18),
	})
	modulesCaption.TextTransparency = 0.08
	local moduleNav = create("ScrollingFrame", {
		Name = "ModuleTabs",
		Position = UDim2.new(0, 12, 0, 105),
		Size = UDim2.new(1, -24, 0.38, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(),
		ScrollBarThickness = 0,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
	}, sidebar)
	create("UIListLayout", {
		Padding = UDim.new(0, 3),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, moduleNav)
	self.ModuleNav = moduleNav

	local separator = create("Frame", {
		Name = "Separator",
		Position = UDim2.new(0, 22, 0.54, 0),
		Size = UDim2.new(1, -44, 0, 1),
		BackgroundColor3 = COLORS.Border,
		BackgroundTransparency = 0.48,
		BorderSizePixel = 0,
	}, sidebar)
	local generalCaption = makeLabel(sidebar, "GENERAL", 11, COLORS.Muted, Enum.Font.GothamMedium, {
		Position = UDim2.new(0, 22, 0.565, 0),
		Size = UDim2.new(1, -34, 0, 18),
	})

	local generalNav = create("ScrollingFrame", {
		Name = "GeneralNavigation",
		Position = UDim2.new(0, 12, 0.605, 0),
		Size = UDim2.new(1, -24, 0.35, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 0,
	}, sidebar)
	create("UIListLayout", {
		Padding = UDim.new(0, 3),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, generalNav)
	for index, item in ipairs({
		{ "☰", "Settings" },
		{ "✿", "Theme" },
		{ "▱", "Configs" },
		{ "♟", "Socials" },
		{ "⌨", "Keybinds" },
	}) do
		local row = create("TextButton", {
			Name = item[2],
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 42),
			LayoutOrder = index,
			Font = Enum.Font.GothamMedium,
			Text = "",
			AutoButtonColor = false,
		}, generalNav)
		addCorner(row, 9)
		makeLabel(row, item[1], 17, COLORS.Secondary, Enum.Font.GothamMedium, {
			Position = UDim2.new(0, 8, 0, 0),
			Size = UDim2.new(0, 25, 1, 0),
			TextXAlignment = Enum.TextXAlignment.Center,
		})
		makeLabel(row, item[2], 14, COLORS.Secondary, Enum.Font.GothamMedium, {
			Position = UDim2.new(0, 40, 0, 0),
			Size = UDim2.new(1, -48, 1, 0),
		})
		row.MouseEnter:Connect(function()
			tween(row, 0.12, { BackgroundTransparency = 0.72, BackgroundColor3 = COLORS.Border })
		end)
		row.MouseLeave:Connect(function()
			tween(row, 0.12, { BackgroundTransparency = 1 })
		end)
	end

	local main = create("Frame", {
		Name = "Main",
		Position = UDim2.new(0, 275, 0, 13),
		Size = UDim2.new(1, -288, 1, -26),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	}, window)
	self.Main = main

	local title = makeLabel(main, "Combat Modules", 28, COLORS.Text, Enum.Font.GothamBold, {
		Position = UDim2.new(0, 0, 0, 7),
		Size = UDim2.new(0.52, 0, 0, 34),
	})
	title.RichText = true
	title.Text = '<i><font color="#9B9CFF">Combat</font></i> Modules'
	title.Font = Enum.Font.GothamBold

	local countLabel = makeLabel(main, "0 modules · 0 enabled", 14, COLORS.Secondary, Enum.Font.Gotham, {
		Position = UDim2.new(0, 0, 0, 42),
		Size = UDim2.new(0.55, 0, 0, 21),
	})
	self.CountLabel = countLabel

	local dragHandle = create("TextButton", {
		Name = "DragHandle",
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(0.5, 0, 0, 68),
		BackgroundTransparency = 1,
		Text = "",
		AutoButtonColor = false,
		ZIndex = 4,
	}, main)

	local search = create("TextBox", {
		Name = "Search",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 15),
		Size = UDim2.new(0.38, 0, 0, 40),
		BackgroundColor3 = COLORS.Input,
		BackgroundTransparency = 0.08,
		BorderSizePixel = 0,
		ClearTextOnFocus = false,
		Font = Enum.Font.Gotham,
		PlaceholderColor3 = COLORS.Muted,
		PlaceholderText = "⌕   Search modules",
		Text = "",
		TextColor3 = COLORS.Text,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, main)
	addCorner(search, 10)
	addStroke(search, COLORS.Border, 0.36)
	create("UISizeConstraint", {
		MinSize = Vector2.new(160, 40),
		MaxSize = Vector2.new(330, 40),
	}, search)
	create("UIPadding", {
		PaddingLeft = UDim.new(0, 14),
		PaddingRight = UDim.new(0, 12),
	}, search)
	search.Focused:Connect(function()
		local stroke = search:FindFirstChildOfClass("UIStroke")
		if stroke then
			tween(stroke, 0.14, { Transparency = 0.08, Color = COLORS.Accent })
		end
	end)
	search.FocusLost:Connect(function()
		local stroke = search:FindFirstChildOfClass("UIStroke")
		if stroke then
			tween(stroke, 0.14, { Transparency = 0.36, Color = COLORS.Border })
		end
	end)
	search:GetPropertyChangedSignal("Text"):Connect(function()
		if self.SelectedTab then
			self:_renderModules()
		end
	end)
	self.SearchBox = search

	local toolbar = create("Frame", {
		Name = "Toolbar",
		Position = UDim2.new(0, 0, 0, 94),
		Size = UDim2.new(1, 0, 0, 30),
		BackgroundTransparency = 1,
	}, main)
	local gameMode = create("TextButton", {
		Name = "Gamemodes",
		Size = UDim2.new(0, 112, 0, 27),
		BackgroundColor3 = COLORS.Input,
		BackgroundTransparency = 0.1,
		BorderSizePixel = 0,
		Font = Enum.Font.GothamMedium,
		Text = "Gamemodes",
		TextColor3 = COLORS.Secondary,
		TextSize = 13,
		AutoButtonColor = false,
	}, toolbar)
	addCorner(gameMode, 14)
	addStroke(gameMode, COLORS.Border, 0.46)

	local viewSwitch = create("Frame", {
		Name = "ViewSwitch",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 0),
		Size = UDim2.new(0, 70, 0, 28),
		BackgroundColor3 = COLORS.Input,
		BackgroundTransparency = 0.12,
		BorderSizePixel = 0,
	}, toolbar)
	addCorner(viewSwitch, 14)
	addStroke(viewSwitch, COLORS.Border, 0.48)
	local listButton = create("TextButton", {
		Position = UDim2.new(0, 3, 0, 3),
		Size = UDim2.new(0, 31, 1, -6),
		BackgroundColor3 = COLORS.AccentDark,
		BorderSizePixel = 0,
		Font = Enum.Font.GothamBold,
		Text = "☰",
		TextColor3 = COLORS.Text,
		TextSize = 14,
		AutoButtonColor = false,
	}, viewSwitch)
	addCorner(listButton, 12)
	local gridButton = create("TextButton", {
		Position = UDim2.new(0, 36, 0, 3),
		Size = UDim2.new(0, 31, 1, -6),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Text = "▦",
		TextColor3 = COLORS.Secondary,
		TextSize = 15,
		AutoButtonColor = false,
	}, viewSwitch)
	addCorner(gridButton, 12)

	local list = create("ScrollingFrame", {
		Name = "ModuleList",
		Position = UDim2.new(0, 0, 0, 141),
		Size = UDim2.new(1, 0, 1, -141),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 0,
	}, main)
	create("UIListLayout", {
		Padding = UDim.new(0, 12),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, list)
	self.List = list

	local gridMode = false
	local function setGrid(enabled)
		gridMode = enabled
		listButton.BackgroundColor3 = enabled and COLORS.Input or COLORS.AccentDark
		listButton.BackgroundTransparency = enabled and 1 or 0
		listButton.TextColor3 = enabled and COLORS.Secondary or COLORS.Text
		gridButton.BackgroundColor3 = enabled and COLORS.AccentDark or COLORS.Input
		gridButton.BackgroundTransparency = enabled and 0 or 1
		gridButton.TextColor3 = enabled and COLORS.Text or COLORS.Secondary
		local layout = list:FindFirstChildOfClass("UIListLayout")
		if layout then
			layout:Destroy()
		end
		local gridLayout = list:FindFirstChildOfClass("UIGridLayout")
		if gridLayout then
			gridLayout:Destroy()
		end
		if gridMode then
			create("UIGridLayout", {
				CellPadding = UDim2.new(0, 12, 0, 12),
				CellSize = UDim2.new(0.5, -6, 0, 80),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}, list)
		else
			create("UIListLayout", {
				Padding = UDim.new(0, 12),
				SortOrder = Enum.SortOrder.LayoutOrder,
			}, list)
		end
	end
	listButton.Activated:Connect(function()
		setGrid(false)
	end)
	gridButton.Activated:Connect(function()
		setGrid(true)
	end)

	for _, tabConfig in ipairs(config.Tabs or DEFAULT_TABS) do
		local tab = self:AddTab(tabConfig.Name, tabConfig)
		local modules = tabConfig.Modules
		if modules then
			for _, moduleConfig in ipairs(modules) do
				self:AddModule(tab, moduleConfig.Name, moduleConfig.Description, moduleConfig.Callback)
				local added = tab.Modules[#tab.Modules]
				added.Enabled = moduleConfig.Enabled == true
			end
		elseif tabConfig.Name == "Combat" and not config.Tabs then
			for _, moduleConfig in ipairs(DEFAULT_MODULES) do
				self:AddModule(tab, moduleConfig.Name, moduleConfig.Description, moduleConfig.Callback)
			end
		end
	end

	if #self.Tabs > 0 then
		self:SelectTab(self.Tabs[1])
	end

	local dragging = false
	local dragStart
	local startPosition
	dragHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPosition = window.Position
		end
	end)
	self.DragInputConnection = UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			window.Position = UDim2.new(
				startPosition.X.Scale,
				startPosition.X.Offset + delta.X,
				startPosition.Y.Scale,
				startPosition.Y.Offset + delta.Y
			)
		end
	end)
	self.DragEndConnection = UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	return self
end

return PrestigeUI
