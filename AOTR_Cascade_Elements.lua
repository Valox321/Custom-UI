-- AOTR Cascade Elements
-- Reusable UI wrappers for Cascade. This module contains no game automation.
--
-- GitHub usage:
-- local UI = loadstring(game:HttpGet("RAW_GITHUB_URL/AOTR_Cascade_Elements.lua"))()
-- local kit = UI.new()
-- local window = kit:Window({ Title = "Valox", Subtitle = "AOTR - Revolution" })
-- local section = kit:Section(window, { Title = "In-Game" })
-- local tab = kit:Tab(section, { Title = "Farming", Icon = kit.Symbols.leaf })
-- local form = kit:Form(tab, { Title = "Auto Farm", Subtitle = "Farm settings." })
-- form:Status({ Key = "farmStatus", Title = "Status", Value = "Idle" })
-- form:Toggle({ Key = "autoFarm", Title = "Auto Farm", Value = false,
--     OnChanged = function(value) print("Auto Farm:", value) end })

local DEFAULT_CASCADE_URL = "https://github.com/cascadeui/Cascade/releases/latest/download/dist.luau"

local UI = {}
local Kit = {}
local Form = {}

Kit.__index = Kit
Form.__index = Form

local function requireTable(value, name)
    assert(type(value) == "table", name .. " must be a table")
    return value
end

local function getCascade(options)
    if options.Cascade then
        return options.Cascade
    end

    local url = options.CascadeUrl or DEFAULT_CASCADE_URL
    local source = game:HttpGetAsync(url)
    local loader = loadstring(source)
    assert(type(loader) == "function", "Could not compile Cascade UI")
    return loader()
end

function UI.new(options)
    options = options or {}
    local cascade = getCascade(options)
    assert(type(cascade) == "table" and type(cascade.New) == "function", "Cascade UI failed to load")

    local app = cascade.New(options.AppOptions or {})
    return setmetatable({
        Cascade = cascade,
        App = app,
        Symbols = cascade.Symbols,
        State = options.State or {},
    }, Kit)
end

function Kit:Window(options)
    self.WindowInstance = self.App:Window(options or {})
    return self.WindowInstance
end

function Kit:Section(parent, options)
    requireTable(parent, "parent")
    return parent:Section(options or {})
end

function Kit:Tab(parent, options)
    requireTable(parent, "parent")
    return parent:Tab(options or {})
end

function Kit:Form(parent, options)
    requireTable(parent, "parent")
    local pageSection = parent:PageSection(options or {})
    return setmetatable({
        Raw = pageSection:Form(),
        State = self.State,
        Controls = {},
    }, Form)
end

function Form:_row(options)
    options = options or {}
    local title = options.Title or ""
    local row = self.Raw:Row({ SearchIndex = options.SearchIndex or title })
    row:Left():TitleStack({
        Title = title,
        Subtitle = options.Subtitle,
    })
    return row
end

function Form:Info(options)
    return self:_row(options)
end

function Form:Status(options)
    options = options or {}
    local key = options.Key
    local value = options.Value == nil and "" or tostring(options.Value)
    local row = self:_row(options)
    local label = row:Right():Label({ Text = value })
    if key then
        self.State[key] = value
        self.Controls[key] = label
    end
    return label
end

function Form:SetStatus(key, value)
    local label = self.Controls[key]
    if label then
        local text = tostring(value)
        self.State[key] = text
        label.Text = text
    end
    return label
end

function Form:Toggle(options)
    options = options or {}
    local key = options.Key
    local value = options.Value == true
    local row = self:_row(options)
    local control = row:Right():Toggle({
        Value = value,
        ValueChanged = function(_, newValue)
            if key then
                self.State[key] = newValue
            end
            if options.OnChanged then
                options.OnChanged(newValue)
            end
        end,
    })
    if key then
        self.State[key] = value
        self.Controls[key] = control
    end
    return control
end

function Form:Slider(options)
    options = options or {}
    local key = options.Key
    local value = options.Value or options.Minimum or 0
    local row = self.Raw:Row({ SearchIndex = options.SearchIndex or options.Title or "Slider" })
    local titleStack = row:Left():TitleStack({
        Title = options.Title or "",
        Subtitle = options.Subtitle,
    })
    local control = row:Right():Slider({
        Minimum = options.Minimum or 0,
        Maximum = options.Maximum or 100,
        Step = options.Step,
        Value = value,
        ValueChanged = function(_, newValue)
            if key then
                self.State[key] = newValue
            end
            if options.Format then
                titleStack.Subtitle = options.Format(newValue)
            end
            if options.OnChanged then
                options.OnChanged(newValue)
            end
        end,
    })
    if key then
        self.State[key] = value
        self.Controls[key] = control
    end
    return control, titleStack
end

function Form:Dropdown(options)
    options = options or {}
    local choices = requireTable(options.Options, "Options")
    assert(#choices > 0, "Dropdown Options cannot be empty")
    local key = options.Key
    local selected = options.Value or choices[1]
    local selectedIndex = table.find(choices, selected) or 1
    selected = choices[selectedIndex]
    local row = self:_row(options)
    local control = row:Right():PullDownButton({
        Label = selected,
        Options = table.clone(choices),
        Value = selectedIndex,
        ValueChanged = function(button, index)
            local newValue = button.Options[index]
            if newValue ~= nil then
                if key then
                    self.State[key] = newValue
                end
                button.Label = newValue
                if options.OnChanged then
                    options.OnChanged(newValue, index, button)
                end
            end
        end,
    })
    if key then
        self.State[key] = selected
        self.Controls[key] = control
    end
    return control
end

function Form:MultiSelect(options)
    options = options or {}
    local choices = requireTable(options.Options, "Options")
    local key = options.Key
    local maximum = options.Maximum or #choices
    local selectedIndexes = {}
    local selectedValues = {}

    for _, selectedValue in ipairs(options.Value or {}) do
        local index = table.find(choices, selectedValue)
        if index and #selectedIndexes < maximum then
            selectedIndexes[#selectedIndexes + 1] = index
            selectedValues[#selectedValues + 1] = selectedValue
        end
    end

    local row = self:_row(options)
    local control = row:Right():PopUpButton({
        Options = table.clone(choices),
        Maximum = maximum,
        Value = selectedIndexes,
        ValueChanged = function(button, indexes)
            local values = {}
            for _, index in ipairs(indexes or {}) do
                local option = button.Options[index]
                if option ~= nil then
                    values[#values + 1] = option
                end
            end
            if key then
                self.State[key] = values
            end
            if options.OnChanged then
                options.OnChanged(values, indexes or {}, button)
            end
        end,
    })
    if key then
        self.State[key] = selectedValues
        self.Controls[key] = control
    end
    return control
end

function Form:TextField(options)
    options = options or {}
    local key = options.Key
    local value = options.Value or ""
    local row = self:_row(options)
    local control = row:Right():TextField({
        Value = value,
        Placeholder = options.Placeholder,
        ValueChanged = function(_, newValue)
            if key then
                self.State[key] = newValue
            end
            if options.OnChanged then
                options.OnChanged(newValue)
            end
        end,
    })
    if key then
        self.State[key] = value
        self.Controls[key] = control
    end
    return control
end

function Form:Button(options)
    options = options or {}
    local row = self:_row(options)
    return row:Right():Button({
        Label = options.Label or "Go",
        State = options.Style or "Primary",
        Pushed = function(button)
            if options.OnClick then
                options.OnClick(button)
            end
        end,
    })
end

return UI
