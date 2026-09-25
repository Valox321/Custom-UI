--// sable | custom UI library (style like screenshot)
--// Usage:
--// local Sable = loadstring(game:HttpGet(".../SableLib.lua"))()
--// local Window = Sable:CreateWindow({ Name = "sable" })
--// local Tab = Window:CreateTab({ Name = "Main", Icon = "+" })
--// local Page = Tab:CreatePage({ Name = "Level Up", Icon = "" })
--// Page:AddToggle({ Name = "...", Description = "...", Default = false, Callback = function(v) end })

local SableLib = {}
SableLib.Version = "1.4-menu-key"

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

--// Lucide support via Footagesus/Icons (lucide default)
--// GetIcon gibt Tabelle {imageUrl, iconData} zurück, kein String!
local IconsModule = nil
pcall(function()
	local src = game:HttpGet("https://raw.githubusercontent.com/Footagesus/Icons/main/Main-v2.lua")
	IconsModule = loadstring(src)()
	if IconsModule and IconsModule.SetIconsType then
		pcall(function() IconsModule.SetIconsType("lucide") end)
	end
end)

-- gibt image, rectSize, rectOffset zurück (oder nil)
function SableLib:ResolveIcon(name)
	if not name or name == "" then return nil end
	if string.find(name, "rbxassetid", 1, true) then
		return name, Vector2.new(0, 0), Vector2.new(0, 0)
	end
	if IconsModule then
		-- 1) GetIcon (kann string ODER {url, data} sein)
		local ok, res = pcall(function()
			if IconsModule.GetIcon then
				return IconsModule.GetIcon(name)
			end
			return nil
		end)
		if ok and res then
			if type(res) == "string" and res ~= "" then
				return res, Vector2.new(0, 0), Vector2.new(0, 0)
			elseif type(res) == "table" and res[1] then
				local url = res[1]
				local data = res[2]
				if type(url) == "string" and url ~= "" then
					if type(data) == "table" then
						return url, data.ImageRectSize or Vector2.new(0, 0), data.ImageRectPosition or Vector2.new(0, 0)
					end
					return url, Vector2.new(0, 0), Vector2.new(0, 0)
				end
			end
		end
		-- 2) Fallback über Icon2 (gibt immer {url, data})
		local ok2, res2 = pcall(function()
			if IconsModule.Icon2 then
				return IconsModule.Icon2(name)
			end
			return nil
		end)
		if ok2 and type(res2) == "table" and res2[1] then
			local url = res2[1]
			local data = res2[2]
			if type(url) == "string" then
				if type(data) == "table" then
					return url, data.ImageRectSize or Vector2.new(0, 0), data.ImageRectPosition or Vector2.new(0, 0)
				end
				return url, Vector2.new(0, 0), Vector2.new(0, 0)
			end
		end
	end
	return nil
end

function SableLib:GetIcon(name)
	local img = self:ResolveIcon(name)
	return img
end

local function isLucideName(s)
	if type(s) ~= "string" then return false end
	if s == "" then return false end
	if string.find(s, "rbxassetid", 1, true) then return false end
	-- lucide-namen sind lowercase mit bindestrich, keine leerzeichen/emojis
	if string.match(s, "^[a-z0-9%-]+$") then return true end
	return false
end

local function create(className, props, children)
	local inst = Instance.new(className)
	for k, v in pairs(props or {}) do
		if k ~= "Parent" then
			pcall(function()
				inst[k] = v
			end)
		end
	end
	for _, child in ipairs(children or {}) do
		child.Parent = inst
	end
	if props and props.Parent then
		inst.Parent = props.Parent
	end
	return inst
end

local COLORS = {
	ContentBG  = Color3.fromRGB(19, 20, 27),
	RowBG      = Color3.fromRGB(27, 30, 39),
	RowStroke  = Color3.fromRGB(39, 43, 56),
	PillBG     = Color3.fromRGB(26, 29, 38),
	PillActive = Color3.fromRGB(34, 38, 50),
	Text       = Color3.fromRGB(255, 255, 255),
	Sub        = Color3.fromRGB(144, 149, 164),
	Beige      = Color3.fromRGB(242, 226, 184),
	BeigeText  = Color3.fromRGB(25, 25, 25),
	TrackOff   = Color3.fromRGB(43, 47, 61),
	Knob       = Color3.fromRGB(198, 203, 216),
	Dark       = Color3.fromRGB(15, 16, 21),
}

local function corner(parent, radius)
	return create("UICorner", { CornerRadius = UDim.new(0, radius or 10), Parent = parent })
end

local function stroke(parent, color, thickness, transparency)
	return create("UIStroke", {
		Color = color or COLORS.RowStroke,
		Thickness = thickness or 1,
		Transparency = transparency or 0.35,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Parent = parent,
	})
end

local function padding(parent, l, t, r, b)
	return create("UIPadding", {
		PaddingLeft = UDim.new(0, l or 12),
		PaddingTop = UDim.new(0, t or 10),
		PaddingRight = UDim.new(0, r or 12),
		PaddingBottom = UDim.new(0, b or 10),
		Parent = parent,
	})
end

local function makeDraggable(main, handles)
	local dragging = false
	local dragStart, startPos
	for _, handle in ipairs(handles) do
		handle.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = main.Position
				input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false
					end
				end)
			end
		end)
	end
	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
end

function SableLib:CreateWindow(opts)
	opts = opts or {}
	local winName = opts.Name or "sable"
	local toggleKey = opts.ToggleKey or Enum.KeyCode.RightShift

	-- cleanup old
	pcall(function()
		if CoreGui:FindFirstChild("SableUI") then
			CoreGui.SableUI:Destroy()
		end
		if Players.LocalPlayer:FindFirstChildOfClass("PlayerGui"):FindFirstChild("SableUI") then
			Players.LocalPlayer:FindFirstChildOfClass("PlayerGui").SableUI:Destroy()
		end
	end)

	local gui = create("ScreenGui", {
		Name = "SableUI",
		ResetOnSpawn = false,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		IgnoreGuiInset = false,
	})
	pcall(function() gui.Parent = CoreGui end)
	if not gui.Parent then
		gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
	end

	local main = create("Frame", {
		Name = "Main",
		Parent = gui,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = opts.Size or UDim2.fromOffset(560, 480),
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
	})

	-- TOP PILLS (Level Up / Mobs / Bosses)
	local topBar = create("Frame", {
		Name = "TopBar",
		Parent = main,
		Size = UDim2.new(1, 0, 0, 38),
		Position = UDim2.new(0, 0, 0, 0),
		BackgroundTransparency = 1,
	})
	create("UIListLayout", {
		Parent = topBar,
		FillDirection = Enum.FillDirection.Horizontal,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 8),
		VerticalAlignment = Enum.VerticalAlignment.Center,
	})

	-- CONTENT CARD
	local contentCard = create("Frame", {
		Name = "Content",
		Parent = main,
		Position = UDim2.new(0, 0, 0, 46),
		Size = UDim2.new(1, 0, 1, -46 - 58),
		BackgroundColor3 = COLORS.ContentBG,
		BorderSizePixel = 0,
	})
	corner(contentCard, 12)
	stroke(contentCard, COLORS.RowStroke, 1, 0.25)

	local scroll = create("ScrollingFrame", {
		Name = "List",
		Parent = contentCard,
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = Color3.fromRGB(60, 65, 80),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ScrollingDirection = Enum.ScrollingDirection.Y,
	})
	padding(scroll, 8, 8, 8, 8)
	create("UIListLayout", {
		Parent = scroll,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 6),
	})

	-- BOTTOM NAV (logo links fix, tabs rechts scrollbar für viele Feature-Tabs)
	local bottomBar = create("Frame", {
		Name = "BottomBar",
		Parent = main,
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 0, 1, 0),
		Size = UDim2.new(1, 0, 0, 50),
		BackgroundTransparency = 1,
	})
	local logo = create("TextLabel", {
		Parent = bottomBar,
		Size = UDim2.fromOffset(70, 40),
		Position = UDim2.new(0, 0, 0, 5),
		BackgroundTransparency = 1,
		Text = winName,
		Font = Enum.Font.GothamBold,
		TextSize = 24,
		TextColor3 = COLORS.Beige,
		TextXAlignment = Enum.TextXAlignment.Left,
	})
	local navScroll = create("ScrollingFrame", {
		Name = "NavScroll",
		Parent = bottomBar,
		Position = UDim2.new(0, 78, 0, 5),
		Size = UDim2.new(1, -78, 0, 40),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 0,
		AutomaticCanvasSize = Enum.AutomaticSize.X,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ScrollingDirection = Enum.ScrollingDirection.X,
	})
	create("UIListLayout", {
		Parent = navScroll,
		FillDirection = Enum.FillDirection.Horizontal,
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 8),
		VerticalAlignment = Enum.VerticalAlignment.Center,
	})

	makeDraggable(main, { topBar, contentCard, bottomBar })

	local Window = {}
	Window.Gui = gui
	Window.Main = main
	Window._tabs = {}
	Window._pages = {}
	Window._topBar = topBar
	Window._scroll = scroll
	Window._bottomBar = bottomBar
	Window._navScroll = navScroll
	Window._currentTab = nil
	Window._currentPage = nil
	Window._toggleKey = toggleKey
	Window._visible = true

	-- Menü-Taste zur Laufzeit ändern, z.B. Window:SetToggleKey(Enum.KeyCode.T)
	function Window:SetToggleKey(key)
		if typeof(key) == "EnumItem" then
			self._toggleKey = key
		end
	end
	function Window:Toggle()
		self._visible = not self._visible
		gui.Enabled = self._visible
	end

	-- toggle visibility (nutzt Window._toggleKey, damit Keybinds sie ändern können)
	UserInputService.InputBegan:Connect(function(input, gpe)
		if gpe then return end
		if input.KeyCode == Window._toggleKey then
			Window._visible = not Window._visible
			gui.Enabled = Window._visible
		end
	end)

	local function stylePill(btn, active)
		btn.BackgroundColor3 = active and COLORS.PillActive or COLORS.PillBG
		pcall(function() btn.TextColor3 = active and COLORS.Text or COLORS.Sub end)
		for _, ch in ipairs(btn:GetDescendants()) do
			if ch:IsA("TextLabel") then
				ch.TextColor3 = active and COLORS.Text or COLORS.Sub
			elseif ch:IsA("ImageLabel") then
				ch.ImageColor3 = active and COLORS.Text or COLORS.Sub
			end
		end
	end

	local function buildPillContent(btn, iconName, text, iconOnly)
		btn.Text = ""
		create("UIListLayout", {
			Parent = btn,
			FillDirection = Enum.FillDirection.Horizontal,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Padding = UDim.new(0, 6),
			VerticalAlignment = Enum.VerticalAlignment.Center,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
		})
		padding(btn, 10, 0, 10, 0)

		local hasIcon = iconName and iconName ~= ""
		if hasIcon then
			local img, rectSize, rectOffset = nil, nil, nil
			if isLucideName(iconName) or string.find(iconName, "rbxassetid", 1, true) then
				img, rectSize, rectOffset = SableLib:ResolveIcon(iconName)
			end
			if img then
				local imgLabel = create("ImageLabel", {
					Parent = btn,
					Size = UDim2.fromOffset(16, 16),
					BackgroundTransparency = 1,
					Image = img,
					ImageColor3 = COLORS.Sub,
					LayoutOrder = 1,
				})
				-- Spritesheet-Icons brauchen Rect (Footagesus/Icons nutzt Spritesheets)
				if rectSize and rectSize.X > 0 and rectSize.Y > 0 then
					imgLabel.ImageRectSize = rectSize
					imgLabel.ImageRectOffset = rectOffset or Vector2.new(0, 0)
				end
			else
				-- fallback: emoji / text-symbol (z.B. "+", "↗")
				-- wenn lucide-name nicht gefunden wurde, nichts als Text anzeigen (kein "trending-up" text)
				if not isLucideName(iconName) then
					create("TextLabel", {
						Parent = btn,
						Size = UDim2.fromOffset(18, 18),
						BackgroundTransparency = 1,
						Text = iconName,
						Font = Enum.Font.GothamBold,
						TextSize = 14,
						TextColor3 = COLORS.Sub,
						LayoutOrder = 1,
					})
				else
					warn("[sable] lucide icon nicht gefunden: " .. tostring(iconName))
				end
			end
		end

		if not iconOnly then
			create("TextLabel", {
				Parent = btn,
				Size = UDim2.fromOffset(0, 18),
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundTransparency = 1,
				Text = text or "",
				Font = Enum.Font.GothamBold,
				TextSize = 13,
				TextColor3 = COLORS.Sub,
				LayoutOrder = 2,
			})
		end
	end

	-- creates a top pill page holder in advance, actual rows live in one shared scroll
	-- we switch visibility per page by storing row frames
	-- Icon kann sein: "crown" / "swords" / "skull" (lucide-name) ODER "rbxassetid://..." ODER emoji-text
	function Window:CreateTab(tabOpts)
		tabOpts = tabOpts or {}
		local tabName = tabOpts.Name or "Main"
		local icon = tabOpts.Icon or "house"

		local isActive = (#self._tabs == 0)
		local iconOnly = (tabName == "" or tabOpts.IconOnly == true)

		local pill = create("TextButton", {
			Parent = navScroll,
			Size = iconOnly and UDim2.fromOffset(40, 40) or UDim2.fromOffset(86, 40),
			AutomaticSize = iconOnly and Enum.AutomaticSize.None or Enum.AutomaticSize.X,
			BackgroundColor3 = isActive and COLORS.PillActive or COLORS.PillBG,
			BorderSizePixel = 0,
			AutoButtonColor = false,
			Text = "",
			ClipsDescendants = true,
			LayoutOrder = #self._tabs + 1,
		})
		corner(pill, 20)
		stroke(pill, COLORS.RowStroke, 1, 0.3)
		buildPillContent(pill, icon, tabName, iconOnly)
		stylePill(pill, isActive)

		local Tab = { Name = tabName, Button = pill, Pages = {}, ParentWindow = self }

		local function selectTab(target)
			local win = target.ParentWindow
			win._currentTab = target
			for _, t in ipairs(win._tabs) do
				stylePill(t.Button, t == target)
			end
			-- nur Top-Pills von diesem Tab zeigen
			for _, p in ipairs(win._pages) do
				p.TopButton.Visible = (p.ParentTab == target)
			end
			-- Seite bestimmen: aktuelle behalten wenn sie zu diesem Tab gehört, sonst erste
			local toShow = nil
			if win._currentPage and win._currentPage.ParentTab == target then
				toShow = win._currentPage
			else
				toShow = target.Pages[1]
			end
			win._currentPage = toShow
			for _, p in ipairs(win._pages) do
				local active = (p == toShow)
				if p.ParentTab == target then
					stylePill(p.TopButton, active)
				end
				for _, r in ipairs(p.Rows) do
					r.Visible = active
				end
			end
			pcall(function() win._scroll.CanvasPosition = Vector2.new(0, 0) end)
		end

		pill.MouseButton1Click:Connect(function()
			selectTab(Tab)
		end)

		function Tab:CreatePage(pageOpts)
			pageOpts = pageOpts or {}
			local pageName = pageOpts.Name or "Page"
			local pageIcon = pageOpts.Icon or ""

			local win = self.ParentWindow
			local isFirstOverall = (#win._pages == 0)
			local isOwnTabSelected = (win._currentTab == nil and #win._tabs <= 1) or (win._currentTab == self)

			local topPill = create("TextButton", {
				Parent = win._topBar,
				Size = UDim2.fromOffset(0, 32),
				AutomaticSize = Enum.AutomaticSize.X,
				BackgroundColor3 = COLORS.PillBG,
				BorderSizePixel = 0,
				AutoButtonColor = false,
				Text = "",
				Visible = isOwnTabSelected,
				LayoutOrder = #win._pages + 1,
			})
			corner(topPill, 16)
			stroke(topPill, COLORS.RowStroke, 1, 0.3)
			buildPillContent(topPill, pageIcon, pageName, false)

			local Page = {
				Name = pageName,
				TopButton = topPill,
				Rows = {},
				ParentTab = self,
				ParentWindow = win,
			}

			local function selectPage()
				win._currentTab = self
				win._currentPage = Page
				for _, t in ipairs(win._tabs) do
					stylePill(t.Button, t == self)
				end
				for _, p in ipairs(win._pages) do
					p.TopButton.Visible = (p.ParentTab == self)
				end
				for _, p in ipairs(win._pages) do
					local active = (p == Page)
					if p.ParentTab == self then
						stylePill(p.TopButton, active)
					end
					for _, r in ipairs(p.Rows) do
						r.Visible = active
					end
				end
				pcall(function() win._scroll.CanvasPosition = Vector2.new(0, 0) end)
			end

			topPill.MouseButton1Click:Connect(selectPage)

			-- ROW BUILDERS -------------------------------------------------
			local function baseRow(height)
				local row = create("Frame", {
					Parent = win._scroll,
					Size = UDim2.new(1, 0, 0, height or 64),
					BackgroundColor3 = COLORS.RowBG,
					BorderSizePixel = 0,
					Visible = (win._currentPage == Page),
				})
				corner(row, 10)
				stroke(row, COLORS.RowStroke, 1, 0.4)
				padding(row, 14, 10, 14, 10)
				table.insert(Page.Rows, row)
				return row
			end

			function Page:AddToggle(tOpts)
				local row = baseRow(64)
				local title = create("TextLabel", {
					Parent = row,
					Size = UDim2.new(1, -70, 0, 20),
					BackgroundTransparency = 1,
					Text = tOpts.Name or "Toggle",
					Font = Enum.Font.GothamBold,
					TextSize = 14,
					TextColor3 = COLORS.Text,
					TextXAlignment = Enum.TextXAlignment.Left,
				})
				local desc = create("TextLabel", {
					Parent = row,
					Position = UDim2.new(0, 0, 0, 22),
					Size = UDim2.new(1, -70, 1, -24),
					BackgroundTransparency = 1,
					Text = tOpts.Description or "",
					Font = Enum.Font.Gotham,
					TextSize = 12,
					TextColor3 = COLORS.Sub,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Top,
					TextWrapped = true,
				})

				local state = tOpts.Default or false
				local track = create("TextButton", {
					Parent = row,
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, 0, 0.5, 0),
					Size = UDim2.fromOffset(46, 26),
					BackgroundColor3 = state and COLORS.Beige or COLORS.TrackOff,
					Text = "",
					AutoButtonColor = false,
				})
				corner(track, 13)
				local knob = create("Frame", {
					Parent = track,
					AnchorPoint = Vector2.new(0, 0.5),
					Position = state and UDim2.new(1, -22, 0.5, 0) or UDim2.new(0, 4, 0.5, 0),
					Size = UDim2.fromOffset(18, 18),
					BackgroundColor3 = state and COLORS.BeigeText or COLORS.Knob,
					BorderSizePixel = 0,
				})
				corner(knob, 9)

				local function update()
					TweenService:Create(track, TweenInfo.new(0.18), { BackgroundColor3 = state and COLORS.Beige or COLORS.TrackOff }):Play()
					TweenService:Create(knob, TweenInfo.new(0.18), {
						Position = state and UDim2.new(1, -22, 0.5, 0) or UDim2.new(0, 4, 0.5, 0),
						BackgroundColor3 = state and COLORS.BeigeText or COLORS.Knob,
					}):Play()
				end

				track.MouseButton1Click:Connect(function()
					state = not state
					update()
					if tOpts.Callback then
						pcall(tOpts.Callback, state)
					end
				end)

				if state then update() end
				return Page
			end

			function Page:AddButton(bOpts)
				local row = baseRow(58)
				create("TextLabel", {
					Parent = row,
					Size = UDim2.new(1, -120, 0, 18),
					BackgroundTransparency = 1,
					Text = bOpts.Name or "Button",
					Font = Enum.Font.GothamBold,
					TextSize = 14,
					TextColor3 = COLORS.Text,
					TextXAlignment = Enum.TextXAlignment.Left,
				})
				create("TextLabel", {
					Parent = row,
					Position = UDim2.new(0, 0, 0, 20),
					Size = UDim2.new(1, -120, 1, -22),
					BackgroundTransparency = 1,
					Text = bOpts.Description or "",
					Font = Enum.Font.Gotham,
					TextSize = 12,
					TextColor3 = COLORS.Sub,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Top,
					TextWrapped = true,
				})
				local btn = create("TextButton", {
					Parent = row,
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, 0, 0.5, 0),
					Size = UDim2.fromOffset(96, 30),
					BackgroundColor3 = COLORS.Beige,
					Text = bOpts.Text or "Click",
					Font = Enum.Font.GothamBold,
					TextSize = 13,
					TextColor3 = COLORS.BeigeText,
					AutoButtonColor = true,
				})
				corner(btn, 8)
				btn.MouseButton1Click:Connect(function()
					if bOpts.Callback then
						pcall(bOpts.Callback)
					end
				end)
				return Page
			end

			function Page:AddDropdown(dOpts)
				local row = baseRow(58)
				create("TextLabel", {
					Parent = row,
					Size = UDim2.new(1, -190, 0, 18),
					BackgroundTransparency = 1,
					Text = dOpts.Name or "Dropdown",
					Font = Enum.Font.GothamBold,
					TextSize = 14,
					TextColor3 = COLORS.Text,
					TextXAlignment = Enum.TextXAlignment.Left,
				})
				create("TextLabel", {
					Parent = row,
					Position = UDim2.new(0, 0, 0, 20),
					Size = UDim2.new(1, -190, 1, -22),
					BackgroundTransparency = 1,
					Text = dOpts.Description or "",
					Font = Enum.Font.Gotham,
					TextSize = 12,
					TextColor3 = COLORS.Sub,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Top,
					TextWrapped = true,
				})

				local options = dOpts.Options or { "Option 1" }
				local current = dOpts.Default or options[1]

				local box = create("TextButton", {
					Parent = row,
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, 0, 0.5, 0),
					Size = UDim2.fromOffset(178, 30),
					BackgroundColor3 = COLORS.Dark,
					Text = "",
					AutoButtonColor = false,
				})
				corner(box, 15)
				stroke(box, COLORS.RowStroke, 1, 0.2)

				local label = create("TextLabel", {
					Parent = box,
					Size = UDim2.new(1, -30, 1, 0),
					Position = UDim2.new(0, 12, 0, 0),
					BackgroundTransparency = 1,
					Text = tostring(current),
					Font = Enum.Font.GothamMedium,
					TextSize = 12,
					TextColor3 = COLORS.Text,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextTruncate = Enum.TextTruncate.AtEnd,
				})
				create("TextLabel", {
					Parent = box,
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, -10, 0.5, 0),
					Size = UDim2.fromOffset(16, 16),
					BackgroundTransparency = 1,
					Text = "v",
					Font = Enum.Font.GothamBold,
					TextSize = 12,
					TextColor3 = COLORS.Sub,
				})

				local open = false
				local listFrame
				local function closeList()
					open = false
					if listFrame then
						listFrame:Destroy()
						listFrame = nil
					end
				end
				box.MouseButton1Click:Connect(function()
					if open then
						closeList()
						return
					end
					open = true
					listFrame = create("Frame", {
						Parent = gui,
						Size = UDim2.fromOffset(178, math.min(#options * 32 + 8, 160)),
						BackgroundColor3 = COLORS.PillBG,
						BorderSizePixel = 0,
						ZIndex = 50,
					})
					corner(listFrame, 10)
					stroke(listFrame, COLORS.RowStroke, 1, 0.1)
					padding(listFrame, 4, 4, 4, 4)
					local absPos = box.AbsolutePosition
					local absSize = box.AbsoluteSize
					listFrame.Position = UDim2.fromOffset(absPos.X, absPos.Y + absSize.Y + 4)
					create("UIListLayout", { Parent = listFrame, Padding = UDim.new(0, 2), SortOrder = Enum.SortOrder.LayoutOrder })
					for _, opt in ipairs(options) do
						local ob = create("TextButton", {
							Parent = listFrame,
							Size = UDim2.new(1, 0, 0, 30),
							BackgroundColor3 = (opt == current) and COLORS.PillActive or COLORS.PillBG,
							Text = "  " .. tostring(opt),
							Font = Enum.Font.GothamMedium,
							TextSize = 12,
							TextColor3 = COLORS.Text,
							TextXAlignment = Enum.TextXAlignment.Left,
							AutoButtonColor = false,
							ZIndex = 51,
						})
						corner(ob, 8)
						ob.MouseButton1Click:Connect(function()
							current = opt
							label.Text = tostring(opt)
							closeList()
							if dOpts.Callback then
								pcall(dOpts.Callback, opt)
							end
						end)
					end
				end)
				return Page
			end

			function Page:AddLabel(lOpts)
				local row = baseRow(52)
				create("TextLabel", {
					Parent = row,
					Size = UDim2.new(0.5, 0, 0, 18),
					BackgroundTransparency = 1,
					Text = lOpts.Name or "Label",
					Font = Enum.Font.GothamBold,
					TextSize = 14,
					TextColor3 = COLORS.Text,
					TextXAlignment = Enum.TextXAlignment.Left,
				})
				create("TextLabel", {
					Parent = row,
					Position = UDim2.new(0, 0, 0, 20),
					Size = UDim2.new(0.5, 0, 1, -22),
					BackgroundTransparency = 1,
					Text = lOpts.Description or "",
					Font = Enum.Font.Gotham,
					TextSize = 12,
					TextColor3 = COLORS.Sub,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextWrapped = true,
				})
				local val = create("TextLabel", {
					Parent = row,
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, 0, 0.5, 0),
					Size = UDim2.new(0.45, 0, 1, -10),
					BackgroundTransparency = 1,
					Text = lOpts.Value or "",
					Font = Enum.Font.GothamMedium,
					TextSize = 13,
					TextColor3 = Color3.fromRGB(200, 204, 216),
					TextXAlignment = Enum.TextXAlignment.Right,
					TextWrapped = true,
				})
				function Page:_updateLabel() end
				-- return setter
				local api = {}
				function api:Set(v)
					val.Text = tostring(v)
				end
				return api
			end

			function Page:AddSlider(sOpts)
				local row = baseRow(66)
				local min = sOpts.Min or 0
				local max = sOpts.Max or 100
				local val = sOpts.Default or 50
				create("TextLabel", {
					Parent = row,
					Size = UDim2.new(1, -60, 0, 18),
					BackgroundTransparency = 1,
					Text = sOpts.Name or "Slider",
					Font = Enum.Font.GothamBold,
					TextSize = 14,
					TextColor3 = COLORS.Text,
					TextXAlignment = Enum.TextXAlignment.Left,
				})
				local valLabel = create("TextLabel", {
					Parent = row,
					AnchorPoint = Vector2.new(1, 0),
					Position = UDim2.new(1, 0, 0, 0),
					Size = UDim2.fromOffset(50, 18),
					BackgroundTransparency = 1,
					Text = tostring(val),
					Font = Enum.Font.GothamMedium,
					TextSize = 12,
					TextColor3 = COLORS.Beige,
					TextXAlignment = Enum.TextXAlignment.Right,
				})
				local bar = create("TextButton", {
					Parent = row,
					Position = UDim2.new(0, 0, 0, 34),
					Size = UDim2.new(1, 0, 0, 8),
					BackgroundColor3 = COLORS.TrackOff,
					Text = "",
					AutoButtonColor = false,
				})
				corner(bar, 4)
				local fill = create("Frame", {
					Parent = bar,
					Size = UDim2.new((val - min) / math.max(1, (max - min)), 0, 1, 0),
					BackgroundColor3 = COLORS.Beige,
					BorderSizePixel = 0,
				})
				corner(fill, 4)
				local dragging = false
				local function setFromX(x)
					local absPos = bar.AbsolutePosition
					local absSize = bar.AbsoluteSize
					local p = math.clamp((x - absPos.X) / absSize.X, 0, 1)
					val = math.floor(min + (max - min) * p)
					fill.Size = UDim2.new(p, 0, 1, 0)
					valLabel.Text = tostring(val)
					if sOpts.Callback then
						pcall(sOpts.Callback, val)
					end
				end
				bar.InputBegan:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
						dragging = true
						setFromX(input.Position.X)
					end
				end)
				UserInputService.InputEnded:Connect(function(input)
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						dragging = false
					end
				end)
				UserInputService.InputChanged:Connect(function(input)
					if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
						setFromX(input.Position.X)
					end
				end)
				return Page
			end

			function Page:AddProgress(pOpts)
				local row = baseRow(58)
				create("TextLabel", {
					Parent = row,
					Size = UDim2.new(1, 0, 0, 16),
					BackgroundTransparency = 1,
					Text = pOpts.Name or "Progress",
					Font = Enum.Font.GothamMedium,
					TextSize = 12,
					TextColor3 = COLORS.Sub,
					TextXAlignment = Enum.TextXAlignment.Left,
				})
				local bar = create("Frame", {
					Parent = row,
					Position = UDim2.new(0, 0, 0, 26),
					Size = UDim2.new(1, 0, 0, 6),
					BackgroundColor3 = COLORS.TrackOff,
					BorderSizePixel = 0,
				})
				corner(bar, 3)
				local fill = create("Frame", {
					Parent = bar,
					Size = UDim2.new(pOpts.Value or 0.3, 0, 1, 0),
					BackgroundColor3 = COLORS.Beige,
					BorderSizePixel = 0,
				})
				corner(fill, 3)
				local api = {}
				function api:Set(v)
					fill.Size = UDim2.new(math.clamp(v, 0, 1), 0, 1, 0)
				end
				return api
			end

			function Page:AddSection(sOpts)
				local holder = create("Frame", {
					Parent = win._scroll,
					Size = UDim2.new(1, 0, 0, 28),
					BackgroundTransparency = 1,
					Visible = (win._currentPage == Page),
				})
				table.insert(Page.Rows, holder)
				local title = create("TextLabel", {
					Parent = holder,
					Size = UDim2.new(1, 0, 1, 0),
					BackgroundTransparency = 1,
					Text = string.upper(sOpts.Name or sOpts.Title or "SECTION"),
					Font = Enum.Font.GothamBold,
					TextSize = 12,
					TextColor3 = COLORS.Beige,
					TextXAlignment = Enum.TextXAlignment.Left,
				})
				create("Frame", {
					Parent = holder,
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, 0, 0.5, 0),
					Size = UDim2.new(1, -(#title.Text * 8 + 16), 0, 1),
					BackgroundColor3 = COLORS.RowStroke,
					BackgroundTransparency = 0.4,
					BorderSizePixel = 0,
				})
				return Page
			end

			function Page:AddParagraph(pOpts)
				local row = baseRow(72)
				create("TextLabel", {
					Parent = row,
					Size = UDim2.new(1, 0, 0, 18),
					BackgroundTransparency = 1,
					Text = pOpts.Title or pOpts.Name or "Paragraph",
					Font = Enum.Font.GothamBold,
					TextSize = 14,
					TextColor3 = COLORS.Text,
					TextXAlignment = Enum.TextXAlignment.Left,
				})
				local body = create("TextLabel", {
					Parent = row,
					Position = UDim2.new(0, 0, 0, 20),
					Size = UDim2.new(1, 0, 1, -22),
					BackgroundTransparency = 1,
					Text = pOpts.Body or pOpts.Description or pOpts.Text or "",
					Font = Enum.Font.Gotham,
					TextSize = 12,
					TextColor3 = COLORS.Sub,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Top,
					TextWrapped = true,
				})
				local api = {}
				function api:Set(t) body.Text = tostring(t) end
				return Page
			end

			function Page:AddInput(iOpts)
				local row = baseRow(58)
				create("TextLabel", {
					Parent = row,
					Size = UDim2.new(1, -190, 0, 18),
					BackgroundTransparency = 1,
					Text = iOpts.Name or "Input",
					Font = Enum.Font.GothamBold,
					TextSize = 14,
					TextColor3 = COLORS.Text,
					TextXAlignment = Enum.TextXAlignment.Left,
				})
				create("TextLabel", {
					Parent = row,
					Position = UDim2.new(0, 0, 0, 20),
					Size = UDim2.new(1, -190, 1, -22),
					BackgroundTransparency = 1,
					Text = iOpts.Description or "",
					Font = Enum.Font.Gotham,
					TextSize = 12,
					TextColor3 = COLORS.Sub,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Top,
					TextWrapped = true,
				})
				local box = create("TextBox", {
					Parent = row,
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, 0, 0.5, 0),
					Size = UDim2.fromOffset(178, 30),
					BackgroundColor3 = COLORS.Dark,
					Text = iOpts.Default or "",
					PlaceholderText = iOpts.Placeholder or "Type here...",
					Font = Enum.Font.GothamMedium,
					TextSize = 12,
					TextColor3 = COLORS.Text,
					PlaceholderColor3 = COLORS.Sub,
					TextXAlignment = Enum.TextXAlignment.Left,
					ClearTextOnFocus = false,
				})
				corner(box, 8)
				stroke(box, COLORS.RowStroke, 1, 0.2)
				padding(box, 10, 0, 10, 0)
				box.FocusLost:Connect(function(enter)
					if enter and iOpts.Callback then
						pcall(iOpts.Callback, box.Text)
					end
				end)
				local api = {}
				function api:Set(v) box.Text = tostring(v) end
				function api:Get() return box.Text end
				return api
			end

			function Page:AddKeybind(kOpts)
				local row = baseRow(58)
				create("TextLabel", {
					Parent = row,
					Size = UDim2.new(1, -130, 0, 18),
					BackgroundTransparency = 1,
					Text = kOpts.Name or "Keybind",
					Font = Enum.Font.GothamBold,
					TextSize = 14,
					TextColor3 = COLORS.Text,
					TextXAlignment = Enum.TextXAlignment.Left,
				})
				create("TextLabel", {
					Parent = row,
					Position = UDim2.new(0, 0, 0, 20),
					Size = UDim2.new(1, -130, 1, -22),
					BackgroundTransparency = 1,
					Text = kOpts.Description or "",
					Font = Enum.Font.Gotham,
					TextSize = 12,
					TextColor3 = COLORS.Sub,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextWrapped = true,
				})
				local current = kOpts.Default or Enum.KeyCode.F
				local function keyName(k)
					if typeof(k) == "EnumItem" then return k.Name end
					return tostring(k)
				end
				local btn = create("TextButton", {
					Parent = row,
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, 0, 0.5, 0),
					Size = UDim2.fromOffset(110, 30),
					BackgroundColor3 = COLORS.Dark,
					Text = keyName(current),
					Font = Enum.Font.GothamBold,
					TextSize = 12,
					TextColor3 = COLORS.Beige,
					AutoButtonColor = false,
				})
				corner(btn, 8)
				stroke(btn, COLORS.RowStroke, 1, 0.2)
				local listening = false
				btn.MouseButton1Click:Connect(function()
					listening = true
					btn.Text = "..."
				end)
				-- Executor-sicher: InputBegan feuert auch im Executor für Keyboard.
				-- Beim Binden (listening) wird gpe ignoriert, damit jede Taste übernommen wird.
				UserInputService.InputBegan:Connect(function(input, gpe)
					if listening then
						if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode ~= Enum.KeyCode.Unknown then
							listening = false
							current = input.KeyCode
							btn.Text = keyName(current)
							if kOpts.Callback then
								local ok, err = pcall(kOpts.Callback, current)
								if not ok then warn("[sable] keybind callback error: " .. tostring(err)) end
							end
						end
					elseif not gpe and input.KeyCode == current then
						if kOpts.Callback then
							local ok, err = pcall(kOpts.Callback, current)
							if not ok then warn("[sable] keybind callback error: " .. tostring(err)) end
						end
					end
				end)
				local api = {}
				function api:Set(k) current = k btn.Text = keyName(k) end
				function api:Get() return current end
				return api
			end

			function Page:AddColorpicker(cOpts)
				local row = baseRow(58)
				create("TextLabel", {
					Parent = row,
					Size = UDim2.new(1, -90, 0, 18),
					BackgroundTransparency = 1,
					Text = cOpts.Name or "Colorpicker",
					Font = Enum.Font.GothamBold,
					TextSize = 14,
					TextColor3 = COLORS.Text,
					TextXAlignment = Enum.TextXAlignment.Left,
				})
				create("TextLabel", {
					Parent = row,
					Position = UDim2.new(0, 0, 0, 20),
					Size = UDim2.new(1, -90, 1, -22),
					BackgroundTransparency = 1,
					Text = cOpts.Description or "",
					Font = Enum.Font.Gotham,
					TextSize = 12,
					TextColor3 = COLORS.Sub,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextWrapped = true,
				})
				local col = cOpts.Default or Color3.fromRGB(48, 255, 106)
				local preview = create("TextButton", {
					Parent = row,
					AnchorPoint = Vector2.new(1, 0.5),
					Position = UDim2.new(1, 0, 0.5, 0),
					Size = UDim2.fromOffset(44, 30),
					BackgroundColor3 = col,
					Text = "",
					AutoButtonColor = false,
				})
				corner(preview, 8)
				stroke(preview, COLORS.RowStroke, 1, 0.1)

				local open = false
				local pop = nil

				local function toHex(c)
					return string.format("#%02x%02x%02x", math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5))
				end
				local function fromHex(s)
					s = string.gsub(string.lower(tostring(s or "")), "#", "")
					if #s ~= 6 then return nil end
					local r = tonumber(string.sub(s, 1, 2), 16)
					local g = tonumber(string.sub(s, 3, 4), 16)
					local b = tonumber(string.sub(s, 5, 6), 16)
					if not r or not g or not b then return nil end
					return Color3.fromRGB(r, g, b)
				end

				preview.MouseButton1Click:Connect(function()
					if open and pop then open = false pop:Destroy() pop = nil return end
					open = true
					local orig = col
					local h, s, v = col:ToHSV()
					local cur = col
					local syncing = false

					pop = create("Frame", {
						Parent = gui,
						Size = UDim2.fromOffset(350, 372),
						BackgroundColor3 = Color3.fromRGB(22, 24, 33),
						BorderSizePixel = 0,
						ZIndex = 60,
					})
					corner(pop, 16)
					stroke(pop, COLORS.RowStroke, 1, 0.1)
					local pp = preview.AbsolutePosition
					pop.Position = UDim2.fromOffset(math.clamp(pp.X - 300, 8, 1200), math.max(8, pp.Y - 120))

					create("TextLabel", {
						Parent = pop,
						Position = UDim2.new(0, 16, 0, 12),
						Size = UDim2.new(1, -32, 0, 22),
						BackgroundTransparency = 1,
						Text = cOpts.Name or "Colorpicker",
						Font = Enum.Font.GothamBold,
						TextSize = 16,
						TextColor3 = COLORS.Text,
						TextXAlignment = Enum.TextXAlignment.Left,
						ZIndex = 61,
					})

					-- SV square
					local svBox = create("TextButton", {
						Parent = pop,
						Position = UDim2.new(0, 16, 0, 44),
						Size = UDim2.fromOffset(176, 168),
						BackgroundColor3 = Color3.fromHSV(h, 1, 1),
						Text = "",
						AutoButtonColor = false,
						ZIndex = 61,
					})
					corner(svBox, 10)
					local whiteOv = create("Frame", {
						Parent = svBox,
						Size = UDim2.new(1, 0, 1, 0),
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BorderSizePixel = 0,
						ZIndex = 62,
					})
					corner(whiteOv, 10)
					create("UIGradient", {
						Parent = whiteOv,
						Rotation = 0,
						Transparency = NumberSequence.new({
							NumberSequenceKeypoint.new(0, 0),
							NumberSequenceKeypoint.new(1, 1),
						}),
					})
					local blackOv = create("Frame", {
						Parent = svBox,
						Size = UDim2.new(1, 0, 1, 0),
						BackgroundColor3 = Color3.fromRGB(0, 0, 0),
						BorderSizePixel = 0,
						BackgroundTransparency = 0,
						ZIndex = 63,
					})
					corner(blackOv, 10)
					create("UIGradient", {
						Parent = blackOv,
						Rotation = 90,
						Transparency = NumberSequence.new({
							NumberSequenceKeypoint.new(0, 1),
							NumberSequenceKeypoint.new(1, 0),
						}),
					})
					local svDot = create("Frame", {
						Parent = svBox,
						AnchorPoint = Vector2.new(0.5, 0.5),
						Size = UDim2.fromOffset(14, 14),
						BackgroundColor3 = cur,
						BorderSizePixel = 0,
						ZIndex = 64,
					})
					corner(svDot, 7)
					stroke(svDot, Color3.fromRGB(255, 255, 255), 2, 0)

					-- Hue bar
					local hueBar = create("TextButton", {
						Parent = pop,
						Position = UDim2.new(0, 200, 0, 44),
						Size = UDim2.fromOffset(10, 168),
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						Text = "",
						AutoButtonColor = false,
						ZIndex = 61,
					})
					corner(hueBar, 5)
					create("UIGradient", {
						Parent = hueBar,
						Rotation = 90,
						Color = ColorSequence.new({
							ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
							ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
							ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
							ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
							ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
							ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
							ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
						}),
					})
					local hueDot = create("Frame", {
						Parent = hueBar,
						AnchorPoint = Vector2.new(0.5, 0.5),
						Size = UDim2.fromOffset(14, 14),
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BorderSizePixel = 0,
						ZIndex = 64,
					})
					corner(hueDot, 7)
					stroke(hueDot, Color3.fromRGB(255, 255, 255), 2, 0)

					-- Right inputs (Hex / R / G / B)
					local function makeField(y, initial, tag)
						local holder = create("Frame", {
							Parent = pop,
							Position = UDim2.new(0, 222, 0, y),
							Size = UDim2.new(1, -234, 0, 34),
							BackgroundColor3 = Color3.fromRGB(32, 35, 47),
							BorderSizePixel = 0,
							ZIndex = 61,
						})
						corner(holder, 8)
						local tb = create("TextBox", {
							Parent = holder,
							Position = UDim2.new(0, 10, 0, 0),
							Size = UDim2.new(1, -58, 1, 0),
							BackgroundTransparency = 1,
							Text = initial,
							Font = Enum.Font.GothamMedium,
							TextSize = 12,
							TextColor3 = COLORS.Text,
							TextXAlignment = Enum.TextXAlignment.Left,
							ClearTextOnFocus = false,
							ZIndex = 62,
						})
						create("TextLabel", {
							Parent = holder,
							AnchorPoint = Vector2.new(1, 0.5),
							Position = UDim2.new(1, -10, 0.5, 0),
							Size = UDim2.fromOffset(44, 16),
							BackgroundTransparency = 1,
							Text = tag,
							Font = Enum.Font.Gotham,
							TextSize = 12,
							TextColor3 = COLORS.Sub,
							TextXAlignment = Enum.TextXAlignment.Right,
							ZIndex = 62,
						})
						return tb
					end
					local hexBox = makeField(44, toHex(cur), "Hex")
					local rBox = makeField(86, tostring(math.floor(cur.R * 255 + 0.5)), "Red")
					local gBox = makeField(128, tostring(math.floor(cur.G * 255 + 0.5)), "Green")
					local bBox = makeField(170, tostring(math.floor(cur.B * 255 + 0.5)), "Blue")

					-- Preview bars (old vs new)
					local oldPrev = create("Frame", {
						Parent = pop,
						Position = UDim2.new(0, 16, 0, 224),
						Size = UDim2.new(0.5, -22, 0, 24),
						BackgroundColor3 = orig,
						BorderSizePixel = 0,
						ZIndex = 61,
					})
					corner(oldPrev, 7)
					local newPrev = create("Frame", {
						Parent = pop,
						Position = UDim2.new(0.5, 6, 0, 224),
						Size = UDim2.new(0.5, -22, 0, 24),
						BackgroundColor3 = cur,
						BorderSizePixel = 0,
						ZIndex = 61,
					})
					corner(newPrev, 7)

					-- Buttons
					local cancelBtn = create("TextButton", {
						Parent = pop,
						Position = UDim2.new(0, 16, 0, 262),
						Size = UDim2.new(0.5, -22, 0, 40),
						BackgroundColor3 = Color3.fromRGB(40, 43, 57),
						Text = "Abbrechen",
						Font = Enum.Font.GothamBold,
						TextSize = 14,
						TextColor3 = COLORS.Text,
						AutoButtonColor = false,
						ZIndex = 61,
					})
					corner(cancelBtn, 20)
					local applyBtn = create("TextButton", {
						Parent = pop,
						Position = UDim2.new(0.5, 6, 0, 262),
						Size = UDim2.new(0.5, -22, 0, 40),
						BackgroundColor3 = Color3.fromRGB(160, 165, 185),
						Text = "Apply",
						Font = Enum.Font.GothamBold,
						TextSize = 14,
						TextColor3 = Color3.fromRGB(25, 25, 30),
						AutoButtonColor = false,
						ZIndex = 61,
					})
					corner(applyBtn, 20)
					pop.Size = UDim2.fromOffset(350, 318)

					local function refresh()
						syncing = true
						svBox.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
						svDot.Position = UDim2.new(s, 0, 1 - v, 0)
						svDot.BackgroundColor3 = cur
						hueDot.Position = UDim2.new(0.5, 0, h, 0)
						newPrev.BackgroundColor3 = cur
						hexBox.Text = toHex(cur)
						rBox.Text = tostring(math.floor(cur.R * 255 + 0.5))
						gBox.Text = tostring(math.floor(cur.G * 255 + 0.5))
						bBox.Text = tostring(math.floor(cur.B * 255 + 0.5))
						syncing = false
					end
					refresh()

					local dragSV, dragH = false, false
					local function setSV(pos)
						local ap = svBox.AbsolutePosition
						local as = svBox.AbsoluteSize
						s = math.clamp((pos.X - ap.X) / math.max(1, as.X), 0, 1)
						v = 1 - math.clamp((pos.Y - ap.Y) / math.max(1, as.Y), 0, 1)
						cur = Color3.fromHSV(h, s, v)
						refresh()
					end
					local function setH(pos)
						local ap = hueBar.AbsolutePosition
						local as = hueBar.AbsoluteSize
						h = math.clamp((pos.Y - ap.Y) / math.max(1, as.Y), 0, 1)
						cur = Color3.fromHSV(h, s, v)
						refresh()
					end
					svBox.InputBegan:Connect(function(i)
						if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
							dragSV = true setSV(i.Position)
						end
					end)
					hueBar.InputBegan:Connect(function(i)
						if i.UserInputType == Enum.UserInputType.MouseButton1 or i.UserInputType == Enum.UserInputType.Touch then
							dragH = true setH(i.Position)
						end
					end)
					UserInputService.InputEnded:Connect(function(i)
						if i.UserInputType == Enum.UserInputType.MouseButton1 then dragSV = false dragH = false end
					end)
					UserInputService.InputChanged:Connect(function(i)
						if i.UserInputType == Enum.UserInputType.MouseMovement or i.UserInputType == Enum.UserInputType.Touch then
							if dragSV then setSV(i.Position) end
							if dragH then setH(i.Position) end
						end
					end)

					hexBox.FocusLost:Connect(function(enter)
						if not enter or syncing then return end
						local c = fromHex(hexBox.Text)
						if c then
							h, s, v = c:ToHSV() cur = c refresh()
						else
							hexBox.Text = toHex(cur)
						end
					end)
					local function bindNum(box)
						box.FocusLost:Connect(function(enter)
							if not enter or syncing then return end
							local r = math.clamp(tonumber(rBox.Text) or (cur.R * 255), 0, 255)
							local g = math.clamp(tonumber(gBox.Text) or (cur.G * 255), 0, 255)
							local b = math.clamp(tonumber(bBox.Text) or (cur.B * 255), 0, 255)
							cur = Color3.fromRGB(r, g, b) h, s, v = cur:ToHSV() refresh()
						end)
					end
					bindNum(rBox) bindNum(gBox) bindNum(bBox)

					cancelBtn.MouseButton1Click:Connect(function()
						open = false if pop then pop:Destroy() pop = nil end
					end)
					applyBtn.MouseButton1Click:Connect(function()
						col = cur
						preview.BackgroundColor3 = col
						if cOpts.Callback then pcall(cOpts.Callback, col) end
						open = false if pop then pop:Destroy() pop = nil end
					end)
				end)
				local api = {}
				function api:Set(c) col = c preview.BackgroundColor3 = c end
				function api:Get() return col end
				return api
			end

			function Page:AddCode(cOpts)
				local row = baseRow(96)
				create("TextLabel", {
					Parent = row,
					Size = UDim2.new(1, -70, 0, 18),
					BackgroundTransparency = 1,
					Text = cOpts.Title or cOpts.Name or "Code",
					Font = Enum.Font.GothamBold,
					TextSize = 14,
					TextColor3 = COLORS.Text,
					TextXAlignment = Enum.TextXAlignment.Left,
				})
				local copy = create("TextButton", {
					Parent = row,
					AnchorPoint = Vector2.new(1, 0),
					Position = UDim2.new(1, 0, 0, 0),
					Size = UDim2.fromOffset(56, 22),
					BackgroundColor3 = COLORS.Dark,
					Text = "Copy",
					Font = Enum.Font.GothamBold,
					TextSize = 11,
					TextColor3 = COLORS.Beige,
					AutoButtonColor = false,
				})
				corner(copy, 6)
				stroke(copy, COLORS.RowStroke, 1, 0.3)
				local codeBox = create("TextBox", {
					Parent = row,
					Position = UDim2.new(0, 0, 0, 26),
					Size = UDim2.new(1, 0, 1, -28),
					BackgroundColor3 = COLORS.Dark,
					Text = cOpts.Code or "-- code",
					Font = Enum.Font.Code,
					TextSize = 12,
					TextColor3 = Color3.fromRGB(200, 210, 220),
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Top,
					TextWrapped = true,
					MultiLine = true,
					ClearTextOnFocus = false,
					TextEditable = (cOpts.Editable ~= false),
				})
				corner(codeBox, 6)
				stroke(codeBox, COLORS.RowStroke, 1, 0.3)
				padding(codeBox, 8, 6, 8, 6)
				copy.MouseButton1Click:Connect(function()
					pcall(function()
						if setclipboard then setclipboard(codeBox.Text) end
					end)
					copy.Text = "Copied"
					task.delay(1, function() pcall(function() copy.Text = "Copy" end) end)
					if cOpts.Callback then pcall(cOpts.Callback, codeBox.Text) end
				end)
				local api = {}
				function api:Set(t) codeBox.Text = tostring(t) end
				function api:Get() return codeBox.Text end
				return api
			end

			table.insert(self.Pages, Page)
			table.insert(win._pages, Page)
			if isFirstOverall then
				win._currentTab = self
				win._currentPage = Page
				stylePill(topPill, true)
				topPill.Visible = true
			else
				stylePill(topPill, false)
				topPill.Visible = (win._currentTab == self)
				-- rows bleiben versteckt bis Seite gewählt wird (baseRow prüft _currentPage)
			end
			return Page
		end

		table.insert(self._tabs, Tab)
		if isActive then
			self._currentTab = Tab
		end
		return Tab
	end

	function Window:Notify(nOpts)
		local holderName = "NotifyHolder"
		local holder = gui:FindFirstChild(holderName)
		if not holder then
			holder = create("Frame", {
				Name = holderName,
				Parent = gui,
				AnchorPoint = Vector2.new(1, 1),
				Position = UDim2.new(1, -16, 1, -16),
				Size = UDim2.fromOffset(260, 200),
				BackgroundTransparency = 1,
			})
			create("UIListLayout", { Parent = holder, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8), VerticalAlignment = Enum.VerticalAlignment.Bottom })
		end
		local n = create("Frame", {
			Parent = holder,
			Size = UDim2.new(1, 0, 0, 64),
			BackgroundColor3 = COLORS.RowBG,
			BorderSizePixel = 0,
		})
		corner(n, 10)
		stroke(n, COLORS.RowStroke, 1, 0.2)
		padding(n, 12, 8, 12, 8)
		create("TextLabel", {
			Parent = n,
			Size = UDim2.new(1, 0, 0, 18),
			BackgroundTransparency = 1,
			Text = nOpts.Title or "sable",
			Font = Enum.Font.GothamBold,
			TextSize = 13,
			TextColor3 = COLORS.Beige,
			TextXAlignment = Enum.TextXAlignment.Left,
		})
		create("TextLabel", {
			Parent = n,
			Position = UDim2.new(0, 0, 0, 20),
			Size = UDim2.new(1, 0, 1, -20),
			BackgroundTransparency = 1,
			Text = nOpts.Description or "",
			Font = Enum.Font.Gotham,
			TextSize = 12,
			TextColor3 = COLORS.Text,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextWrapped = true,
		})
		task.delay(nOpts.Duration or 3, function()
			pcall(function()
				TweenService:Create(n, TweenInfo.new(0.3), { BackgroundTransparency = 1 }):Play()
				task.wait(0.3)
				n:Destroy()
			end)
		end)
	end

	return Window
end

return SableLib
