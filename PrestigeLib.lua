-- PrestigeUI - a lightweight Roblox Luau interface library.
-- Use from a LocalScript or a client-side ModuleScript.

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Library = { Windows = {} }
Library.__index = Library

local DEFAULTS = {
	Shell = Color3.fromRGB(5, 8, 23),
	Sidebar = Color3.fromRGB(13, 17, 36),
	Panel = Color3.fromRGB(16, 21, 42),
	PanelHover = Color3.fromRGB(22, 28, 53),
	Outline = Color3.fromRGB(38, 47, 79),
	Muted = Color3.fromRGB(119, 130, 161),
	Text = Color3.fromRGB(231, 234, 247),
	Accent = Color3.fromRGB(132, 116, 255),
	Danger = Color3.fromRGB(255, 105, 125),
}
Library.Scheme = {
	BackgroundColor = DEFAULTS.Shell,
	MainColor = DEFAULTS.Panel,
	AccentColor = DEFAULTS.Accent,
	OutlineColor = DEFAULTS.Outline,
	FontColor = DEFAULTS.Text,
}

local function make(className, properties, parent)
	local instance = Instance.new(className)
	for key, value in pairs(properties or {}) do
		instance[key] = value
	end
	if parent then
		instance.Parent = parent
	end
	return instance
end

local function corner(instance, radius)
	make("UICorner", { CornerRadius = UDim.new(0, radius or 8) }, instance)
end

local function outline(instance, color, transparency)
	return make("UIStroke", {
		Color = color or DEFAULTS.Outline,
		Transparency = transparency or 0,
		Thickness = 1,
	}, instance)
end

local function tween(instance, duration, properties)
	local animation = TweenService:Create(
		instance,
		TweenInfo.new(duration or 0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out),
		properties
	)
	animation:Play()
	return animation
end

local function invoke(callback, value)
	if typeof(callback) == "function" then
		local ok, message = pcall(callback, value)
		if not ok then
			warn("[PrestigeUI] Callback error: " .. tostring(message))
		end
	end
end

local function makeText(parent, text, size, position, fontSize, color, font)
	return make("TextLabel", {
		BackgroundTransparency = 1,
		Position = position or UDim2.new(),
		Size = size or UDim2.new(1, 0, 0, 20),
		Font = font or Enum.Font.Gotham,
		Text = text or "",
		TextColor3 = color or DEFAULTS.Text,
		TextSize = fontSize or 14,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		TextTruncate = Enum.TextTruncate.AtEnd,
	}, parent)
end

local function makeButton(parent, text, size, color)
	local button = make("TextButton", {
		AutoButtonColor = false,
		BackgroundColor3 = color or DEFAULTS.Panel,
		BorderSizePixel = 0,
		Size = size,
		Font = Enum.Font.GothamMedium,
		Text = text or "",
		TextColor3 = DEFAULTS.Text,
		TextSize = 12,
	}, parent)
	corner(button, 7)
	outline(button)
	button:SetAttribute("RestColor", color or DEFAULTS.Panel)
	button.MouseEnter:Connect(function()
		tween(button, 0.14, { BackgroundColor3 = DEFAULTS.PanelHover })
	end)
	button.MouseLeave:Connect(function()
		tween(button, 0.14, { BackgroundColor3 = button:GetAttribute("RestColor") or DEFAULTS.Panel })
	end)
	return button
end

local WindowMethods = {}
WindowMethods.__index = WindowMethods
local TabMethods = {}
TabMethods.__index = TabMethods
local GroupMethods = {}
GroupMethods.__index = GroupMethods
local createKeyPicker

function Library:CreateWindow(options)
	options = options or {}
	local player = Players.LocalPlayer
	if not player then
		error("PrestigeUI must be required from a Roblox client LocalScript.", 2)
	end

	local colors = table.clone(DEFAULTS)
	local scheme = options.Theme or self.Scheme or {}
	for key, value in pairs(scheme) do
		local mappedKey = ({ BackgroundColor = "Shell", MainColor = "Panel", AccentColor = "Accent", OutlineColor = "Outline", FontColor = "Text" })[key] or key
		if colors[mappedKey] ~= nil then colors[mappedKey] = value end
	end

	local playerGui = options.Parent or player:WaitForChild("PlayerGui")
	local screenGui = make("ScreenGui", {
		Name = options.Name or "PrestigeUI",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		DisplayOrder = options.DisplayOrder or 50,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	}, playerGui)

	local root = make("Frame", {
		Name = "Window",
		AnchorPoint = options.Center == false and Vector2.new(0, 0) or Vector2.new(0.5, 0.5),
		Position = options.Position or (options.Center == false and UDim2.fromOffset(8, 8) or UDim2.fromScale(0.5, 0.5)),
		Size = options.Size or UDim2.fromOffset(980, 650),
		BackgroundColor3 = colors.Shell,
		BorderSizePixel = 0,
		ClipsDescendants = true,
	}, screenGui)
	corner(root, 24)
	outline(root, colors.Outline)
	local sizeConstraint = make("UISizeConstraint", {
		MinSize = Vector2.new(680, 440),
		MaxSize = Vector2.new(1500, 1000),
	}, root)
	local resizeGrip = make("TextButton", {
		Name = "ResizeGrip",
		AutoButtonColor = false,
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -5, 1, -5),
		Size = UDim2.fromOffset(18, 18),
		BackgroundTransparency = 1,
		Font = Enum.Font.GothamBold,
		Text = "◢",
		TextColor3 = colors.Muted,
		TextSize = 13,
		Visible = options.Resizable ~= false,
	}, root)

	local sidebar = make("Frame", {
		Name = "Sidebar",
		Position = UDim2.new(0, 14, 0, 14),
		Size = UDim2.new(0, 220, 1, -28),
		BackgroundColor3 = colors.Sidebar,
		BorderSizePixel = 0,
	}, root)
	corner(sidebar, 16)
	outline(sidebar, colors.Outline)

	local brand = make("Frame", {
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 14, 0, 14),
		Size = UDim2.new(1, -28, 0, 54),
	}, sidebar)
	makeText(brand, "♛", UDim2.fromOffset(24, 30), UDim2.fromOffset(0, 2), 20, colors.Accent, Enum.Font.GothamBold)
	local title = makeText(brand, options.Title or "Prestige Client", UDim2.new(1, -32, 0, 24), UDim2.fromOffset(32, 0), 17, colors.Text, Enum.Font.GothamSemibold)
	title.RichText = true
	makeText(brand, options.Footer or "B E T A   R E L E A S E", UDim2.new(1, -32, 0, 16), UDim2.fromOffset(32, 24), 9, colors.Muted)

	makeText(sidebar, "MODULES", UDim2.new(1, -28, 0, 18), UDim2.new(0, 14, 0, 82), 10, colors.Muted)
	local tabList = make("ScrollingFrame", {
		Name = "Tabs",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 10, 0, 106),
		Size = UDim2.new(1, -20, 1, -118),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 2,
		ScrollBarImageColor3 = colors.Accent,
	}, sidebar)
	make("UIListLayout", {
		Padding = UDim.new(0, 5),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, tabList)

	local content = make("Frame", {
		Name = "Content",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 250, 0, 0),
		Size = UDim2.new(1, -264, 1, 0),
	}, root)
	local header = make("Frame", {
		Name = "Header",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 20),
		Size = UDim2.new(1, 0, 0, 72),
	}, content)
	local heading = makeText(header, "Modules", UDim2.new(0.54, 0, 0, 30), UDim2.new(0, 0, 0, 0), 25, colors.Text, Enum.Font.GothamSemibold)
	local subtitle = makeText(header, "Choose a tab to get started", UDim2.new(0.54, 0, 0, 18), UDim2.new(0, 0, 0, 32), 12, colors.Muted)

	local searchBox = make("TextBox", {
		Name = "Search",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 2),
		Size = UDim2.new(0, 290, 0, 38),
		BackgroundColor3 = colors.Sidebar,
		BorderSizePixel = 0,
		ClearTextOnFocus = false,
		Font = Enum.Font.Gotham,
		PlaceholderText = "⌕   Search controls",
		PlaceholderColor3 = colors.Muted,
		Text = "",
		TextColor3 = colors.Text,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, header)
	corner(searchBox, 9)
	outline(searchBox, colors.Outline)
	make("UIPadding", { PaddingLeft = UDim.new(0, 12), PaddingRight = UDim.new(0, 10) }, searchBox)

	local pages = make("Frame", {
		Name = "Pages",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 0, 0, 104),
		Size = UDim2.new(1, 0, 1, -118),
		ClipsDescendants = true,
	}, content)

	local self = setmetatable({
		Gui = screenGui,
		Library = self,
		Root = root,
		Colors = colors,
		Tabs = {},
		Options = {},
		Items = {},
		Connections = {},
		Keybinds = {},
		Capturing = nil,
		ActiveTab = nil,
		Visible = true,
		SearchBox = searchBox,
		Pages = pages,
		Heading = heading,
		Subtitle = subtitle,
		TabList = tabList,
		ResizeGrip = resizeGrip,
		SizeConstraint = sizeConstraint,
	}, WindowMethods)

	self:_connect(searchBox:GetPropertyChangedSignal("Text"), function()
		self:_ApplySearch(searchBox.Text)
	end)
	self:_connect(UserInputService.InputBegan, function(input, processed)
		if input.UserInputType ~= Enum.UserInputType.Keyboard then
			return
		end
		if self.Capturing then
			local bind = self.Capturing
			self.Capturing = nil
			if input.KeyCode == Enum.KeyCode.Escape then
				bind:_SetDisplay()
			else
				bind:SetValue(input.KeyCode)
			end
			return
		end
		if processed or UserInputService:GetFocusedTextBox() then
			return
		end
		for _, bind in ipairs(self.Keybinds) do
			if bind.Value == input.KeyCode then
				bind:_Activate()
			end
		end
	end)
	self:_connect(UserInputService.InputEnded, function(input)
		if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
		for _, bind in ipairs(self.Keybinds) do
			if bind.Value == input.KeyCode and bind.Mode == "Hold" then bind:_Deactivate() end
		end
	end)

	local dragging = false
	local resizing = false
	local dragStart
	local startPosition
	local resizeStart
	local startingSize
	self:_connect(resizeGrip.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			resizing = true
			resizeStart = input.Position
			startingSize = root.AbsoluteSize
		end
	end)
	self:_connect(header.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPosition = root.Position
		end
	end)
	self:_connect(UserInputService.InputChanged, function(input)
		if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - resizeStart
			local width = math.clamp(startingSize.X + delta.X, sizeConstraint.MinSize.X, sizeConstraint.MaxSize.X)
			local height = math.clamp(startingSize.Y + delta.Y, sizeConstraint.MinSize.Y, sizeConstraint.MaxSize.Y)
			root.Size = UDim2.fromOffset(width, height)
		elseif dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			root.Position = UDim2.new(startPosition.X.Scale, startPosition.X.Offset + delta.X, startPosition.Y.Scale, startPosition.Y.Offset + delta.Y)
		end
	end)
	self:_connect(UserInputService.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
			resizing = false
		end
	end)

	self.ToggleKeybind = options.ToggleKeybind or Enum.KeyCode.RightControl
	if self.ToggleKeybind ~= Enum.KeyCode.Unknown then
		self:_connect(UserInputService.InputBegan, function(input, processed)
			if not processed and not UserInputService:GetFocusedTextBox() and input.KeyCode == self.ToggleKeybind then
				self:Toggle()
			end
		end)
	end

	if options.AutoShow == false then
		self.Visible = false
		self.Gui.Enabled = false
	end
	table.insert(self.Windows, self)
	return self
end

function WindowMethods:_connect(signal, callback)
	local connection = signal:Connect(callback)
	table.insert(self.Connections, connection)
	return connection
end

function WindowMethods:_ApplySearch(query)
	query = string.lower(query or "")
	for _, item in ipairs(self.Items) do
		local groupMatches = string.find(string.lower(item.Group.Name), query, 1, true) ~= nil
		local matches = query == "" or groupMatches or string.find(string.lower(item.SearchText), query, 1, true) ~= nil
		item.Row.Visible = matches
	end
	for _, tab in ipairs(self.Tabs) do
		for _, group in ipairs(tab.Groups) do
			local hasVisible = false
			for _, item in ipairs(group.Items) do
				if item.Row.Visible then
					hasVisible = true
					break
				end
			end
			local groupMatch = query ~= "" and string.find(string.lower(group.Name), query, 1, true) ~= nil
			group.Frame.Visible = query == "" or hasVisible or groupMatch
			if groupMatch then
				for _, item in ipairs(group.Items) do item.Row.Visible = true end
			end
		end
	end
end

function WindowMethods:_SelectTab(tab)
	if self.ActiveTab == tab then return end
	self.ActiveTab = tab
	self.Heading.Text = tab.Name
	self.Subtitle.Text = tab.Description or (tostring(#tab.Groups) .. " sections")
	for _, other in ipairs(self.Tabs) do
		local active = other == tab
		other.Page.Visible = active
		other.IconLabel.TextColor3 = active and self.Colors.Accent or self.Colors.Muted
		other.NameLabel.TextColor3 = active and self.Colors.Text or self.Colors.Muted
		local restingColor = active and self.Colors.Accent:Lerp(self.Colors.Sidebar, 0.62) or self.Colors.Sidebar
		other.Button:SetAttribute("RestColor", restingColor)
		tween(other.Button, 0.16, {
			BackgroundColor3 = restingColor,
			TextColor3 = active and self.Colors.Text or self.Colors.Muted,
		})
	end
	self:_ApplySearch(self.SearchBox.Text)
end

function WindowMethods:AddTab(name, icon, description)
	local index = #self.Tabs + 1
	local button = make("TextButton", {
		Name = name .. "TabButton",
		AutoButtonColor = false,
		BackgroundColor3 = self.Colors.Sidebar,
		BorderSizePixel = 0,
		Size = UDim2.new(1, -2, 0, 40),
		Font = Enum.Font.GothamMedium,
		Text = "",
		LayoutOrder = index,
	}, self.TabList)
	corner(button, 9)
	outline(button, self.Colors.Outline, 1)
	local iconMap = {
		swords = "⚔", sword = "⚔", hammer = "⚒", mace = "⚒", wrench = "🔧",
		move = "↗", footprints = "↗", spear = "➤", eye = "◉", visual = "◉",
		settings = "⚙", theme = "✿", palette = "✿", configs = "▰", folder = "▰",
		socials = "♟", users = "♟", keybinds = "⌨", keyboard = "⌨", home = "⌂",
	}
	local iconText = typeof(icon) == "string" and (iconMap[string.lower(icon)] or (#icon <= 3 and icon ~= "" and icon)) or nil
	iconText = iconText or "◈"
	local iconLabel = makeText(button, iconText, UDim2.fromOffset(24, 28), UDim2.fromOffset(10, 6), 15, self.Colors.Muted, Enum.Font.GothamBold)
	local nameLabel = makeText(button, name, UDim2.new(1, -68, 1, 0), UDim2.fromOffset(40, 0), 13, self.Colors.Muted, Enum.Font.GothamMedium)
	local page = make("Frame", {
		Name = name .. "Page",
		BackgroundTransparency = 1,
		Size = UDim2.fromScale(1, 1),
		Visible = false,
	}, self.Pages)
	local left = make("ScrollingFrame", {
		Name = "LeftColumn",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(0.495, 0, 1, 0),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = self.Colors.Accent,
	}, page)
	local right = make("ScrollingFrame", {
		Name = "RightColumn",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0.505, 0, 0, 0),
		Size = UDim2.new(0.495, 0, 1, 0),
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = self.Colors.Accent,
	}, page)
	for _, column in ipairs({ left, right }) do
		make("UIListLayout", {
			Padding = UDim.new(0, 12),
			SortOrder = Enum.SortOrder.LayoutOrder,
		}, column)
		make("UIPadding", { PaddingRight = UDim.new(0, 7), PaddingBottom = UDim.new(0, 8) }, column)
	end

	local tab = setmetatable({
		Window = self,
		Name = name,
		Description = description,
		Button = button,
		IconLabel = iconLabel,
		NameLabel = nameLabel,
		Page = page,
		Left = left,
		Right = right,
		Groups = {},
	}, TabMethods)
	table.insert(self.Tabs, tab)
	self:_connect(button.Activated, function() self:_SelectTab(tab) end)
	if index == 1 then self:_SelectTab(tab) end
	return tab
end

WindowMethods.AddKeyTab = WindowMethods.AddTab

function TabMethods:AddLeftGroupbox(name)
	return self:_AddGroupbox(name, self.Left)
end

function TabMethods:AddRightGroupbox(name)
	return self:_AddGroupbox(name, self.Right)
end

function TabMethods:AddGroupbox(name)
	return self:AddLeftGroupbox(name)
end

function TabMethods:AddLeftTabbox(name)
	return self:_CreateTabbox(name, self.Left)
end

function TabMethods:AddRightTabbox(name)
	return self:_CreateTabbox(name, self.Right)
end

function TabMethods:_AddGroupbox(name, parent)
	local frame = make("Frame", {
		Name = name:gsub("%s+", "") .. "Groupbox",
		BackgroundColor3 = self.Window.Colors.Panel,
		BorderSizePixel = 0,
		Size = UDim2.new(1, -7, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		ClipsDescendants = false,
	}, parent)
	frame.LayoutOrder = #self.Groups + 1
	corner(frame, 12)
	outline(frame, self.Window.Colors.Outline)
	makeText(frame, name, UDim2.new(1, -28, 0, 24), UDim2.fromOffset(14, 10), 14, self.Window.Colors.Text, Enum.Font.GothamSemibold)
	local body = make("Frame", {
		Name = "Controls",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 10, 0, 42),
		Size = UDim2.new(1, -20, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
	}, frame)
	make("UIListLayout", {
		Padding = UDim.new(0, 7),
		SortOrder = Enum.SortOrder.LayoutOrder,
	}, body)
	make("UIPadding", { PaddingBottom = UDim.new(0, 12) }, body)

	local group = setmetatable({
		Tab = self,
		Window = self.Window,
		Name = name,
		Frame = frame,
		Body = body,
		Items = {},
		Order = 0,
	}, GroupMethods)
	table.insert(self.Groups, group)
	if self.Window.ActiveTab == self then
		self.Window.Subtitle.Text = self.Description or (tostring(#self.Groups) .. " sections")
	end
	return group
end

function TabMethods:_CreateTabbox(name, parent)
	local group = self:_AddGroupbox(name, parent)
	group.Body.Position = UDim2.new(0, 10, 0, 76)
	local tabBar = make("Frame", {
		Name = "TabButtons",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 12, 0, 38),
		Size = UDim2.new(1, -24, 0, 28),
	}, group.Frame)
	local tabs = {}
	local tabbox = { Group = group }
	function tabbox:AddTab(tabName)
		local index = #tabs + 1
		local page = make("Frame", {
			Name = tabName,
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -4, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			Visible = false,
			LayoutOrder = index,
		}, group.Body)
		make("UIListLayout", { Padding = UDim.new(0, 7), SortOrder = Enum.SortOrder.LayoutOrder }, page)
		make("UIPadding", { PaddingBottom = UDim.new(0, 10) }, page)
		local pageGroup = setmetatable({
			Tab = group.Tab,
			Window = group.Window,
			Name = tabName,
			Frame = page,
			Body = page,
			Items = {},
			Order = 0,
		}, GroupMethods)
		local button = makeButton(tabBar, tabName, UDim2.new(0, 82, 1, 0), group.Window.Colors.Sidebar)
		button.Position = UDim2.new(0, (index - 1) * 86, 0, 0)
		local record = { Page = page, Button = button, Group = pageGroup }
		table.insert(tabs, record)
		group.Window:_connect(button.Activated, function()
			for _, tab in ipairs(tabs) do
				tab.Page.Visible = tab == record
				local restingColor = tab == record and group.Window.Colors.Accent or group.Window.Colors.Sidebar
				tab.Button:SetAttribute("RestColor", restingColor)
				tween(tab.Button, 0.14, { BackgroundColor3 = restingColor })
			end
		end)
		if index == 1 then
			page.Visible = true
			button.BackgroundColor3 = group.Window.Colors.Accent
			button:SetAttribute("RestColor", group.Window.Colors.Accent)
		end
		return pageGroup
	end
	return tabbox
end

function GroupMethods:Resize()
	if self.Frame then self.Frame.AutomaticSize = Enum.AutomaticSize.Y end
end

function GroupMethods:_MakeRow(id, options, height)
	options = options or {}
	self.Order += 1
	local row = make("Frame", {
		Name = tostring(id or options.Text or "Control"):gsub("%s+", ""),
		BackgroundColor3 = self.Window.Colors.Sidebar:Lerp(self.Window.Colors.Panel, 0.45),
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, height or 62),
		LayoutOrder = self.Order,
		Visible = options.Visible ~= false,
		ClipsDescendants = false,
	}, self.Body)
	corner(row, 9)
	outline(row, self.Window.Colors.Outline, 0.25)
	local title = makeText(row, options.Text or tostring(id or "Control"), UDim2.new(1, -190, 0, 21), UDim2.new(0, 12, 0, 9), 13, options.Risky and self.Window.Colors.Danger or self.Window.Colors.Text, Enum.Font.GothamSemibold)
	local description = makeText(row, options.Description or options.Tooltip or "", UDim2.new(1, -190, 0, 16), UDim2.new(0, 12, 0, 32), 10, self.Window.Colors.Muted)
	local controls = make("Frame", {
		Name = "Control",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		Size = UDim2.new(0, 160, 1, -12),
		BackgroundTransparency = 1,
	}, row)
	local handle = {
		Id = tostring(id or options.Text or "Control"),
		Text = title,
		DescriptionLabel = description,
		Row = row,
		Controls = controls,
		Group = self,
		Window = self.Window,
		Options = options,
		Changed = {},
		Disabled = options.Disabled == true,
	}
	function handle:SetText(text) self.Text.Text = tostring(text) end
	function handle:SetVisible(visible) self.Row.Visible = visible == true end
	function handle:SetDisabled(disabled)
		self.Disabled = disabled == true
		self.Row.BackgroundTransparency = self.Disabled and 0.35 or 0
	end
	function handle:OnChanged(callback)
		table.insert(self.Changed, callback)
	end
	function handle:_Notify(value)
		invoke(self.Options.Callback, value)
		for _, callback in ipairs(self.Changed) do invoke(callback, value) end
	end
	table.insert(self.Items, handle)
	self.Window.Options[handle.Id] = handle
	table.insert(self.Window.Items, {
		Row = row,
		SearchText = tostring(options.Text or id or "") .. " " .. tostring(options.Description or options.Tooltip or ""),
		Group = self,
	})
	return handle
end

function GroupMethods:AddToggle(id, options)
	options = options or {}
	local handle = self:_MakeRow(id, options, 62)
	handle.Value = options.Default == true
	local track = make("TextButton", {
		Name = "Switch",
		AutoButtonColor = false,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.fromOffset(44, 24),
		BackgroundColor3 = handle.Value and self.Window.Colors.Accent or Color3.fromRGB(7, 10, 24),
		BorderSizePixel = 0,
		Text = "",
	}, handle.Controls)
	corner(track, 20)
	outline(track, handle.Value and self.Window.Colors.Accent or self.Window.Colors.Outline)
	local knob = make("Frame", {
		Name = "Knob",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = handle.Value and UDim2.new(1, -21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
		Size = UDim2.fromOffset(18, 18),
		BackgroundColor3 = Color3.fromRGB(244, 245, 252),
		BorderSizePixel = 0,
	}, track)
	corner(knob, 20)
	handle.Track = track
	function handle:SetValue(value, silent)
		if self.Disabled then return end
		value = value == true
		if self.Value == value then return end
		self.Value = value
		tween(self.Track, 0.18, { BackgroundColor3 = value and self.Group.Window.Colors.Accent or Color3.fromRGB(7, 10, 24) })
		tween(knob, 0.18, { Position = value and UDim2.new(1, -21, 0.5, 0) or UDim2.new(0, 3, 0.5, 0) })
		if not silent then self:_Notify(value) end
	end
	self.Window:_connect(track.Activated, function() handle:SetValue(not handle.Value) end)
	function handle:AddKeyPicker(keyId, keyOptions)
		self.Keybind = createKeyPicker(self, self.Controls, keyOptions, self)
		return self.Keybind
	end
	return handle
end

function GroupMethods:AddCheckbox(id, options)
	return self:AddToggle(id, options)
end

function GroupMethods:AddSlider(id, options)
	options = options or {}
	local handle = self:_MakeRow(id, options, options.Compact and 72 or 78)
	handle.Min = tonumber(options.Min) or 0
	handle.Max = tonumber(options.Max) or 100
	handle.Rounding = math.max(0, tonumber(options.Rounding) or 0)
	handle.Prefix = options.Prefix or ""
	handle.Suffix = options.Suffix or ""
	handle.Value = math.clamp(tonumber(options.Default) or handle.Min, handle.Min, handle.Max)
	local valueBox = make("TextBox", {
		Name = "Value",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, 0, 0, 5),
		Size = UDim2.fromOffset(52, 24),
		BackgroundColor3 = Color3.fromRGB(22, 29, 53),
		BorderSizePixel = 0,
		ClearTextOnFocus = false,
		Font = Enum.Font.GothamMedium,
		Text = "",
		TextColor3 = self.Window.Colors.Text,
		TextSize = 12,
	}, handle.Controls)
	corner(valueBox, 6)
	outline(valueBox, self.Window.Colors.Outline)
	local track = make("TextButton", {
		Name = "Track",
		AutoButtonColor = false,
		Position = UDim2.new(0, 0, 0, 44),
		Size = UDim2.new(1, -4, 0, 5),
		BackgroundColor3 = Color3.fromRGB(48, 56, 86),
		BorderSizePixel = 0,
		Text = "",
	}, handle.Controls)
	corner(track, 8)
	local fill = make("Frame", {
		Name = "Fill",
		Size = UDim2.new(0, 0, 1, 0),
		BackgroundColor3 = self.Window.Colors.Accent,
		BorderSizePixel = 0,
	}, track)
	corner(fill, 8)
	local thumb = make("Frame", {
		Name = "Thumb",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.fromOffset(13, 13),
		BackgroundColor3 = Color3.fromRGB(224, 220, 255),
		BorderSizePixel = 0,
	}, track)
	corner(thumb, 20)
	outline(thumb, self.Window.Colors.Accent)
	local function formatValue(value)
		return (handle.Prefix or "") .. string.format("%." .. tostring(handle.Rounding) .. "f", value) .. (handle.Suffix or "")
	end
	local function setValue(value, silent)
		if handle.Disabled then return end
		value = math.clamp(tonumber(value) or handle.Min, handle.Min, handle.Max)
		local multiplier = 10 ^ handle.Rounding
		value = math.floor(value * multiplier + 0.5) / multiplier
		if handle.Value == value and not silent then return end
		handle.Value = value
		local alpha = handle.Max == handle.Min and 0 or (value - handle.Min) / (handle.Max - handle.Min)
		fill.Size = UDim2.new(alpha, 0, 1, 0)
		thumb.Position = UDim2.new(alpha, 0, 0.5, 0)
		valueBox.Text = formatValue(value)
		if not silent then handle:_Notify(value) end
	end
	function handle:SetValue(value, silent) setValue(value, silent) end
	function handle:SetMin(value) handle.Min = tonumber(value) or handle.Min; setValue(math.max(handle.Value, handle.Min), true) end
	function handle:SetMax(value) handle.Max = tonumber(value) or handle.Max; setValue(math.min(handle.Value, handle.Max), true) end
	function handle:SetPrefix(value) handle.Prefix = tostring(value or ""); setValue(handle.Value, true) end
	function handle:SetSuffix(value) handle.Suffix = tostring(value or ""); setValue(handle.Value, true) end
	function handle:SetText(value) self.Text.Text = tostring(value) end
	setValue(handle.Value, true)
	valueBox.FocusLost:Connect(function()
		local numericText = valueBox.Text:match("-?[%d%.]+")
		setValue(tonumber(numericText), false)
	end)
	local dragging = false
	local function updateFromInput(input)
		local width = track.AbsoluteSize.X
		if width <= 0 then return end
		local alpha = math.clamp((input.Position.X - track.AbsolutePosition.X) / width, 0, 1)
		setValue(handle.Min + (handle.Max - handle.Min) * alpha, false)
	end
	self.Window:_connect(track.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			updateFromInput(input)
		end
	end)
	self.Window:_connect(UserInputService.InputChanged, function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then updateFromInput(input) end
	end)
	self.Window:_connect(UserInputService.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
	end)
	return handle
end

function GroupMethods:AddInput(id, options)
	options = options or {}
	local handle = self:_MakeRow(id, options, 62)
	handle.Value = tostring(options.Default or "")
	local input = make("TextBox", {
		Name = "Input",
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.new(1, -4, 0, 32),
		BackgroundColor3 = Color3.fromRGB(22, 29, 53),
		BorderSizePixel = 0,
		ClearTextOnFocus = options.ClearTextOnFocus == true,
		Font = Enum.Font.Gotham,
		PlaceholderText = options.Placeholder or "Enter a value…",
		Text = handle.Value,
		TextColor3 = self.Window.Colors.Text,
		PlaceholderColor3 = self.Window.Colors.Muted,
		TextSize = 12,
	}, handle.Controls)
	corner(input, 6)
	outline(input, self.Window.Colors.Outline)
	make("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingRight = UDim.new(0, 8) }, input)
	local settingInput = false
	local function commit()
		if handle.Disabled then return end
		local value = input.Text
		if options.Numeric then value = tonumber(value) end
		if value == nil and options.Numeric then
			value = handle.Value
			settingInput = true
			input.Text = tostring(value)
			settingInput = false
		end
		handle.Value = value
		handle:_Notify(value)
	end
	self.Window:_connect(input:GetPropertyChangedSignal("Text"), function()
		if not options.Finished and not settingInput then commit() end
	end)
	self.Window:_connect(input.FocusLost, function()
		if options.Finished then commit() end
	end)
	function handle:SetValue(value, silent)
		self.Value = value
		settingInput = true
		input.Text = tostring(value)
		settingInput = false
		if not silent then self:_Notify(value) end
	end
	return handle
end

function GroupMethods:AddDropdown(id, options)
	options = options or {}
	local values = options.Values or {}
	local height = 62
	local handle = self:_MakeRow(id, options, height)
	handle.Values = values
	handle.Value = typeof(options.Default) == "number" and values[options.Default] or options.Default or values[1]
	local selector = makeButton(handle.Controls, tostring(handle.Value or "Select…") .. "   ▾", UDim2.new(1, 0, 0, 30), Color3.fromRGB(22, 29, 53))
	selector.AnchorPoint = Vector2.new(1, 0.5)
	selector.Position = UDim2.new(1, 0, 0.5, 0)
	local menu = make("Frame", {
		Name = "Options",
		Position = UDim2.new(0, 0, 0, 61),
		Size = UDim2.new(1, 0, 0, 0),
		BackgroundTransparency = 1,
		Visible = false,
	}, handle.Row)
	local list = make("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder }, menu)
	local opened = false
	local function refreshMenu()
		for _, child in ipairs(menu:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
		for index, value in ipairs(handle.Values) do
			local optionButton = makeButton(menu, tostring(value), UDim2.new(1, 0, 0, 28), self.Window.Colors.Sidebar)
			optionButton.LayoutOrder = index
			self.Window:_connect(optionButton.Activated, function()
				handle:SetValue(value)
				opened = false
				menu.Visible = false
				handle.Row.Size = UDim2.new(1, 0, 0, height)
			end)
		end
		local menuHeight = #handle.Values * 28 + math.max(0, #handle.Values - 1) * 4
		menu.Size = UDim2.new(1, 0, 0, menuHeight)
	end
	refreshMenu()
	self.Window:_connect(selector.Activated, function()
		if handle.Disabled then return end
		opened = not opened
		menu.Visible = opened
		handle.Row.Size = UDim2.new(1, 0, 0, height + (opened and menu.Size.Y.Offset + 6 or 0))
	end)
	function handle:SetValue(value, silent)
		if self.Disabled then return end
		if not table.find(self.Values, value) then return end
		self.Value = value
		selector.Text = tostring(value) .. "   ▾"
		if not silent then self:_Notify(value) end
	end
	function handle:SetValues(newValues)
		self.Values = newValues or {}
		if not table.find(self.Values, self.Value) then
			self.Value = self.Values[1]
			selector.Text = tostring(self.Value or "Select…") .. "   ▾"
		end
		refreshMenu()
	end
	return handle
end

function GroupMethods:AddButton(options)
	if typeof(options) == "string" then options = { Text = options } end
	options = options or {}
	local handle = self:_MakeRow(options.Id or options.Text or "Button", options, 54)
	local button = makeButton(handle.Controls, options.ButtonText or options.Text or "Run", UDim2.new(1, 0, 0, 32), self.Window.Colors.Accent)
	button.TextColor3 = Color3.new(1, 1, 1)
	self.Window:_connect(button.Activated, function() if not handle.Disabled then invoke(options.Func or options.Callback) end end)
	function handle:SetText(text) self.Text.Text = tostring(text); button.Text = tostring(text) end
	return handle
end

function GroupMethods:AddLabel(value)
	local options = typeof(value) == "table" and value or { Text = tostring(value) }
	local handle = self:_MakeRow(options.Id or options.Text, options, options.DoesWrap and 74 or 42)
	handle.Row.BackgroundTransparency = 1
	handle.Row:FindFirstChildOfClass("UIStroke").Transparency = 1
	handle.Text.Position = UDim2.new(0, 12, 0, 2)
	handle.Text.Size = UDim2.new(1, -24, 1, -4)
	handle.Text.TextWrapped = options.DoesWrap == true
	handle.Text.TextSize = 12
	handle.DescriptionLabel.Visible = false
	function handle:SetText(text) self.Text.Text = tostring(text) end
	return handle
end

function GroupMethods:AddDivider()
	local frame = make("Frame", {
		Name = "Divider",
		BackgroundColor3 = self.Window.Colors.Outline,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 1),
		LayoutOrder = self.Order + 1,
	}, self.Body)
	self.Order += 1
	return frame
end

createKeyPicker = function(owner, parent, options, toggle)
	options = options or {}
	local window = owner.Window
	local keyCode = options.Default
	if typeof(keyCode) == "string" then
		keyCode = Enum.KeyCode[keyCode] or Enum.KeyCode.Unknown
	end
	local bind = {
		Window = window,
		Value = keyCode or Enum.KeyCode.Unknown,
		Mode = options.Mode or "Toggle",
		Callback = options.Callback,
		SyncToggle = options.SyncToggleState == true,
		Toggle = toggle,
	}
	local button = makeButton(parent, bind.Value == Enum.KeyCode.Unknown and "None" or bind.Value.Name, UDim2.fromOffset(70, 26), Color3.fromRGB(22, 29, 53))
	button.AnchorPoint = Vector2.new(0, 0.5)
	button.Position = UDim2.new(0, 0, 0.5, 0)
	bind.Button = button
	function bind:_SetDisplay()
		button.Text = self.Value == Enum.KeyCode.Unknown and "None" or self.Value.Name
	end
	function bind:SetValue(value)
		if typeof(value) == "string" then value = Enum.KeyCode[value] end
		self.Value = value or Enum.KeyCode.Unknown
		self:_SetDisplay()
		invoke(options.ChangedCallback, self.Value)
	end
	function bind:_Activate()
		if owner.Disabled then return end
		invoke(self.Callback, true)
		if self.SyncToggle and self.Toggle then
			self.Toggle:SetValue(self.Mode == "Hold" and true or not self.Toggle.Value)
		end
	end
	function bind:_Deactivate()
		if self.Mode ~= "Hold" then return end
		invoke(self.Callback, false)
		if self.SyncToggle and self.Toggle then self.Toggle:SetValue(false) end
	end
	window:_connect(button.Activated, function()
		window.Capturing = bind
		button.Text = "Press key…"
	end)
	table.insert(window.Keybinds, bind)
	return bind
end

function GroupMethods:AddKeybind(id, options)
	options = options or {}
	local handle = self:_MakeRow(id, options, 54)
	local bind = createKeyPicker(handle, handle.Controls, options)
	handle.Bind = bind
	function handle:SetValue(value) bind:SetValue(value) end
	return handle
end

function GroupMethods:AddColorPicker(id, options)
	options = options or {}
	local handle = self:_MakeRow(id, options, 62)
	handle.Value = options.Default or Color3.fromRGB(132, 116, 255)
	local swatch = makeButton(handle.Controls, "", UDim2.fromOffset(42, 28), handle.Value)
	swatch.AnchorPoint = Vector2.new(1, 0.5)
	swatch.Position = UDim2.new(1, 0, 0.5, 0)
	swatch.BackgroundColor3 = handle.Value
	local palette = make("Frame", {
		Name = "Palette",
		Position = UDim2.new(0, 0, 1, 4),
		AnchorPoint = Vector2.new(1, 0),
		Size = UDim2.fromOffset(174, 64),
		BackgroundColor3 = self.Window.Colors.Sidebar,
		BorderSizePixel = 0,
		Visible = false,
		ZIndex = 5,
	}, handle.Controls)
	palette.Position = UDim2.new(1, 0, 1, 4)
	corner(palette, 8)
	outline(palette, self.Window.Colors.Outline)
	local swatches = {
		Color3.fromRGB(132, 116, 255), Color3.fromRGB(64, 150, 255), Color3.fromRGB(45, 211, 190),
		Color3.fromRGB(102, 205, 95), Color3.fromRGB(255, 177, 66), Color3.fromRGB(255, 92, 135),
	}
	make("UIGridLayout", { CellSize = UDim2.fromOffset(42, 22), CellPadding = UDim2.fromOffset(5, 5), SortOrder = Enum.SortOrder.LayoutOrder }, palette)
	make("UIPadding", { PaddingLeft = UDim.new(0, 8), PaddingTop = UDim.new(0, 8) }, palette)
	local function setValue(color, silent)
		if handle.Disabled then return end
		handle.Value = color
		swatch.BackgroundColor3 = color
		if not silent then handle:_Notify(color) end
	end
	for _, color in ipairs(swatches) do
		local chip = make("TextButton", { AutoButtonColor = false, BackgroundColor3 = color, BorderSizePixel = 0, Text = "", ZIndex = 6 }, palette)
		corner(chip, 5)
		self.Window:_connect(chip.Activated, function() setValue(color); palette.Visible = false end)
	end
	self.Window:_connect(swatch.Activated, function() if not handle.Disabled then palette.Visible = not palette.Visible end end)
	function handle:SetValue(color, silent) if typeof(color) == "Color3" then setValue(color, silent) end end
	return handle
end

function GroupMethods:AddToggleKeyPicker(toggle, id, options)
	return createKeyPicker(toggle, toggle.Controls, options, toggle)
end

function WindowMethods:Notify(message, duration)
	local toast = make("Frame", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -24, 0, 24),
		Size = UDim2.fromOffset(280, 62),	
		BackgroundColor3 = self.Colors.Panel,
		BorderSizePixel = 0,
		ZIndex = 20,
	}, self.Gui)
	corner(toast, 10)
	outline(toast, self.Colors.Accent)
	makeText(toast, "Prestige Client", UDim2.new(1, -24, 0, 20), UDim2.fromOffset(12, 8), 13, self.Colors.Text, Enum.Font.GothamSemibold).ZIndex = 21
	makeText(toast, tostring(message), UDim2.new(1, -24, 0, 22), UDim2.fromOffset(12, 31), 11, self.Colors.Muted).ZIndex = 21
	toast.Position = UDim2.new(1, 300, 0, 24)
	tween(toast, 0.24, { Position = UDim2.new(1, -24, 0, 24) })
	task.delay(duration or 3, function()
		if toast.Parent then
			tween(toast, 0.2, { Position = UDim2.new(1, 300, 0, 24), BackgroundTransparency = 1 })
			task.delay(0.22, function() if toast.Parent then toast:Destroy() end end)
		end
	end)
	return toast
end

function WindowMethods:SetAccent(color)
	if typeof(color) ~= "Color3" then return end
	local oldAccent = self.Colors.Accent
	self.Colors.Accent = color
	for _, descendant in ipairs(self.Gui:GetDescendants()) do
		if descendant:IsA("UIStroke") and descendant.Color == oldAccent then
			descendant.Color = color
		elseif descendant:IsA("TextLabel") and descendant.TextColor3 == oldAccent then
			descendant.TextColor3 = color
		elseif descendant:IsA("GuiObject") and descendant.BackgroundColor3 == oldAccent then
			descendant.BackgroundColor3 = color
		end
		if descendant:IsA("ScrollingFrame") and descendant.ScrollBarImageColor3 == oldAccent then
			descendant.ScrollBarImageColor3 = color
		end
	end
	for _, tab in ipairs(self.Tabs) do
		local restingColor = tab == self.ActiveTab and color:Lerp(self.Colors.Sidebar, 0.62) or self.Colors.Sidebar
		tab.Button:SetAttribute("RestColor", restingColor)
		tab.Button.BackgroundColor3 = restingColor
	end
end

function WindowMethods:SetVisible(visible)
	self.Visible = visible == true
	self.Gui.Enabled = self.Visible
end

function WindowMethods:Toggle(visible)
	if visible == nil then visible = not self.Visible end
	self:SetVisible(visible)
end

function WindowMethods:OnUnload(callback)
	self.UnloadCallback = callback
end

function WindowMethods:Destroy()
	for _, connection in ipairs(self.Connections) do connection:Disconnect() end
	self.Connections = {}
	if self.Gui then self.Gui:Destroy() end
	invoke(self.UnloadCallback)
	for index, window in ipairs(self.Library and self.Library.Windows or Library.Windows) do
		if window == self then table.remove(self.Library and self.Library.Windows or Library.Windows, index); break end
	end
end

WindowMethods.Unload = WindowMethods.Destroy

function Library:Notify(message, duration)
	local first = self.Windows[#self.Windows]
	if first then return first:Notify(message, duration) end
	return nil
end

function Library:Toggle(visible)
	local latest = self.Windows[#self.Windows]
	if latest then latest:Toggle(visible) end
end

function Library:Unload()
	for index = #self.Windows, 1, -1 do self.Windows[index]:Destroy() end
end

return Library
