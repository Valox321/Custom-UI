local Services = {
    Players = game:GetService("Players"),
    StarterGui = game:GetService("StarterGui"),
    GuiService = game:GetService("GuiService"),
    VirtualInputManager = game:GetService("VirtualInputManager"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    TeleportService = game:GetService("TeleportService"),
    VirtualUser = game:GetService("VirtualUser"),
    UserInputService = game:GetService("UserInputService"),
    RunService = game:GetService("RunService"),
    Lighting = game:GetService("Lighting"),
    TweenService = game:GetService("TweenService"),
    HttpService = game:GetService("HttpService"),
    CollectionService = game:GetService("CollectionService"),
}

local Players = Services.Players

if not game:IsLoaded() then
    game.Loaded:Wait()
end

local LocalPlayer = Players.LocalPlayer or Players.PlayerAdded:Wait()
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")
local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local cascade = loadstring(game:HttpGetAsync("https://github.com/cascadeui/Cascade/releases/latest/download/dist.luau"))()

local App = cascade.New({})
local configRecorder = cascade.AppRecorder.new(App):Start()

local epicFamilyOptions = {
    "Any", "GALLIARD", "ZOE", "LEONHART", "TYBUR", "KSAVER", "BRAUN", "FINGER", "ARLERT",
}
local legendaryFamilyOptions = { "Any", "YEAGER", "ACKERMAN", "REISS" }
local mythicFamilyOptions = { "Any", "FRITZ", "HELOS" }

local selectedEpicFamilies = {}
local selectedLegendaryFamilies = {}
local selectedMythicFamilies = {}
local autoStoreFamily = false
local autoRollFamilyEnabled = false
local autoRollFamilyRunId = 0
local autoRollFamilyToggle
local familyStatusLabel
local selectedCharacterSlot = "A"
local autoSelectCharacterEnabled = false
local autoSelectCharacterRunId = 0
local autoSelectCharacterToggle
local autoSelectStatusLabel
local goToLobbyAfterCharacterSelect = true
local selectedGearWeapon = "Blades"
local autoUpgradeGearEnabled = false
local autoUpgradeGearRunId = 0
local autoUpgradeGearToggle
local autoFarmToggle
local windowBodyInstance
local autoLobbyRewardConnection
local SoloOnly = {
    enabled = false,
    playerAddedConnection = nil,
    checkedForSession = false,
}
local VisualFeatures = {
    removeFogEnabled = true,
    fogDensity = 0.15,
    atmosphere = nil,
    originalDensity = nil,
    originalDensities = setmetatable({}, { __mode = "k" }),
    densityConnection = nil,
    lightingConnection = nil,
    reapplyingFog = false,
    napeExtenderEnabled = false,
    napeOriginals = setmetatable({}, { __mode = "k" }),
    napeFolder = nil,
    napeChildAddedConnection = nil,
    napeWorkspaceConnection = nil,
    titanEspEnabled = false,
    titanEspFolder = nil,
    titanHighlights = {},
    titanChildAddedConnection = nil,
    titanChildRemovedConnection = nil,
    titanWorkspaceConnection = nil,
}
local AutoLobby = {
    enabled = false,
    after = 10,
    completedSessions = 0,
    returning = false,
    titleStack = nil,
}
local FarmFeatures = {
    enabled = false,
    runId = 0,
    executeEnabled = false,
    hoverHeight = 200,
    hoverSpeed = 500,
    waitBeforeFarming = 5,
    missionSafetyTimer = 120,
    raidSafetyTimer = 300,
    statusLabel = nil,
    currentStatus = "Idle",
    lastAttackTime = 0,
    lastSessionSeconds = nil,
    lastSessionSecondsChangedAt = 0,
    soloOnlyCheckedForSession = false,
    movementConnection = nil,
    movementBodyPosition = nil,
    movementTarget = nil,
    movementNape = nil,
    movementHumanoid = nil,
    noclipRunId = 0,
    noclipCharacterConnection = nil,
    noclipDescendantConnection = nil,
    noclipParts = {},
}
local AutoRetry = {
    enabled = false,
    runId = 0,
    busy = false,
    lastHandledAt = 0,
    rewardChangedConnection = nil,
    forceEndChangedConnection = nil,
}
local CombatFeatures = {
    autoGrabEscapeEnabled = true,
    autoGrabEscapeRunId = 0,
    escapeButtonsFolder = nil,
    escapeFolderConnection = nil,
    escapeChildConnection = nil,
    autoReloadBladesEnabled = true,
    autoFullReloadEnabled = true,
    combatReloadRunId = 0,
    combatReloading = false,
    lastBladeReloadTime = 0,
    lastFullReloadTime = 0,
    fullReloadPending = false,
    fullReloadPendingSince = 0,
    lastRefillSearchTime = 0,
    cachedRefillPart = nil,
}
local missionMaps = {
    { Name = "Shiganshina", Objectives = { "Skirmish", "Breach" } },
    { Name = "Trost", Objectives = { "Skirmish", "Protect" } },
    { Name = "Outskirts", Objectives = { "Skirmish", "Escort" } },
    { Name = "Forest", Objectives = { "Skirmish", "Guard" } },
    { Name = "Utgard", Objectives = { "Skirmish", "Defend" } },
    { Name = "Docks", Objectives = { "Skirmish", "Stall" } },
    { Name = "Stohess", Objectives = { "Skirmish" } },
    { Name = "Chapel", Objectives = { "Skirmish" } },
}
local missionDifficulties = { "Easy", "Normal", "Hard", "Severe", "Aberrant" }
local missionModifiers = {
    "No Perks", "No Skills", "No Memories", "Nightmare", "Oddball", "Injury Prone",
    "Chronic Injuries", "Fog", "Time Trial", "Glass Cannon", "Boring", "Simple",
}
local selectedMissionMap = "Shiganshina"
local selectedMissionObjective = "Skirmish"
local selectedMissionDifficulty = "Normal"
local selectedMissionModifiers = {}
local autoCreateMissionEnabled = false
local autoCreateMissionRunId = 0
local autoCreateMissionToggle
local missionBoostMapLabel
local missionObjectiveDropdown
local missionDifficultyDropdown
local updatingMissionObjectives = false
local raidObjectives = { "Attack Titan", "Armored Titan", "Female Titan", "Colossal Titan" }
local raidDifficulties = { "Hard", "Severe", "Aberrant" }
local raidObjectiveMaps = {
    ["Attack Titan"] = "Trost",
    ["Armored Titan"] = "Shiganshina",
    ["Female Titan"] = "Stohess",
    ["Colossal Titan"] = "Shiganshina",
}
local selectedRaidObjective = "Attack Titan"
local selectedRaidDifficulty = "Aberrant"
local selectedRaidModifiers = {}
local raidDifficultyDropdown
local autoCreateRaidEnabled = false
local autoCreateRaidRunId = 0
local autoCreateRaidToggle
local autoCreateWaveEnabled = false
local autoCreateWaveRunId = 0
local autoCreateWaveToggle
local autoClaimAchievementsEnabled = false
local autoClaimAchievementsRunId = 0
local autoClaimAchievementsToggle
local prestigeMinGold = { 0, 0, 0, 0, 0 }
local prestigeBoosts = { "Gold", "Gold", "Gold", "Gold", "Gold" }
local autoPrestigeEnabled = false
local autoPrestigeRunId = 0
local autoPrestigeToggle
local prestigeStatusLabel

local function setAutoSelectStatus(message)
    if autoSelectStatusLabel then
        autoSelectStatusLabel.Text = message
    end
end

local function setFamilyStatus(message)
    if familyStatusLabel then
        familyStatusLabel.Text = message
    end
end

local function getFamilyScreen()
    local current = PlayerGui
    for _, childName in ipairs({ "Interface", "Customisation", "Family" }) do
        current = current and current:FindFirstChild(childName)
    end
    return current
end

local function getCurrentFamily()
    local familyScreen = getFamilyScreen()
    local familyContainer = familyScreen and familyScreen:FindFirstChild("Family")
    local title = familyContainer and familyContainer:FindFirstChild("Title")
    local titleText = title and title.Text
    return type(titleText) == "string" and titleText:match("^(%S+)") or nil
end

local function getTargetFamilies()
    local targets = {}

    local function addSelectedFamilies(selectedFamilies, options)
        local includesAny = table.find(selectedFamilies, "Any") ~= nil
        if includesAny then
            for _, familyName in ipairs(options) do
                if familyName ~= "Any" and not table.find(targets, familyName) then
                    table.insert(targets, familyName)
                end
            end
        else
            for _, familyName in ipairs(selectedFamilies) do
                if familyName ~= "Any" and not table.find(targets, familyName) then
                    table.insert(targets, familyName)
                end
            end
        end
    end

    addSelectedFamilies(selectedEpicFamilies, epicFamilyOptions)
    addSelectedFamilies(selectedLegendaryFamilies, legendaryFamilyOptions)
    addSelectedFamilies(selectedMythicFamilies, mythicFamilyOptions)
    return targets
end

local isFamilyRollActive

local function pressFamilyButton(buttonName, runId)
    if not isFamilyRollActive(runId) then
        return nil
    end

    local familyScreen = getFamilyScreen()
    local buttons = familyScreen and familyScreen:FindFirstChild("Buttons_2")
    local button = buttons and buttons:FindFirstChild(buttonName)
    if not button then
        return false
    end

    Services.GuiService.SelectedObject = button
    task.wait(0.1)
    if not isFamilyRollActive(runId) then
        Services.GuiService.SelectedObject = nil
        return nil
    end

    Services.VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
    task.wait(0.1)
    Services.VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
    task.wait(0.6)
    if not isFamilyRollActive(runId) then
        Services.GuiService.SelectedObject = nil
        return nil
    end

    local interface = PlayerGui:FindFirstChild("Interface")
    local warning = interface and interface:FindFirstChild("Warning")
    local prompt = warning and warning:FindFirstChild("Prompt")
    local main = prompt and prompt:FindFirstChild("Main")
    local confirmButton = main and main:FindFirstChild("Yes")
    if warning and warning.Visible and confirmButton then
        Services.GuiService.SelectedObject = confirmButton
        task.wait(0.1)
        if not isFamilyRollActive(runId) then
            Services.GuiService.SelectedObject = nil
            return nil
        end

        Services.VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
        task.wait(0.1)
        Services.VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
        task.wait(0.3)
    end

    return true
end

isFamilyRollActive = function(runId)
    return autoRollFamilyEnabled and autoRollFamilyRunId == runId
end

local function stopFamilyRoll(message)
    autoRollFamilyEnabled = false
    autoRollFamilyRunId += 1
    Services.GuiService.SelectedObject = nil
    if autoRollFamilyToggle then
        autoRollFamilyToggle.Value = false
    end
    setFamilyStatus(message)
end

local function runFamilyRoll(runId)
    local targets = getTargetFamilies()
    if #targets == 0 then
        stopFamilyRoll("Choose a target family first.")
        return
    end

    setFamilyStatus("Waiting for the Family panel...")
    local deadline = os.clock() + 15
    while isFamilyRollActive(runId) do
        local familyScreen = getFamilyScreen()
        if familyScreen and familyScreen.Visible then
            break
        end
        if os.clock() >= deadline then
            stopFamilyRoll("Open Customisation > Family first.")
            return
        end
        task.wait(0.5)
    end

    if not isFamilyRollActive(runId) then
        return
    end

    local currentFamily = getCurrentFamily()
    if currentFamily and table.find(targets, currentFamily) then
        if autoStoreFamily then
            setFamilyStatus("Storing " .. currentFamily .. "...")
            local stored = pressFamilyButton("Store", runId)
            if stored == nil then
                return
            elseif not stored then
                stopFamilyRoll("Could not find the Store button.")
                return
            end
        else
            stopFamilyRoll("Target found: " .. currentFamily)
            return
        end
    end

    setFamilyStatus("Rolling for a target family...")
    local rolled = pressFamilyButton("Roll", runId)
    if rolled == nil then
        return
    elseif not rolled then
        stopFamilyRoll("Could not find the Roll button.")
        return
    end

    while isFamilyRollActive(runId) do
        task.wait(4)
        if not isFamilyRollActive(runId) then
            return
        end

        local familyScreen = getFamilyScreen()
        if not familyScreen or not familyScreen.Visible then
            stopFamilyRoll("Family panel closed. Rolling stopped.")
            return
        end

        currentFamily = getCurrentFamily()
        if currentFamily and table.find(targets, currentFamily) then
            if autoStoreFamily then
                setFamilyStatus("Storing " .. currentFamily .. "; continuing to roll...")
                local stored = pressFamilyButton("Store", runId)
                if stored == nil then
                    return
                elseif not stored then
                    stopFamilyRoll("Could not find the Store button.")
                    return
                end
                if isFamilyRollActive(runId) then
                    local continued = pressFamilyButton("Roll", runId)
                    if continued == false then
                        stopFamilyRoll("Could not find the Roll button.")
                        return
                    end
                end
            else
                stopFamilyRoll("Target found: " .. currentFamily)
                return
            end
        else
            setFamilyStatus("Rolling... Last result: " .. (currentFamily or "unknown"))
            local rolled = pressFamilyButton("Roll", runId)
            if rolled == nil then
                return
            elseif not rolled then
                stopFamilyRoll("Could not find the Roll button.")
                return
            end
        end
    end
end

local function isAutoSelectCharacterActive(runId)
    return autoSelectCharacterEnabled and autoSelectCharacterRunId == runId
end

local function stopAutoSelectCharacter(message)
    autoSelectCharacterEnabled = false
    autoSelectCharacterRunId += 1
    if autoSelectCharacterToggle then
        autoSelectCharacterToggle.Value = false
    end
    if message then
        setAutoSelectStatus(message)
    end
end

local function invokeActorFunction(remoteName, functionName, argument)
    local assets = Services.ReplicatedStorage:FindFirstChild("Assets")
    local remotes = assets and assets:FindFirstChild("Remotes")
    local getRemote = remotes and remotes:FindFirstChild("GET")
    if not getRemote then
        return { ok = false, err = "GET remote not found" }
    end

    local callSucceeded, result, secondResult, thirdResult = pcall(function()
        if argument == nil then
            return getRemote:InvokeServer(remoteName, functionName)
        end
        return getRemote:InvokeServer(remoteName, functionName, argument)
    end)
    if not callSucceeded then
        return { ok = false, err = tostring(result) }
    end

    -- Match Mahmut.lua's hub.Actor.invoke: a non-nil first remote result means the invoke returned.
    if result ~= nil then
        return { ok = true, data = true, result = result, secondResult = secondResult, thirdResult = thirdResult }
    end
    return { ok = false, err = "invoke_failed" }
end

function CombatFeatures.getPostRemote()
    local assets = Services.ReplicatedStorage:FindFirstChild("Assets")
    local remotes = assets and assets:FindFirstChild("Remotes")
    return remotes and remotes:FindFirstChild("POST")
end

function CombatFeatures.sendPost(remoteName, functionName, ...)
    local postRemote = CombatFeatures.getPostRemote()
    if not postRemote then
        return false
    end
    local arguments = table.pack(...)
    return pcall(function()
        postRemote:FireServer(remoteName, functionName, table.unpack(arguments, 1, arguments.n))
    end)
end

function CombatFeatures.getNearestEscapeNape()
    local character = LocalPlayer.Character
    local rootPart = character and character:FindFirstChild("HumanoidRootPart")
    local titans = workspace:FindFirstChild("Titans")
    if not rootPart or not titans then
        return nil
    end

    local nearestNape
    local nearestDistance = math.huge
    for _, titan in ipairs(titans:GetChildren()) do
        local humanoid = titan:IsA("Model") and titan:FindFirstChildOfClass("Humanoid")
        local state = titan:GetAttribute("State")
        if humanoid and state ~= nil and state ~= "Roar" and state ~= "HeatWave" then
            local hitboxes = titan:FindFirstChild("Hitboxes")
            local hit = hitboxes and hitboxes:FindFirstChild("Hit")
            local nape = hit and hit:FindFirstChild("Nape")
            if not nape then
                local hitFolder = titan:FindFirstChild("Hit", true)
                nape = hitFolder and hitFolder:FindFirstChild("Nape")
            end
            if nape and nape:IsA("BasePart") then
                local distance = (rootPart.Position - nape.Position).Magnitude
                if distance < nearestDistance then
                    nearestDistance = distance
                    nearestNape = nape
                end
            end
        end
    end
    return nearestNape
end

function CombatFeatures.getAstraFarmTargets()
    local titans = workspace:FindFirstChild("Titans")
    local targets = {}
    if not titans then
        return targets
    end

    for _, titan in ipairs(titans:GetChildren()) do
        if not titan:GetAttribute("Killed") then
            local hitboxes = titan:FindFirstChild("Hitboxes")
            local hit = hitboxes and hitboxes:FindFirstChild("Hit")
            local nape = hit and hit:FindFirstChild("Nape")
            local fake = titan:FindFirstChild("Fake")
            local collision = fake and fake:FindFirstChild("Collision")
            if nape and nape:IsA("BasePart") and not (collision and not collision.CanCollide) then
                table.insert(targets, nape)
            end
        end
    end
    return targets
end

function CombatFeatures.getEscapeButtonsFolder()
    local interface = PlayerGui:FindFirstChild("Interface")
    return interface and interface:FindFirstChild("Buttons")
end

function CombatFeatures.disconnectEscapeConnections()
    if CombatFeatures.escapeChildConnection then
        CombatFeatures.escapeChildConnection:Disconnect()
        CombatFeatures.escapeChildConnection = nil
    end
    if CombatFeatures.escapeFolderConnection then
        CombatFeatures.escapeFolderConnection:Disconnect()
        CombatFeatures.escapeFolderConnection = nil
    end
    CombatFeatures.escapeButtonsFolder = nil
end

function CombatFeatures.attachAutoGrabEscape(folder, runId)
    if not folder or not CombatFeatures.autoGrabEscapeEnabled or CombatFeatures.autoGrabEscapeRunId ~= runId then
        return false
    end
    if CombatFeatures.escapeButtonsFolder == folder and CombatFeatures.escapeChildConnection then
        return true
    end

    CombatFeatures.disconnectEscapeConnections()
    CombatFeatures.escapeButtonsFolder = folder
    CombatFeatures.escapeChildConnection = folder.ChildAdded:Connect(function(newChild)
        if not CombatFeatures.autoGrabEscapeEnabled then
            return
        end
        task.wait(0.15)
        CombatFeatures.sendPost("Attacks", "Slash_Escape")
        pcall(function()
            newChild:Destroy()
        end)
        task.wait(0.3)

        local nape = CombatFeatures.getNearestEscapeNape()
        if nape then
            CombatFeatures.sendPost("Attacks", "Slash", true)
            CombatFeatures.sendPost(
                "Hitboxes",
                "Register",
                nape,
                math.random(200, 400),
                math.random(100, 800) / 1000
            )
        end
    end)
    return true
end

function CombatFeatures.setAutoGrabEscapeEnabled(value)
    CombatFeatures.autoGrabEscapeEnabled = value
    CombatFeatures.autoGrabEscapeRunId += 1
    local runId = CombatFeatures.autoGrabEscapeRunId
    if not value then
        CombatFeatures.disconnectEscapeConnections()
        return
    end

    if CombatFeatures.attachAutoGrabEscape(CombatFeatures.getEscapeButtonsFolder(), runId) then
        return
    end
    task.spawn(function()
        while CombatFeatures.autoGrabEscapeEnabled and CombatFeatures.autoGrabEscapeRunId == runId do
            if CombatFeatures.attachAutoGrabEscape(CombatFeatures.getEscapeButtonsFolder(), runId) then
                return
            end
            task.wait(0.2)
        end
    end)
end

function CombatFeatures.isCombatSession()
    return game.PlaceId ~= 14916516914 and workspace:FindFirstChild("Titans") ~= nil
end

function VisualFeatures.attachAtmosphere(atmosphere)
    if VisualFeatures.atmosphere == atmosphere then
        return
    end

    local previousAtmosphere = VisualFeatures.atmosphere
    if previousAtmosphere and previousAtmosphere.Parent then
        local previousDensity = VisualFeatures.originalDensities[previousAtmosphere]
        if previousDensity ~= nil then
            pcall(function()
                previousAtmosphere.Density = previousDensity
            end)
        end
    end

    if VisualFeatures.densityConnection then
        VisualFeatures.densityConnection:Disconnect()
        VisualFeatures.densityConnection = nil
    end

    VisualFeatures.atmosphere = atmosphere
    if VisualFeatures.originalDensities[atmosphere] == nil then
        VisualFeatures.originalDensities[atmosphere] = atmosphere.Density
    end
    VisualFeatures.originalDensity = VisualFeatures.originalDensities[atmosphere]

    local function applyFogReduction()
        if VisualFeatures.removeFogEnabled and atmosphere.Parent and atmosphere.Density > VisualFeatures.fogDensity then
            atmosphere.Density = VisualFeatures.fogDensity
        end
    end

    applyFogReduction()
    VisualFeatures.densityConnection = atmosphere:GetPropertyChangedSignal("Density"):Connect(function()
        if not VisualFeatures.removeFogEnabled or VisualFeatures.reapplyingFog then
            return
        end

        VisualFeatures.reapplyingFog = true
        task.delay(0.5, function()
            VisualFeatures.reapplyingFog = false
            pcall(applyFogReduction)
        end)
    end)
end

function VisualFeatures.setFog(enabled)
    VisualFeatures.removeFogEnabled = enabled
    if enabled then
        local atmosphere = Services.Lighting:FindFirstChildOfClass("Atmosphere")
        if atmosphere then
            VisualFeatures.attachAtmosphere(atmosphere)
        end

        if not VisualFeatures.lightingConnection then
            VisualFeatures.lightingConnection = Services.Lighting.ChildAdded:Connect(function(child)
                if VisualFeatures.removeFogEnabled and child:IsA("Atmosphere") then
                    VisualFeatures.attachAtmosphere(child)
                end
            end)
        end
        return
    end

    if VisualFeatures.lightingConnection then
        VisualFeatures.lightingConnection:Disconnect()
        VisualFeatures.lightingConnection = nil
    end
    if VisualFeatures.densityConnection then
        VisualFeatures.densityConnection:Disconnect()
        VisualFeatures.densityConnection = nil
    end

    for atmosphere, originalDensity in pairs(VisualFeatures.originalDensities) do
        if atmosphere.Parent then
            pcall(function()
                atmosphere.Density = originalDensity
            end)
        end
        VisualFeatures.originalDensities[atmosphere] = nil
    end
    VisualFeatures.atmosphere = nil
    VisualFeatures.originalDensity = nil
end

function VisualFeatures.getNapeHitbox(titan)
    local hitboxes = titan and titan:FindFirstChild("Hitboxes")
    local hit = hitboxes and hitboxes:FindFirstChild("Hit")
    local nape = hit and hit:FindFirstChild("Nape")
    return nape and nape:IsA("BasePart") and nape or nil
end

function VisualFeatures.extendNape(titan)
    local nape = VisualFeatures.getNapeHitbox(titan)
    if not nape then
        return
    end

    if not VisualFeatures.napeOriginals[nape] then
        VisualFeatures.napeOriginals[nape] = {
            Size = nape.Size,
            Color = nape.Color,
            Material = nape.Material,
            Transparency = nape.Transparency,
        }
    end

    pcall(function()
        nape.Size = Vector3.new(60, 60, 60)
        nape.Color = Color3.new(1, 1, 1)
        nape.Material = Enum.Material.Neon
    end)
end

function VisualFeatures.restoreNapes()
    for nape, properties in pairs(VisualFeatures.napeOriginals) do
        if nape.Parent then
            pcall(function()
                nape.Size = properties.Size
                nape.Color = properties.Color
                nape.Material = properties.Material
                nape.Transparency = properties.Transparency
            end)
        end
        VisualFeatures.napeOriginals[nape] = nil
    end
end

function VisualFeatures.stopNapeMonitor()
    if VisualFeatures.napeChildAddedConnection then
        VisualFeatures.napeChildAddedConnection:Disconnect()
        VisualFeatures.napeChildAddedConnection = nil
    end
    if VisualFeatures.napeWorkspaceConnection then
        VisualFeatures.napeWorkspaceConnection:Disconnect()
        VisualFeatures.napeWorkspaceConnection = nil
    end
    VisualFeatures.napeFolder = nil
end

function VisualFeatures.attachNapeMonitor(titans)
    if not VisualFeatures.napeExtenderEnabled or VisualFeatures.napeFolder == titans then
        return
    end

    VisualFeatures.stopNapeMonitor()
    VisualFeatures.napeFolder = titans
    for _, titan in ipairs(titans:GetChildren()) do
        VisualFeatures.extendNape(titan)
    end

    VisualFeatures.napeChildAddedConnection = titans.ChildAdded:Connect(function(titan)
        task.delay(0.1, function()
            if VisualFeatures.napeExtenderEnabled and titan.Parent == titans then
                VisualFeatures.extendNape(titan)
            end
        end)
    end)
end

function VisualFeatures.setNapeExtender(enabled)
    VisualFeatures.napeExtenderEnabled = enabled
    if not enabled then
        VisualFeatures.stopNapeMonitor()
        VisualFeatures.restoreNapes()
        return
    end

    local titans = workspace:FindFirstChild("Titans")
    if titans then
        VisualFeatures.attachNapeMonitor(titans)
    elseif not VisualFeatures.napeWorkspaceConnection then
        VisualFeatures.napeWorkspaceConnection = workspace.ChildAdded:Connect(function(child)
            if child.Name == "Titans" and VisualFeatures.napeExtenderEnabled then
                if VisualFeatures.napeWorkspaceConnection then
                    VisualFeatures.napeWorkspaceConnection:Disconnect()
                    VisualFeatures.napeWorkspaceConnection = nil
                end
                VisualFeatures.attachNapeMonitor(child)
            end
        end)
    end
end

function VisualFeatures.removeTitanHighlight(titan)
    local highlight = VisualFeatures.titanHighlights[titan]
    if highlight then
        pcall(function()
            highlight:Destroy()
        end)
        VisualFeatures.titanHighlights[titan] = nil
    end
end

function VisualFeatures.addTitanHighlight(titan)
    if not VisualFeatures.titanEspEnabled or not VisualFeatures.titanEspFolder
        or VisualFeatures.titanHighlights[titan] or titan:GetAttribute("State") == "Dead" then
        return
    end

    local highlight = Instance.new("Highlight")
    highlight.FillColor = Color3.fromRGB(255, 255, 255)
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.45
    highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
    highlight.Adornee = titan
    highlight.Parent = VisualFeatures.titanEspFolder
    VisualFeatures.titanHighlights[titan] = highlight
end

function VisualFeatures.clearTitanESP()
    if VisualFeatures.titanChildAddedConnection then
        VisualFeatures.titanChildAddedConnection:Disconnect()
        VisualFeatures.titanChildAddedConnection = nil
    end
    if VisualFeatures.titanChildRemovedConnection then
        VisualFeatures.titanChildRemovedConnection:Disconnect()
        VisualFeatures.titanChildRemovedConnection = nil
    end
    if VisualFeatures.titanWorkspaceConnection then
        VisualFeatures.titanWorkspaceConnection:Disconnect()
        VisualFeatures.titanWorkspaceConnection = nil
    end
    if VisualFeatures.titanEspFolder then
        VisualFeatures.titanEspFolder:Destroy()
        VisualFeatures.titanEspFolder = nil
    end
    VisualFeatures.titanHighlights = {}
end

function VisualFeatures.attachTitanESP(titans)
    if not VisualFeatures.titanEspEnabled or VisualFeatures.titanEspFolder then
        return
    end

    local espFolder = Instance.new("Folder")
    espFolder.Name = "AOTR_TitanESP"
    espFolder.Parent = workspace
    VisualFeatures.titanEspFolder = espFolder

    for _, titan in ipairs(titans:GetChildren()) do
        VisualFeatures.addTitanHighlight(titan)
    end

    VisualFeatures.titanChildAddedConnection = titans.ChildAdded:Connect(function(titan)
        task.delay(0.1, function()
            if titan.Parent == titans then
                VisualFeatures.addTitanHighlight(titan)
            end
        end)
    end)
    VisualFeatures.titanChildRemovedConnection = titans.ChildRemoved:Connect(function(titan)
        VisualFeatures.removeTitanHighlight(titan)
    end)
end

function VisualFeatures.setTitanESP(enabled)
    VisualFeatures.titanEspEnabled = enabled
    if not enabled then
        VisualFeatures.clearTitanESP()
        return
    end

    local titans = workspace:FindFirstChild("Titans")
    if titans then
        VisualFeatures.attachTitanESP(titans)
    elseif not VisualFeatures.titanWorkspaceConnection then
        VisualFeatures.titanWorkspaceConnection = workspace.ChildAdded:Connect(function(child)
            if child.Name == "Titans" and VisualFeatures.titanEspEnabled then
                if VisualFeatures.titanWorkspaceConnection then
                    VisualFeatures.titanWorkspaceConnection:Disconnect()
                    VisualFeatures.titanWorkspaceConnection = nil
                end
                VisualFeatures.attachTitanESP(child)
            end
        end)
    end
end

function CombatFeatures.getBladeRig()
    local character = LocalPlayer.Character
    if character then
        for _, child in ipairs(character:GetChildren()) do
            if child.Name:match("^Rig_") then
                return child
            end
        end
    end

    local characters = workspace:FindFirstChild("Characters")
    local playerCharacter = characters and characters:FindFirstChild(LocalPlayer.Name)
    if not playerCharacter then
        return nil
    end
    for _, child in ipairs(playerCharacter:GetChildren()) do
        if child.Name:match("^Rig_") then
            return child
        end
    end
    return nil
end

function CombatFeatures.getBladeOne()
    local rig = CombatFeatures.getBladeRig()
    local leftHand = rig and rig:FindFirstChild("LeftHand")
    return leftHand and leftHand:FindFirstChild("Blade_1")
end

function CombatFeatures.getBladeSetsLabel()
    local interface = PlayerGui:FindFirstChild("Interface")
    local hud = interface and interface:FindFirstChild("HUD")
    local main = hud and hud:FindFirstChild("Main")
    local top = main and main:FindFirstChild("Top")
    local blade = top and top:FindFirstChild("Blade")
    local setsLabel = blade and blade:FindFirstChild("Sets")
    if setsLabel then
        return setsLabel
    end
    if hud then
        for _, descendant in ipairs(hud:GetDescendants()) do
            if descendant.Name == "Sets"
                and (descendant:IsA("TextLabel") or descendant:IsA("TextButton")) then
                return descendant
            end
        end
    end
    return nil
end

function CombatFeatures.getBladeSetsRemaining(setsLabel)
    if not setsLabel then
        return nil
    end
    local text = tostring(setsLabel.Text or "")
    local remaining = tonumber(text:match("^%s*(%d+)%s*/"))
    if remaining then
        return remaining
    end
    return tonumber(text:match("^%s*(%d+)"))
end

function CombatFeatures.areAllBladeSetsUsed()
    local rig = CombatFeatures.getBladeRig()
    local lowerTorso = rig and rig:FindFirstChild("LowerTorso")
    if not lowerTorso then
        return false
    end
    for index = 1, 3 do
        local bladeSet = lowerTorso:FindFirstChild("Left_" .. index, true)
        if bladeSet and bladeSet:GetAttribute("Used") == nil then
            return false
        end
    end
    return true
end

function CombatFeatures.findRefillPart()
    for _, descendant in ipairs(workspace:GetDescendants()) do
        if descendant.Name == "Refill" and descendant:IsA("BasePart") then
            return descendant
        end
    end
    return nil
end

function CombatFeatures.getCachedRefillPart()
    if not CombatFeatures.cachedRefillPart or not CombatFeatures.cachedRefillPart.Parent or tick() - CombatFeatures.lastRefillSearchTime > 10 then
        CombatFeatures.cachedRefillPart = CombatFeatures.findRefillPart()
        CombatFeatures.lastRefillSearchTime = tick()
    end
    return CombatFeatures.cachedRefillPart
end

function CombatFeatures.reloadBlades(runId)
    if not CombatFeatures.autoReloadBladesEnabled or CombatFeatures.combatReloading
        or tick() - CombatFeatures.lastFullReloadTime < 4 or tick() - CombatFeatures.lastBladeReloadTime < 5 then
        return
    end
    local blade = CombatFeatures.getBladeOne()
    if not blade or blade.Transparency ~= 1 then
        return
    end
    local character = LocalPlayer.Character
    if character and character:GetAttribute("IFrames") ~= nil then
        return
    end
    local setsLabel = CombatFeatures.getBladeSetsLabel()
    local setsRemaining = setsLabel and tonumber((setsLabel.Text or ""):match("^(%d+)"))
    if not setsRemaining or setsRemaining <= 0 then
        return
    end

    CombatFeatures.combatReloading = true
    CombatFeatures.lastBladeReloadTime = tick()
    local reloadSucceeded = pcall(function()
        invokeActorFunction("Blades", "Reload")
    end)
    if reloadSucceeded then
        local timeout = tick() + 4
        repeat
            task.wait(0.1)
            blade = CombatFeatures.getBladeOne()
        until (blade and blade.Transparency ~= 1) or tick() >= timeout
            or CombatFeatures.combatReloadRunId ~= runId or not CombatFeatures.autoReloadBladesEnabled
    end
    CombatFeatures.combatReloading = false
end

function CombatFeatures.tryFullReload(runId, weapon, setsLabel)
    if not CombatFeatures.autoFullReloadEnabled or tick() - CombatFeatures.lastFullReloadTime < 4 then
        return
    end
    if weapon == "Spears" then
        local interface = PlayerGui:FindFirstChild("Interface")
        local hud = interface and interface:FindFirstChild("HUD")
        local main = hud and hud:FindFirstChild("Main")
        local top = main and main:FindFirstChild("Top")
        local spearRow = top and top:FindFirstChild("7")
        local spearCount = spearRow and spearRow:FindFirstChild("Spears")
        spearCount = spearCount and spearCount:FindFirstChild("Spears")
        local count = spearCount and tonumber((spearCount.Text or ""):match("^%s*(%d+)")) or 0
        if count > 0 then
            return
        end
    elseif weapon ~= "Blades" then
        return
    elseif not setsLabel or (setsLabel.Text or "") ~= "0 / 3"
        or not CombatFeatures.areAllBladeSetsUsed() then
        return
    end

    local refill = CombatFeatures.getCachedRefillPart()
    if not refill then
        return
    end
    local reloadSent = CombatFeatures.sendPost("Attacks", "Reload", refill)
    if reloadSent then
        CombatFeatures.lastFullReloadTime = tick()
        CombatFeatures.fullReloadPending = true
        CombatFeatures.fullReloadPendingSince = tick()
    end
end

function CombatFeatures.updateCombatReloadLoop()
    CombatFeatures.combatReloadRunId += 1
    local runId = CombatFeatures.combatReloadRunId
    if not CombatFeatures.autoReloadBladesEnabled and not CombatFeatures.autoFullReloadEnabled then
        return
    end

    task.spawn(function()
        while CombatFeatures.combatReloadRunId == runId
            and (CombatFeatures.autoReloadBladesEnabled or CombatFeatures.autoFullReloadEnabled) do
            task.wait(0.2)
            if CombatFeatures.combatReloadRunId ~= runId then
                break
            end
            if not CombatFeatures.isCombatSession() then
                continue
            end

            local weapon = LocalPlayer:GetAttribute("Weapon") or "Blades"
            local setsLabel = CombatFeatures.getBladeSetsLabel()
            if CombatFeatures.fullReloadPending then
                if tick() - CombatFeatures.fullReloadPendingSince > 10 then
                    CombatFeatures.fullReloadPending = false
                elseif weapon == "Spears" then
                    local interface = PlayerGui:FindFirstChild("Interface")
                    local hud = interface and interface:FindFirstChild("HUD")
                    local main = hud and hud:FindFirstChild("Main")
                    local top = main and main:FindFirstChild("Top")
                    local spearRow = top and top:FindFirstChild("7")
                    local spearCount = spearRow and spearRow:FindFirstChild("Spears")
                    spearCount = spearCount and spearCount:FindFirstChild("Spears")
                    local count = spearCount and tonumber((spearCount.Text or ""):match("^%s*(%d+)"))
                    if count and count > 0 then
                        CombatFeatures.fullReloadPending = false
                    else
                        continue
                    end
                else
                    local setsRemaining = CombatFeatures.getBladeSetsRemaining(setsLabel)
                    local blade = CombatFeatures.getBladeOne()
                    if setsRemaining and setsRemaining > 0 and blade and blade.Transparency ~= 1 then
                        CombatFeatures.fullReloadPending = false
                    else
                        continue
                    end
                end
            end

            if weapon == "Spears" then
                if CombatFeatures.autoFullReloadEnabled then
                    CombatFeatures.tryFullReload(runId, weapon, setsLabel)
                end
                continue
            end

            local blade = CombatFeatures.getBladeOne()
            if not blade or blade.Transparency ~= 1 then
                continue
            end

            local setsRemaining = CombatFeatures.getBladeSetsRemaining(setsLabel)
            if setsRemaining == 0 then
                if CombatFeatures.autoFullReloadEnabled then
                    CombatFeatures.tryFullReload(runId, weapon, setsLabel)
                end
            elseif setsRemaining and setsRemaining > 0 and CombatFeatures.autoReloadBladesEnabled then
                CombatFeatures.reloadBlades(runId)
            end
        end
    end)
end

function FarmFeatures.setStatus(message)
    if FarmFeatures.currentStatus == message then
        return
    end
    FarmFeatures.currentStatus = message
    if FarmFeatures.statusLabel then
        FarmFeatures.statusLabel.Text = message
    end
end

function FarmFeatures.isActive(runId)
    return FarmFeatures.enabled and FarmFeatures.runId == runId
end

function FarmFeatures.clearMovement()
    if FarmFeatures.movementBodyPosition then
        pcall(function()
            FarmFeatures.movementBodyPosition:Destroy()
        end)
        FarmFeatures.movementBodyPosition = nil
    end
    if FarmFeatures.movementHumanoid then
        pcall(function()
            FarmFeatures.movementHumanoid.AutoRotate = true
        end)
        FarmFeatures.movementHumanoid = nil
    end
end

function FarmFeatures.disablePartCollision(part)
    if not part or not part:IsA("BasePart") then
        return
    end
    if FarmFeatures.noclipParts[part] == nil then
        FarmFeatures.noclipParts[part] = part.CanCollide
    end
    if part.CanCollide then
        part.CanCollide = false
    end
end

function FarmFeatures.startNoclip(runId)
    FarmFeatures.noclipRunId += 1
    local noclipRunId = FarmFeatures.noclipRunId
    if FarmFeatures.noclipDescendantConnection then
        FarmFeatures.noclipDescendantConnection:Disconnect()
        FarmFeatures.noclipDescendantConnection = nil
    end
    if FarmFeatures.noclipCharacterConnection then
        FarmFeatures.noclipCharacterConnection:Disconnect()
    end

    local function applyToCharacter(character)
        if not character or not FarmFeatures.isActive(runId) then
            return
        end
        if FarmFeatures.noclipDescendantConnection then
            FarmFeatures.noclipDescendantConnection:Disconnect()
        end
        for _, descendant in ipairs(character:GetDescendants()) do
            FarmFeatures.disablePartCollision(descendant)
        end
        FarmFeatures.noclipDescendantConnection = character.DescendantAdded:Connect(function(descendant)
            if FarmFeatures.isActive(runId) and descendant:IsA("BasePart") then
                task.defer(function()
                    if descendant.Parent and FarmFeatures.isActive(runId) then
                        FarmFeatures.disablePartCollision(descendant)
                    end
                end)
            end
        end)
    end

    applyToCharacter(LocalPlayer.Character)
    FarmFeatures.noclipCharacterConnection = LocalPlayer.CharacterAdded:Connect(applyToCharacter)
    task.spawn(function()
        while FarmFeatures.isActive(runId) and FarmFeatures.noclipRunId == noclipRunId do
            task.wait(0.5)
            for part in pairs(FarmFeatures.noclipParts) do
                if part and part.Parent then
                    pcall(function()
                        part.CanCollide = false
                    end)
                else
                    FarmFeatures.noclipParts[part] = nil
                end
            end
        end
    end)
end

function FarmFeatures.stopNoclip()
    FarmFeatures.noclipRunId += 1
    if FarmFeatures.noclipCharacterConnection then
        FarmFeatures.noclipCharacterConnection:Disconnect()
        FarmFeatures.noclipCharacterConnection = nil
    end
    if FarmFeatures.noclipDescendantConnection then
        FarmFeatures.noclipDescendantConnection:Disconnect()
        FarmFeatures.noclipDescendantConnection = nil
    end
    for part, originalCanCollide in pairs(FarmFeatures.noclipParts) do
        if part and part.Parent then
            pcall(function()
                part.CanCollide = originalCanCollide
            end)
        end
        FarmFeatures.noclipParts[part] = nil
    end
end

function FarmFeatures.shouldHoldForSafetyTimer()
    local mode = workspace:GetAttribute("Type")
    local minimumTime = mode == "Missions" and FarmFeatures.missionSafetyTimer
        or mode == "Raids" and FarmFeatures.raidSafetyTimer
    if not minimumTime then
        return false, 0
    end

    local gameSeconds = tonumber(workspace:GetAttribute("Seconds"))
    if not gameSeconds then
        return false, 0
    end
    local now = tick()
    if FarmFeatures.lastSessionSeconds == nil or gameSeconds < FarmFeatures.lastSessionSeconds then
        FarmFeatures.lastSessionSecondsChangedAt = now
    elseif gameSeconds ~= FarmFeatures.lastSessionSeconds then
        FarmFeatures.lastSessionSecondsChangedAt = now
    end
    FarmFeatures.lastSessionSeconds = gameSeconds

    -- Track the in-game Seconds attribute, and advance elapsed time locally while
    -- the game pauses it. Do not use Mahmut's six-second escape here: it permits
    -- the final hit before the configured mission timer has elapsed.
    local elapsedSeconds = gameSeconds
        + math.max(0, now - FarmFeatures.lastSessionSecondsChangedAt)
    local remainingTime = minimumTime - elapsedSeconds
    if remainingTime <= 0 then
        return false, 0
    end

    if mode == "Missions" then
        local finalObjectiveTarget = false
        local hasObjectiveProgress = false
        local objectives = Services.ReplicatedStorage:FindFirstChild("Objectives")
        if objectives then
            local objectiveNames = {
                Slay = true,
                Kill = true,
                Defend = true,
                Protect = true,
                Guard = true,
                Protect_HQ = true,
            }
            local objectiveName = workspace:GetAttribute("Objective")
            local objective = objectiveNames[objectiveName]
                and objectives:FindFirstChild(objectiveName)
                or nil
            if not objective then
                for _, candidate in ipairs(objectives:GetChildren()) do
                    if objectiveNames[candidate.Name] then
                        objective = candidate
                        break
                    end
                end
            end
            if objective then
                local progress = tonumber(objective.Value) or 0
                local requirement = tonumber(objective:GetAttribute("Requirement")) or 0
                hasObjectiveProgress = requirement > 1
                local objectiveRequiresKills = objective.Name == "Slay" or objective.Name == "Kill"
                finalObjectiveTarget = objectiveRequiresKills
                    and requirement > 1
                    and progress >= requirement - 1
            end
        end

        -- Match Mahmut's objective gate: hold attacks when only one kill remains.
        -- Use Astra's one-Nape check only when objective progress is unavailable.
        local isFinalTarget = hasObjectiveProgress
            and finalObjectiveTarget
            or not hasObjectiveProgress and #CombatFeatures.getAstraFarmTargets() == 1
        return isFinalTarget, math.max(0, remainingTime)
    end

    local objectives = Services.ReplicatedStorage:FindFirstChild("Objectives")
    if not objectives then
        return false, remainingTime
    end

    local objectiveName = workspace:GetAttribute("Objective")
    local holdableObjectives = { Slay = true, Kill = true, Defend = true, Protect = true, Guard = true, Protect_HQ = true }
    local selectedObjective
    if objectiveName == "Breach" then
        selectedObjective = objectives:FindFirstChild("Protect_HQ")
    elseif holdableObjectives[objectiveName] then
        selectedObjective = objectives:FindFirstChild(objectiveName)
    end
    if not selectedObjective then
        for _, objective in ipairs(objectives:GetChildren()) do
            if holdableObjectives[objective.Name] then
                selectedObjective = objective
                break
            end
        end
    end
    if not selectedObjective then
        return false, remainingTime
    end

    if not selectedObjective:IsA("ValueBase") then
        return false, remainingTime
    end

    local value = tonumber(selectedObjective.Value)
    local requirement = tonumber(selectedObjective:GetAttribute("Requirement"))
    if not value or not requirement or requirement <= 1 then
        return false, remainingTime
    end

    local holdMargin = (selectedObjective.Name == "Protect_HQ" or selectedObjective.Name == "Guard"
        or selectedObjective.Name == "Defend") and 2 or 1
    return value >= requirement - holdMargin, remainingTime
end

function FarmFeatures.stop()
    FarmFeatures.enabled = false
    FarmFeatures.runId += 1
    if FarmFeatures.movementConnection then
        FarmFeatures.movementConnection:Disconnect()
        FarmFeatures.movementConnection = nil
    end
    FarmFeatures.movementTarget = nil
    FarmFeatures.movementNape = nil
    FarmFeatures.clearMovement()
    FarmFeatures.stopNoclip()
    SoloOnly.stop()
    FarmFeatures.setStatus("Idle")
end

function FarmFeatures.start()
    FarmFeatures.enabled = true
    FarmFeatures.runId += 1
    local runId = FarmFeatures.runId
    FarmFeatures.lastSessionSeconds = nil
    FarmFeatures.lastSessionSecondsChangedAt = tick()
    FarmFeatures.soloOnlyCheckedForSession = false
    FarmFeatures.setStatus("Waiting before farming...")
    SoloOnly.start()

    if FarmFeatures.movementConnection then
        FarmFeatures.movementConnection:Disconnect()
    end
    FarmFeatures.movementTarget = nil
    FarmFeatures.movementNape = nil
    FarmFeatures.movementConnection = Services.RunService.Heartbeat:Connect(function(deltaTime)
        local nape = FarmFeatures.movementNape
        local target = FarmFeatures.movementTarget
        local character = LocalPlayer.Character
        local rootPart = character and character:FindFirstChild("HumanoidRootPart")
        local humanoid = character and character:FindFirstChildOfClass("Humanoid")
        if not FarmFeatures.isActive(runId) or not CombatFeatures.isCombatSession()
            or not nape or not nape.Parent or not target or not rootPart or not humanoid then
            FarmFeatures.clearMovement()
            return
        end

        if FarmFeatures.movementHumanoid ~= humanoid then
            if FarmFeatures.movementHumanoid then
                pcall(function()
                    FarmFeatures.movementHumanoid.AutoRotate = true
                end)
            end
            pcall(function()
                humanoid.AutoRotate = false
            end)
            FarmFeatures.movementHumanoid = humanoid
        end

        if rootPart.Anchored then
            rootPart.Anchored = false
        end

        local mover = FarmFeatures.movementBodyPosition
        if not mover or mover.Parent ~= rootPart then
            FarmFeatures.clearMovement()
            pcall(function()
                humanoid.AutoRotate = false
            end)
            FarmFeatures.movementHumanoid = humanoid
            mover = Instance.new("BodyPosition")
            mover.Name = "AOTR_Farm_Hover"
            mover.MaxForce = Vector3.new(100000000, 100000000, 100000000)
            mover.Position = rootPart.Position
            mover.Parent = rootPart
            FarmFeatures.movementBodyPosition = mover
        end

        local speed = math.clamp((tonumber(FarmFeatures.hoverSpeed) or 500) / 130, 4, 16)
        mover.P = 5000 + speed * 500
        mover.D = 1000 + speed * 100
        mover.Position = nape.Position + Vector3.new(0, FarmFeatures.hoverHeight, 0)
        if (mover.Position - rootPart.Position).Magnitude <= 3 then
            pcall(function()
                rootPart.AssemblyLinearVelocity = Vector3.zero
                rootPart.AssemblyAngularVelocity = Vector3.zero
            end)
        end
    end)

    task.spawn(function()
        local waitUntil = os.clock() + math.max(0, FarmFeatures.waitBeforeFarming)
        while FarmFeatures.isActive(runId) and os.clock() < waitUntil do
            task.wait(0.1)
        end
        if not FarmFeatures.isActive(runId) then
            return
        end
        FarmFeatures.startNoclip(runId)

        while FarmFeatures.isActive(runId) do
            task.wait(0.1)
            if not FarmFeatures.isActive(runId) then
                break
            end

            if not CombatFeatures.isCombatSession() then
                FarmFeatures.movementTarget = nil
                FarmFeatures.movementNape = nil
                FarmFeatures.lastSessionSeconds = nil
                FarmFeatures.lastSessionSecondsChangedAt = tick()
                FarmFeatures.soloOnlyCheckedForSession = false
                FarmFeatures.setStatus("Waiting for a combat session")
                continue
            end

            if SoloOnly.enabled and not FarmFeatures.soloOnlyCheckedForSession then
                FarmFeatures.soloOnlyCheckedForSession = true
                if SoloOnly.checkExistingPlayers() then
                    break
                end
            end

            if workspace:GetAttribute("Rewarded") or workspace:GetAttribute("Force_End") then
                FarmFeatures.movementTarget = nil
                FarmFeatures.movementNape = nil
                FarmFeatures.lastSessionSeconds = nil
                FarmFeatures.lastSessionSecondsChangedAt = tick()
                FarmFeatures.setStatus("Session complete; waiting for the next round")
                continue
            end

            local character = LocalPlayer.Character
            local rootPart = character and character:FindFirstChild("HumanoidRootPart")
            local nape = CombatFeatures.getNearestEscapeNape()
            if not rootPart or not nape or not nape.Parent then
                FarmFeatures.movementTarget = nil
                FarmFeatures.movementNape = nil
                FarmFeatures.setStatus("Searching for a target")
                continue
            end

            FarmFeatures.movementNape = nape
            FarmFeatures.movementTarget = nape.Position + Vector3.new(0, FarmFeatures.hoverHeight, 0)

            local safetyHold, safetyRemaining = FarmFeatures.shouldHoldForSafetyTimer()
            if safetyHold then
                FarmFeatures.setStatus(string.format(
                    "Safety hold: %ds remaining",
                    math.ceil(safetyRemaining)
                ))
                continue
            end

            local titan = nape.Parent and nape.Parent.Parent and nape.Parent.Parent.Parent
            local titanState = titan and titan:GetAttribute("State")
            local attackable = titan
                and not titan:GetAttribute("Killed")
                and titan:GetAttribute("Dead") ~= true
                and titanState ~= nil
                and titanState ~= "Roar"
                and titanState ~= "HeatWave"
            local attackRange = (tonumber(FarmFeatures.hoverHeight) or 200) + 50
            if attackable
                and (rootPart.Position - nape.Position).Magnitude <= attackRange
                and tick() - FarmFeatures.lastAttackTime >= 0.5 then
                FarmFeatures.lastAttackTime = tick()
                CombatFeatures.sendPost("Attacks", "Slash", true)
                CombatFeatures.sendPost(
                    "Hitboxes",
                    "Register",
                    nape,
                    math.random(200, 400),
                    math.random(100, 800) / 1000
                )
                CombatFeatures.sendPost("Attacks", "Slash", false)
            end

            local mode = workspace:GetAttribute("Type") or "Combat"
            local seconds = workspace:GetAttribute("Seconds")
            if seconds then
                FarmFeatures.setStatus(string.format("Farming %s | %ds", tostring(mode), seconds))
            else
                FarmFeatures.setStatus("Farming " .. tostring(mode))
            end
        end
    end)
end

function FarmFeatures.setAutoExecute(value)
    FarmFeatures.executeEnabled = value
    if not value then
        return
    end

    local queueTeleport = type(queue_on_teleport) == "function" and queue_on_teleport
        or type(queueonteleport) == "function" and queueonteleport
        or type(queue_on_tp) == "function" and queue_on_tp
        or type(queueontp) == "function" and queueontp
    if not queueTeleport then
        FarmFeatures.executeEnabled = false
        warn("[AOTR] Auto Execute is unavailable: executor has no teleport queue API.")
        return
    end

    local scriptUrl = "https://raw.githubusercontent.com/Valox321/Custom-UI/refs/heads/main/AOTR.lua"
    local queuedSource = string.format(
        'local source = game:HttpGet(%q); local chunk, err = loadstring(source); assert(chunk, err); chunk()',
        scriptUrl
    )
    local queued, queueError = pcall(queueTeleport, queuedSource)
    if not queued then
        FarmFeatures.executeEnabled = false
        warn("[AOTR] Auto Execute could not queue the script: " .. tostring(queueError))
        return
    end

    warn("[AOTR] Auto Execute queued; AOTR.lua will reload after the next teleport.")
end

local function getAutoRetryRewardScreen()
    local interface = PlayerGui:FindFirstChild("Interface")
    local rewards = interface and interface:FindFirstChild("Rewards")
    return rewards and rewards.Visible and rewards or nil
end

local function clickAutoRetryButton(runId)
    local rewards = PlayerGui:FindFirstChild("Interface")
        and PlayerGui.Interface:FindFirstChild("Rewards")
    local current = rewards
    for _, childName in ipairs({ "Main", "Info", "Main", "Buttons", "Retry" }) do
        current = current and current:FindFirstChild(childName)
    end
    local retryButton = current
    if not retryButton or not retryButton:IsA("GuiButton") then
        return false
    end
    if not AutoRetry.enabled or AutoRetry.runId ~= runId or not FarmFeatures.enabled then
        return false
    end

    Services.GuiService.SelectedObject = retryButton
    task.wait(0.1)
    if not AutoRetry.enabled or AutoRetry.runId ~= runId or not retryButton.Parent then
        Services.GuiService.SelectedObject = nil
        return false
    end
    Services.VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
    task.wait(0.1)
    Services.VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
    Services.GuiService.SelectedObject = nil
    return true
end

local function clickRetrySure(runId)
    for _ = 1, 3 do
        if not AutoRetry.enabled or AutoRetry.runId ~= runId or not FarmFeatures.enabled then
            return false
        end
        task.wait(1)
        clickAutoRetryButton(runId)
        local deadline = tick() + 8
        while tick() < deadline do
            if not AutoRetry.enabled or AutoRetry.runId ~= runId or not FarmFeatures.enabled then
                return false
            end
            if not getAutoRetryRewardScreen() then
                return true
            end
            task.wait(0.25)
        end
    end
    warn("[AOTR] Auto Retry could not close the rewards screen after 3 attempts.")
    return false
end

local function requestAutoRetry()
    if not AutoRetry.enabled or not FarmFeatures.enabled or AutoRetry.busy
        or not CombatFeatures.isCombatSession() or not getAutoRetryRewardScreen() then
        return
    end
    local now = tick()
    if now - AutoRetry.lastHandledAt < 3 then
        return
    end
    AutoRetry.lastHandledAt = now
    AutoRetry.busy = true
    local runId = AutoRetry.runId
    task.spawn(function()
        clickRetrySure(runId)
        if AutoRetry.runId == runId then
            AutoRetry.busy = false
        end
    end)
end

AutoRetry.rewardChangedConnection = workspace:GetAttributeChangedSignal("Rewarded"):Connect(function()
    if workspace:GetAttribute("Rewarded") == true then
        task.delay(0.5, requestAutoRetry)
    end
end)
AutoRetry.forceEndChangedConnection = workspace:GetAttributeChangedSignal("Force_End"):Connect(function()
    if workspace:GetAttribute("Force_End") == true then
        task.delay(0.5, requestAutoRetry)
    end
end)

local function startAutoRetryUiWatch()
    task.spawn(function()
    local previousVisible = false
    while windowBodyInstance and windowBodyInstance.Parent do
        task.wait(0.5)
        local visible = getAutoRetryRewardScreen() ~= nil
        if visible and not previousVisible then
            task.delay(0.6, requestAutoRetry)
        end
        previousVisible = visible
        end
    end)
end

local function setAutoRetryEnabled(value)
    AutoRetry.enabled = value
    AutoRetry.runId += 1
    AutoRetry.busy = false
end

local function updateAutoLobbySubtitle()
    if AutoLobby.titleStack then
        AutoLobby.titleStack.Subtitle = string.format(
            "Missions/raids before returning. Completed: %d/%d.",
            AutoLobby.completedSessions,
            AutoLobby.after
        )
    end
end

local function returnFarmToLobby(statusMessage)
    if AutoLobby.returning then
        return
    end

    AutoLobby.returning = true
    AutoLobby.completedSessions = 0
    updateAutoLobbySubtitle()
    FarmFeatures.stop()
    if autoFarmToggle then
        autoFarmToggle.Value = false
    end
    FarmFeatures.setStatus(statusMessage or "Returning to Lobby...")

    task.spawn(function()
        local deadline = os.clock() + 30
        while CombatFeatures.isCombatSession() and os.clock() < deadline do
            CombatFeatures.sendPost("Functions", "Teleport")
            task.wait(2)
        end

        if CombatFeatures.isCombatSession() then
            AutoLobby.returning = false
            FarmFeatures.setStatus("Lobby return failed; try manually.")
            warn("[AOTR] Could not leave the combat session for the Lobby.")
            return
        end

        AutoLobby.returning = false
        FarmFeatures.setStatus("Returned to Lobby.")
    end)
end

function SoloOnly.stop()
    if SoloOnly.playerAddedConnection then
        SoloOnly.playerAddedConnection:Disconnect()
        SoloOnly.playerAddedConnection = nil
    end
end

function SoloOnly.checkExistingPlayers()
    if not SoloOnly.enabled or not FarmFeatures.enabled or not CombatFeatures.isCombatSession() then
        return false
    end

    for _, player in ipairs(Services.Players:GetPlayers()) do
        if player ~= LocalPlayer then
            returnFarmToLobby(player.Name .. " joined; returning to Lobby...")
            return true
        end
    end
    return false
end

function SoloOnly.start()
    SoloOnly.stop()
    SoloOnly.checkedForSession = false
    if not SoloOnly.enabled or not FarmFeatures.enabled then
        return
    end

    SoloOnly.playerAddedConnection = Services.Players.PlayerAdded:Connect(function(player)
        if player ~= LocalPlayer
            and SoloOnly.enabled
            and FarmFeatures.enabled
            and CombatFeatures.isCombatSession() then
            returnFarmToLobby(player.Name .. " joined; returning to Lobby...")
        end
    end)

    if CombatFeatures.isCombatSession() then
        SoloOnly.checkedForSession = true
        SoloOnly.checkExistingPlayers()
    end
end

local function onAutoLobbyRewardedChanged()
    if not AutoLobby.enabled or not FarmFeatures.enabled or AutoLobby.returning then
        return
    end
    if workspace:GetAttribute("Rewarded") ~= true then
        return
    end

    local mode = workspace:GetAttribute("Type")
    if mode ~= "Missions" and mode ~= "Raids" then
        return
    end

    AutoLobby.completedSessions += 1
    updateAutoLobbySubtitle()
    if AutoLobby.completedSessions >= AutoLobby.after then
        returnFarmToLobby()
    else
        FarmFeatures.setStatus(string.format(
            "Completed %d/%d missions or raids",
            AutoLobby.completedSessions,
            AutoLobby.after
        ))
    end
end

autoLobbyRewardConnection = workspace:GetAttributeChangedSignal("Rewarded"):Connect(onAutoLobbyRewardedChanged)

local function missionObjectivesFor(mapName)
    for _, mapInfo in ipairs(missionMaps) do
        if mapInfo.Name == mapName then
            return mapInfo.Objectives
        end
    end
    return { "Skirmish" }
end

local function isAutoCreateMissionActive(runId)
    return autoCreateMissionEnabled and autoCreateMissionRunId == runId
end

local function stopAutoCreateMission()
    autoCreateMissionEnabled = false
    autoCreateMissionRunId += 1
    if autoCreateMissionToggle then
        autoCreateMissionToggle.Value = false
    end
end

local function createAndStartMission(runId)
    if game.PlaceId ~= 14916516914 then
        return false, "Only available in the Lobby."
    end
    if runId and not isAutoCreateMissionActive(runId) then
        return false, "Stopped."
    end

    local createArgs = {
        Name = selectedMissionMap,
        Difficulty = selectedMissionDifficulty,
        Type = "Missions",
        Objective = selectedMissionObjective,
        Minimum = nil,
    }
    local created = invokeActorFunction("S_Missions", "Create", createArgs)
    if not created.ok or typeof(created.result) ~= "Instance" then
        return false, "Mission creation failed."
    end

    for _, modifier in ipairs(selectedMissionModifiers) do
        if runId and not isAutoCreateMissionActive(runId) then
            return false, "Stopped."
        end
        invokeActorFunction("S_Missions", "Modify", modifier)
        task.wait(0.3)
    end

    if runId and not isAutoCreateMissionActive(runId) then
        return false, "Stopped."
    end
    task.wait(0.5)

    local started = invokeActorFunction("S_Missions", "Start")
    if not started.ok then
        invokeActorFunction("S_Missions", "Leave")
        return false, "Mission start failed."
    end
    return true, "Started " .. selectedMissionMap .. " (" .. selectedMissionObjective .. ", "
        .. selectedMissionDifficulty .. ")."
end

local function runAutoCreateMission(runId)
    if game.PlaceId ~= 14916516914 then
        stopAutoCreateMission()
        return
    end

    local attempt = 0
    while isAutoCreateMissionActive(runId) and game.PlaceId == 14916516914 do
        if workspace:FindFirstChild("Titans") then
            task.wait(1)
        else
            local succeeded, message = createAndStartMission(runId)
            if succeeded then
                stopAutoCreateMission()
                return
            end
            if not isAutoCreateMissionActive(runId) then
                return
            end
            attempt += 1
            if attempt >= 2 and selectedMissionDifficulty ~= "Easy" then
                local difficultyIndex = table.find(missionDifficulties, selectedMissionDifficulty)
                if difficultyIndex and difficultyIndex > 1 then
                    selectedMissionDifficulty = missionDifficulties[difficultyIndex - 1]
                    if missionDifficultyDropdown then
                        missionDifficultyDropdown.Value = difficultyIndex - 1
                    end
                    attempt = 0
                end
            end
            warn("[AOTR] Auto Create Session: " .. message .. " Retrying...")
            task.wait(math.clamp(2 * attempt - 1, 1, 6))
        end
    end
end

local function isAutoCreateRaidActive(runId)
    return autoCreateRaidEnabled and autoCreateRaidRunId == runId
end

local function stopAutoCreateRaid()
    autoCreateRaidEnabled = false
    autoCreateRaidRunId += 1
    if autoCreateRaidToggle then
        autoCreateRaidToggle.Value = false
    end
end

local function isAutoCreateWaveActive(runId)
    return autoCreateWaveEnabled and autoCreateWaveRunId == runId
end

local function stopAutoCreateWave()
    autoCreateWaveEnabled = false
    autoCreateWaveRunId += 1
    if autoCreateWaveToggle then
        autoCreateWaveToggle.Value = false
    end
end

local function createAndStartSession(mode, objective, difficulty, modifiers, runId, isActive)
    if game.PlaceId ~= 14916516914 then
        return false, "Only available in the Lobby."
    end
    if runId and not isActive(runId) then
        return false, "Stopped."
    end

    local sessionMap = mode == "Waves" and "Trost" or (raidObjectiveMaps[objective] or "Trost")
    local createArgs = {
        Name = sessionMap,
        Difficulty = difficulty,
        Type = mode,
        Objective = objective,
    }
    local created = invokeActorFunction("S_Missions", "Create", createArgs)
    if not created.ok or typeof(created.result) ~= "Instance" then
        return false, mode .. " session creation failed."
    end

    for _, modifier in ipairs(modifiers) do
        if runId and not isActive(runId) then
            return false, "Stopped."
        end
        invokeActorFunction("S_Missions", "Modify", modifier)
        task.wait(0.3)
    end

    if runId and not isActive(runId) then
        return false, "Stopped."
    end
    task.wait(0.5)

    local started = invokeActorFunction("S_Missions", "Start")
    if not started.ok then
        invokeActorFunction("S_Missions", "Leave")
        return false, mode .. " session start failed."
    end

    return true, mode .. " session started: " .. sessionMap .. " / " .. objective .. " / " .. difficulty .. "."
end

local function createAndStartRaid(runId)
    local difficulty = selectedRaidDifficulty
    if selectedRaidObjective == "Colossal Titan" then
        difficulty = "Aberrant"
    end
    return createAndStartSession("Raids", selectedRaidObjective, difficulty, selectedRaidModifiers,
        runId, isAutoCreateRaidActive)
end

local function createAndStartWave(runId)
    return createAndStartSession("Waves", "Waves", "Easy", {}, runId, isAutoCreateWaveActive)
end

local function runAutoCreateRaid(runId)
    if game.PlaceId ~= 14916516914 then
        stopAutoCreateRaid()
        return
    end

    local attempt = 0
    while isAutoCreateRaidActive(runId) and game.PlaceId == 14916516914 do
        if workspace:FindFirstChild("Titans") then
            task.wait(1)
        else
            local succeeded, message = createAndStartRaid(runId)
            if succeeded then
                stopAutoCreateRaid()
                return
            end
            if not isAutoCreateRaidActive(runId) then
                return
            end
            attempt += 1
            if attempt >= 2 and selectedRaidObjective ~= "Colossal Titan" then
                local difficultyIndex = table.find(raidDifficulties, selectedRaidDifficulty)
                if difficultyIndex and difficultyIndex > 1 then
                    selectedRaidDifficulty = raidDifficulties[difficultyIndex - 1]
                    if raidDifficultyDropdown then
                        raidDifficultyDropdown.Value = difficultyIndex - 1
                    end
                    attempt = 0
                end
            end
            warn("[AOTR] Auto Create Raid: " .. tostring(message) .. " Retrying...")
            task.wait(math.clamp(2 * attempt - 1, 1, 6))
        end
    end
end

local function runAutoCreateWave(runId)
    if game.PlaceId ~= 14916516914 then
        stopAutoCreateWave()
        return
    end

    local attempt = 0
    while isAutoCreateWaveActive(runId) and game.PlaceId == 14916516914 do
        if workspace:FindFirstChild("Titans") then
            task.wait(1)
        else
            local succeeded, message = createAndStartWave(runId)
            if succeeded then
                stopAutoCreateWave()
                return
            end
            if not isAutoCreateWaveActive(runId) then
                return
            end
            attempt += 1
            warn("[AOTR] Auto Create Wave: " .. tostring(message) .. " Retrying...")
            task.wait(math.clamp(2 * attempt - 1, 1, 6))
        end
    end
end

local function stopAutoClaimAchievements()
    autoClaimAchievementsEnabled = false
    autoClaimAchievementsRunId += 1
    if autoClaimAchievementsToggle then
        autoClaimAchievementsToggle.Value = false
    end
end

local function runAutoClaimAchievements(runId)
    if game.PlaceId ~= 14916516914 then
        warn("[AOTR] Auto Claim Achievements is only available in the Lobby.")
        stopAutoClaimAchievements()
        return
    end

    local assets = Services.ReplicatedStorage:FindFirstChild("Assets")
    local remotes = assets and assets:FindFirstChild("Remotes")
    local getRemote = remotes and remotes:FindFirstChild("GET")
    if not getRemote then
        warn("[AOTR] Auto Claim Achievements: GET remote not found.")
        stopAutoClaimAchievements()
        return
    end

    local claimedCount = 0
    for achievementId = 1, 71 do
        if not autoClaimAchievementsEnabled or autoClaimAchievementsRunId ~= runId
            or game.PlaceId ~= 14916516914 then
            break
        end

        local callSucceeded, result = pcall(function()
            return getRemote:InvokeServer("S_Achievements", "Claim", achievementId)
        end)
        if callSucceeded and result ~= nil and result ~= false then
            claimedCount += 1
            task.wait(0.35)
        else
            task.wait(0.1)
        end
    end

    warn(string.format("[AOTR] Auto Claim Achievements finished: %d claimed.", claimedCount))
    if autoClaimAchievementsRunId == runId then
        stopAutoClaimAchievements()
    end
end

local function setPrestigeStatus(message)
    if prestigeStatusLabel then
        prestigeStatusLabel.Text = message
    end
end

local function isAutoPrestigeActive(runId)
    return autoPrestigeEnabled and autoPrestigeRunId == runId
end

local function stopAutoPrestige(message)
    autoPrestigeEnabled = false
    autoPrestigeRunId += 1
    if autoPrestigeToggle then
        autoPrestigeToggle.Value = false
    end
    if message then
        setPrestigeStatus(message)
    end
end

local function fetchPrestigeSnapshot()
    local assets = Services.ReplicatedStorage:FindFirstChild("Assets")
    local remotes = assets and assets:FindFirstChild("Remotes")
    local getRemote = remotes and remotes:FindFirstChild("GET")
    if not getRemote then
        return nil, "GET remote not found"
    end

    local callSucceeded, playerData = pcall(function()
        return getRemote:InvokeServer("Functions", "Settings", "Blur", "Off")
    end)
    if not callSucceeded or type(playerData) ~= "table" then
        return nil, "Player progression data could not be read"
    end

    local slotName = playerData.Current_Slot
    local slotData = slotName and playerData.Slots and playerData.Slots[slotName]
    local progression = slotData and slotData.Progression
    if type(progression) ~= "table" then
        return nil, "Current slot progression is unavailable"
    end

    local level = tonumber(progression.Level) or 0
    local prestige = tonumber(progression.Prestige) or 0
    local requiredLevel = 100 + prestige * 25
    return {
        Slot = tostring(slotName or "?"),
        Level = level,
        Prestige = prestige,
        Ready = prestige < 5 and level >= requiredLevel,
    }
end

local function readPrestigeGold()
    local current = PlayerGui
    for _, childName in ipairs({ "Interface", "Topbar", "Main", "Currencies", "Gold", "Amount" }) do
        current = current and current:FindFirstChild(childName)
    end
    local amountText = current and current.Text
    if type(amountText) ~= "string" then
        return nil
    end
    return tonumber((amountText:gsub("[%s,]", "")))
end

local function getPrestigeTalentTag()
    local assets = Services.ReplicatedStorage:FindFirstChild("Assets")
    local remotes = assets and assets:FindFirstChild("Remotes")
    local getRemote = remotes and remotes:FindFirstChild("GET")
    if not getRemote then
        return nil, "GET remote not found"
    end

    local callSucceeded, _, talentIds = pcall(function()
        return getRemote:InvokeServer("S_Equipment", "Talents")
    end)
    if not callSucceeded or type(talentIds) ~= "table" then
        return nil, "Talent roll failed"
    end

    local requireSucceeded, memories = pcall(function()
        return require(Services.ReplicatedStorage.Modules.Storage.Memories)
    end)
    if not requireSucceeded or type(memories) ~= "table" then
        return nil, "Memories data is unavailable"
    end

    local root = memories.Talents or memories
    local ranks = { Common = 1, Uncommon = 2, Rare = 3, Epic = 4 }
    local bestTag, bestRank
    for _, talentId in ipairs(talentIds) do
        for tier, bucket in pairs(root) do
            local entry = type(bucket) == "table" and bucket[tostring(talentId)]
            local rank = ranks[tier] or 0
            if entry and entry.Tag and (not bestRank or rank > bestRank) then
                bestTag = entry.Tag
                bestRank = rank
            end
        end
    end
    if not bestTag then
        return nil, "No talent memory was returned"
    end
    return bestTag
end

local function prestigeOnce()
    if game.PlaceId ~= 14916516914 then
        return false, "Only available in the Lobby."
    end

    local snapshot, snapshotError = fetchPrestigeSnapshot()
    if not snapshot then
        return false, snapshotError
    end
    if not snapshot.Ready then
        if snapshot.Prestige >= 5 then
            return false, "Maximum prestige reached."
        end
        return false, string.format("Not eligible yet: Slot %s, Level %d, Prestige %d.",
            snapshot.Slot, snapshot.Level, snapshot.Prestige)
    end

    local nextTier = snapshot.Prestige + 1
    local requiredGold = prestigeMinGold[nextTier] or 0
    if requiredGold > 0 then
        local currentGold = readPrestigeGold()
        if not currentGold then
            return false, "Gold amount could not be read."
        end
        if currentGold < requiredGold then
            return false, string.format("Waiting for Gold: %d / %d.", currentGold, requiredGold)
        end
    end

    local talentTag, talentError = getPrestigeTalentTag()
    if not talentTag then
        return false, talentError
    end
    local boostNames = { Luck = "Luck Boost", EXP = "EXP Boost", Gold = "Gold Boost" }
    local boostName = prestigeBoosts[nextTier] or "Gold"
    local result = invokeActorFunction("S_Equipment", "Prestige", {
        Boosts = boostNames[boostName] or "Gold Boost",
        Talents = talentTag,
    })
    if not result.ok then
        return false, "Prestige request failed."
    end
    return true, string.format("P%d → P%d (%s, %s).", snapshot.Prestige, nextTier, boostName, talentTag)
end

local function runAutoPrestige(runId)
    if game.PlaceId ~= 14916516914 then
        stopAutoPrestige("Only available in the Lobby.")
        return
    end

    setPrestigeStatus("Checking prestige eligibility...")
    while isAutoPrestigeActive(runId) and game.PlaceId == 14916516914 do
        local succeeded, message = prestigeOnce()
        if not succeeded then
            if message == "Maximum prestige reached." then
                stopAutoPrestige(message)
                return
            end
            setPrestigeStatus(tostring(message) .. " Checking again shortly.")
            task.wait(10)
        else
            setPrestigeStatus("Prestiged: " .. message)
            task.wait(8)
        end
    end
    if autoPrestigeRunId == runId and game.PlaceId ~= 14916516914 then
        stopAutoPrestige("Stopped outside the Lobby.")
    end
end

local gearUpgradeCategories = {
    Blades = {
        "ODM_Damage", "Crit_Damage", "Crit_Chance", "Blade_Durability",
        "ODM_Speed", "ODM_Control", "ODM_Range", "ODM_Gas",
    },
    Spears = {
        "TS_Damage", "Crit_Damage", "Crit_Chance", "Blast_Radius",
        "TS_Speed", "TS_Control", "TS_Range", "TS_Gas",
    },
}

local function isAutoUpgradeGearActive(runId)
    return autoUpgradeGearEnabled and autoUpgradeGearRunId == runId
end

local function stopAutoUpgradeGear()
    autoUpgradeGearEnabled = false
    autoUpgradeGearRunId += 1
    if autoUpgradeGearToggle then
        autoUpgradeGearToggle.Value = false
    end
end

local function readGearUpgradeLevels(weapon)
    local assets = Services.ReplicatedStorage:FindFirstChild("Assets")
    local remotes = assets and assets:FindFirstChild("Remotes")
    local getRemote = remotes and remotes:FindFirstChild("GET")
    if not getRemote then
        return nil, "GET remote not found"
    end

    local callSucceeded, playerData = pcall(function()
        return getRemote:InvokeServer("Functions", "Settings", "Blur", "Off")
    end)
    if not callSucceeded then
        return nil, tostring(playerData)
    end
    if type(playerData) ~= "table" then
        return nil, "Player data was not returned"
    end

    local currentSlotName = playerData.Current_Slot
    local currentSlot = currentSlotName and playerData.Slots and playerData.Slots[currentSlotName]
    local upgradesByWeapon = currentSlot and currentSlot.Upgrades
    local levels = upgradesByWeapon and upgradesByWeapon[weapon]
    if type(levels) ~= "table" then
        return nil, "Upgrade levels for " .. weapon .. " were not returned"
    end
    return levels
end

local function waitForGearUpgradeConfirmation(weapon, previousLevels, requestedStats, runId)
    local deadline = os.clock() + 3
    repeat
        if not isAutoUpgradeGearActive(runId) then
            return nil, "Stopped."
        end

        task.wait(0.35)
        local currentLevels, readError = readGearUpgradeLevels(weapon)
        if currentLevels then
            local changedStats = {}
            for _, statName in ipairs(requestedStats) do
                local before = tonumber(previousLevels[statName]) or 0
                local after = tonumber(currentLevels[statName]) or 0
                if after > before then
                    changedStats[#changedStats + 1] = statName
                end
            end
            if #changedStats > 0 then
                return true, changedStats
            end
        elseif os.clock() >= deadline then
            return false, "Could not verify upgrade: " .. tostring(readError)
        end
    until os.clock() >= deadline

    return false, "No upgrade level change was confirmed."
end

local function readCurrentGold()
    local interface = PlayerGui:FindFirstChild("Interface")
    local topbar = interface and interface:FindFirstChild("Topbar")
    local main = topbar and topbar:FindFirstChild("Main")
    local currencies = main and main:FindFirstChild("Currencies")
    local gold = currencies and currencies:FindFirstChild("Gold")
    local amount = gold and gold:FindFirstChild("Amount")
    local text = amount and amount.Text
    if type(text) ~= "string" then
        return nil
    end
    return tonumber((text:gsub(",", "")))
end

local function tryUpgradeGear(weapon, runId)
    local categories = gearUpgradeCategories[weapon]
    if not categories then
        return false, "Unknown gear type: " .. tostring(weapon)
    end

    local levels, dataError = readGearUpgradeLevels(weapon)
    if not levels then
        return false, "Could not read gear data: " .. tostring(dataError)
    end
    if not isAutoUpgradeGearActive(runId) then
        return nil, "Stopped."
    end

    invokeActorFunction("S_Equipment", "Weapon", weapon)
    task.wait(0.5)
    if not isAutoUpgradeGearActive(runId) then
        return nil, "Stopped."
    end

    local orderedStats = table.clone(categories)
    table.sort(orderedStats, function(left, right)
        return (tonumber(levels[left]) or 0) < (tonumber(levels[right]) or 0)
    end)

    local gold = readCurrentGold()
    for statCount = #orderedStats, 1, -1 do
        if not isAutoUpgradeGearActive(runId) then
            return nil, "Stopped."
        end

        local statsToUpgrade = {}
        for index = 1, statCount do
            statsToUpgrade[index] = orderedStats[index]
        end

        local previousLevels = table.clone(levels)
        local result = invokeActorFunction("S_Equipment", "Upgrade", statsToUpgrade)
        if result.ok then
            return true, "Upgraded " .. weapon .. ": " .. table.concat(statsToUpgrade, ", ")
                .. (gold and (" | Gold: " .. tostring(gold)) or "")
        end

        if result.err and result.err ~= "invoke_failed" then
            return false, "Upgrade request failed: " .. tostring(result.err)
        end

        local confirmed, confirmation = waitForGearUpgradeConfirmation(
            weapon,
            previousLevels,
            statsToUpgrade,
            runId
        )
        if confirmed == nil then
            return nil, confirmation
        elseif confirmed then
            return true, "Upgrade confirmed: " .. table.concat(confirmation, ", ")
                .. (gold and (" | Gold before: " .. tostring(gold)) or "")
        elseif confirmation:find("Could not verify", 1, true) then
            return false, confirmation .. " Stopping to avoid duplicate upgrades."
        end

        if statCount > 1 then
            task.wait(0.2)
        end
    end

    -- Try the remaining stats individually only after each earlier request was verified unchanged.
    for index = 2, #orderedStats do
        if not isAutoUpgradeGearActive(runId) then
            return nil, "Stopped."
        end

        local statName = orderedStats[index]
        local previousLevels = table.clone(levels)
        local result = invokeActorFunction("S_Equipment", "Upgrade", { statName })
        if result.ok then
            return true, "Upgraded " .. weapon .. ": " .. statName
                .. (gold and (" | Gold: " .. tostring(gold)) or "")
        end

        if result.err and result.err ~= "invoke_failed" then
            return false, "Upgrade request failed for " .. statName .. ": " .. tostring(result.err)
        end

        local confirmed, confirmation = waitForGearUpgradeConfirmation(
            weapon,
            previousLevels,
            { statName },
            runId
        )
        if confirmed == nil then
            return nil, confirmation
        elseif confirmed then
            return true, "Upgrade confirmed: " .. table.concat(confirmation, ", ")
                .. (gold and (" | Gold before: " .. tostring(gold)) or "")
        elseif confirmation:find("Could not verify", 1, true) then
            return false, confirmation .. " Stopping to avoid duplicate upgrades."
        end
    end

    gold = readCurrentGold()
    if gold and gold < 100 then
        return false, "Not enough Gold: " .. tostring(gold) .. " (minimum 100)."
    end
    return false, "Game rejected every " .. weapon .. " upgrade. Gold: " .. tostring(gold or "unavailable")
end

local function runAutoUpgradeGear(runId)
    local lobbyPlaceId = 14916516914
    if game.PlaceId ~= lobbyPlaceId then
        stopAutoUpgradeGear()
        return
    end

    while isAutoUpgradeGearActive(runId) do
        if game.PlaceId ~= lobbyPlaceId then
            stopAutoUpgradeGear()
            return
        end

        local weapon = selectedGearWeapon
        local succeeded = tryUpgradeGear(weapon, runId)
        if succeeded == nil then
            return
        elseif not succeeded then
            stopAutoUpgradeGear()
            return
        end

        task.wait(1)
    end
end

local function selectSlotThroughGameUi(slots, slotName, runId)
    local slot = slots:FindFirstChild(slotName)
    local button = slot and slot:FindFirstChild("Select_" .. slotName)
    if not button or not button:IsA("GuiButton") or not button.Visible or not button.Active or not button.Selectable then
        return false, "Select button for slot " .. slotName .. " is unavailable"
    end

    if not isAutoSelectCharacterActive(runId) then
        return false, "Auto Select Character was stopped"
    end

    local input = Services.VirtualInputManager
    for attempt = 1, 3 do
        if not isAutoSelectCharacterActive(runId) then
            Services.GuiService.SelectedObject = nil
            return false, "Auto Select Character was stopped"
        end

        if not slots.Parent or not slots.Visible then
            if LocalPlayer:GetAttribute("Slot") == slotName then
                Services.GuiService.SelectedObject = nil
                return true
            end
            Services.GuiService.SelectedObject = nil
            return false, "The slot screen closed without confirming slot " .. slotName
        end

        if not button.Parent or not button.Visible or not button.Active then
            break
        end

        setAutoSelectStatus("Selecting slot " .. slotName .. " (attempt " .. attempt .. "/3)...")
        Services.GuiService.SelectedObject = button
        task.wait(0.2)
        if not isAutoSelectCharacterActive(runId) then
            Services.GuiService.SelectedObject = nil
            return false, "Auto Select Character was stopped"
        end

        if Services.GuiService.SelectedObject ~= button then
            Services.GuiService.SelectedObject = nil
            task.wait(0.2)
            continue
        end

        local pressed, pressError = pcall(function()
            input:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
        end)
        task.wait(0.12)
        local released, releaseError = pcall(function()
            input:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
        end)
        if not pressed or not released then
            Services.GuiService.SelectedObject = nil
            return false, "Could not press the selected slot button: " .. tostring(pressError or releaseError)
        end

        local confirmDeadline = os.clock() + 3
        while isAutoSelectCharacterActive(runId) and os.clock() < confirmDeadline do
            local selectedSlot = LocalPlayer:GetAttribute("Slot")
            if selectedSlot == slotName and (not slots.Parent or not slots.Visible) then
                Services.GuiService.SelectedObject = nil
                return true
            end
            task.wait(0.1)
        end

        Services.GuiService.SelectedObject = nil
        if not isAutoSelectCharacterActive(runId) then
            return false, "Auto Select Character was stopped"
        end
        if not slots.Parent or not slots.Visible then
            return false, "The slot screen closed without confirming slot " .. slotName
        end
    end

    if not isAutoSelectCharacterActive(runId) then
        return false, "Auto Select Character was stopped"
    end
    return false, "The game did not confirm slot " .. slotName .. " and close the slot screen"
end

local function runAutoSelectCharacter(runId)
    local mainMenuPlaceId = 13379208636
    if game.PlaceId ~= mainMenuPlaceId then
        warn("[AOTR] Auto Select Character only works in the Main Menu.")
        stopAutoSelectCharacter("Only available in the Main Menu.")
        return
    end

    setAutoSelectStatus("Waiting for character slots...")
    local slots
    local deadline = os.clock() + 15
    while isAutoSelectCharacterActive(runId) and os.clock() < deadline do
        local interface = PlayerGui:FindFirstChild("Interface")
        local titleScreen = interface and interface:FindFirstChild("Title_Screen")
        slots = titleScreen and titleScreen:FindFirstChild("Slots")
        if slots and slots.Visible then
            break
        end
        task.wait(0.3)
    end

    if not isAutoSelectCharacterActive(runId) then
        return
    end

    if not slots or not slots.Visible then
        warn("[AOTR] Auto Select Character could not find the visible character slots.")
        stopAutoSelectCharacter("Character slots were not found.")
        return
    end

    local shouldGoToLobby = goToLobbyAfterCharacterSelect
    setAutoSelectStatus("Selecting slot " .. selectedCharacterSlot .. "...")
    local slotSelected, selectError = selectSlotThroughGameUi(slots, selectedCharacterSlot, runId)

    if not slotSelected then
        warn("[AOTR] Failed to select character slot: " .. tostring(selectError))
        stopAutoSelectCharacter("Select failed: " .. tostring(selectError))
        return
    end

    task.wait(0.5)
    if not isAutoSelectCharacterActive(runId) then
        return
    end

    local completionStatus = "Slot " .. selectedCharacterSlot .. " selected. Staying in Main Menu."
    if shouldGoToLobby then
        setAutoSelectStatus("Going to Lobby...")
        local teleportResult = invokeActorFunction("Functions", "Teleport", "Lobby")
        if not teleportResult or not teleportResult.ok then
            local teleportError = teleportResult and teleportResult.err or "invoke_failed"
            warn("[AOTR] Character selected, but Lobby teleport failed: " .. tostring(teleportError))
            completionStatus = "Teleport failed: " .. tostring(teleportError)
        else
            completionStatus = "Slot selected. Teleporting to Lobby."
        end
    end

    stopAutoSelectCharacter(completionStatus)
end


local window = App:Window({
    Title = "Valox",
    Subtitle = "AOTR - Revolution",
    UIBlur = false,
})

local mouseInput = Services.UserInputService
local previousMouseIconEnabled = mouseInput.MouseIconEnabled
windowBodyInstance = window.Structures.Body.__instance
startAutoRetryUiWatch()
local windowPillInstance = App.Structures.WindowPill.__instance
local mouseBehaviorBeforeUi = {
    value = nil,
    managed = false,
    wasInCombatSession = CombatFeatures.isCombatSession(),
}

local function isMouseOver(guiObject, mousePosition)
    if not guiObject or not guiObject.Parent or not guiObject.Visible then
        return false
    end

    local position = guiObject.AbsolutePosition
    local size = guiObject.AbsoluteSize
    return mousePosition.X >= position.X
        and mousePosition.X <= position.X + size.X
        and mousePosition.Y >= position.Y
        and mousePosition.Y <= position.Y + size.Y
end

local function updateMouseCursor()
    if not windowBodyInstance.Parent then
        return
    end

    if not CombatFeatures.isCombatSession() then
        if mouseBehaviorBeforeUi.wasInCombatSession and mouseBehaviorBeforeUi.managed then
            mouseInput.MouseIconEnabled = true
            mouseInput.MouseBehavior = Enum.MouseBehavior.Default
            mouseBehaviorBeforeUi.value = nil
            mouseBehaviorBeforeUi.managed = false
        end
        mouseBehaviorBeforeUi.wasInCombatSession = false
        return
    end
    mouseBehaviorBeforeUi.wasInCombatSession = true

    local mousePosition = mouseInput:GetMouseLocation()
    local overWindow = not window.Minimized and isMouseOver(windowBodyInstance, mousePosition)
    local overWindowPill = isMouseOver(windowPillInstance, mousePosition)
    local cursorVisible = overWindow or overWindowPill

    if mouseInput.MouseIconEnabled ~= cursorVisible then
        mouseInput.MouseIconEnabled = cursorVisible
        mouseBehaviorBeforeUi.managed = true
    end

    if cursorVisible and mouseInput.MouseBehavior ~= Enum.MouseBehavior.Default then
        mouseBehaviorBeforeUi.value = mouseInput.MouseBehavior
        mouseInput.MouseBehavior = Enum.MouseBehavior.Default
        mouseBehaviorBeforeUi.managed = true
    elseif not cursorVisible and mouseBehaviorBeforeUi.value then
        mouseInput.MouseBehavior = mouseBehaviorBeforeUi.value
        mouseBehaviorBeforeUi.value = nil
    end
end

updateMouseCursor()
local mouseCursorConnection = Services.RunService.RenderStepped:Connect(updateMouseCursor)
local rightShiftConnection = mouseInput.InputBegan:Connect(function(input)
    if input.KeyCode ~= Enum.KeyCode.RightShift or mouseInput:GetFocusedTextBox() then
        return
    end

    window.Minimized = not window.Minimized
end)
windowBodyInstance.Destroying:Connect(function()
    mouseCursorConnection:Disconnect()
    rightShiftConnection:Disconnect()
    if autoLobbyRewardConnection then
        autoLobbyRewardConnection:Disconnect()
    end
    if AutoRetry.rewardChangedConnection then
        AutoRetry.rewardChangedConnection:Disconnect()
    end
    if AutoRetry.forceEndChangedConnection then
        AutoRetry.forceEndChangedConnection:Disconnect()
    end
    if mouseBehaviorBeforeUi.managed then
        mouseInput.MouseIconEnabled = previousMouseIconEnabled
    end
    if mouseBehaviorBeforeUi.value then
        mouseInput.MouseBehavior = mouseBehaviorBeforeUi.value
    end
end)

-- InGame --
local inGame = window:Section({ Title = "In-Game" })
local Farming = inGame:Tab({
    Title = "Farming",
    Icon = cascade.Symbols.leaf,
    Selected = true,
})

do
    local autoFarmForm = Farming:PageSection({
        Title = "Auto Farm",
        Subtitle = "Automatically farm during combat sessions.",
    }):Form()

    local farmStatusRow = autoFarmForm:Row({ SearchIndex = "Farm status" })
    farmStatusRow:Left():TitleStack({
        Title = "Status",
        Subtitle = "Current Auto Farm activity.",
    })
    FarmFeatures.statusLabel = farmStatusRow:Right():Label({ Text = "Idle" })

    local autoFarmRow = autoFarmForm:Row({ SearchIndex = "Auto Farm" })
    autoFarmRow:Left():TitleStack({
        Title = "Auto Farm",
        Subtitle = "Move to Titans and attack their Nape during a session.",
    })
    autoFarmToggle = autoFarmRow:Right():Toggle({
        Value = false,
        ValueChanged = function(_, value)
            if value then
                FarmFeatures.start()
            else
                FarmFeatures.stop()
            end
        end,
    })

    local autoExecuteRow = autoFarmForm:Row({ SearchIndex = "Auto Execute" })
    autoExecuteRow:Left():TitleStack({
        Title = "Auto Execute",
        Subtitle = "Queue the script to run again after teleporting.",
    })
    autoExecuteRow:Right():Toggle({
        Value = false,
        ValueChanged = function(_, value)
            FarmFeatures.setAutoExecute(value)
        end,
    })

    local autoRetryRow = autoFarmForm:Row({ SearchIndex = "Auto Retry" })
    autoRetryRow:Left():TitleStack({
        Title = "Auto Retry",
        Subtitle = "Automatically press Retry after a mission or raid ends.",
    })
    autoRetryRow:Right():Toggle({
        Value = false,
        ValueChanged = function(_, value)
            setAutoRetryEnabled(value)
        end,
    })
end

do
    local miscellaneousForm = Farming:PageSection({
        Title = "Miscellaneous",
        Subtitle = "Visual and weak-point helpers for combat sessions.",
    }):Form()

    local napeExtenderRow = miscellaneousForm:Row({ SearchIndex = "Nape Extender" })
    napeExtenderRow:Left():TitleStack({
        Title = "Nape Extender",
        Subtitle = "Expand all Titan Nape hitboxes.",
    })
    napeExtenderRow:Right():Toggle({
        Value = VisualFeatures.napeExtenderEnabled,
        ValueChanged = function(_, value)
            VisualFeatures.setNapeExtender(value)
        end,
    })

    local titanEspRow = miscellaneousForm:Row({ SearchIndex = "Titan ESP" })
    titanEspRow:Left():TitleStack({
        Title = "Titan ESP",
        Subtitle = "Highlight Titans through walls.",
    })
    titanEspRow:Right():Toggle({
        Value = VisualFeatures.titanEspEnabled,
        ValueChanged = function(_, value)
            VisualFeatures.setTitanESP(value)
        end,
    })
end

local Waves = inGame:Tab({
    Title = "Waves",
    Icon = cascade.Symbols.waterWaves,
})

local Settings = inGame:Tab({
    Title = "Settings",
    Icon = cascade.Symbols.gearshape,
})

do
local CombatFeaturesForm = Settings:PageSection({
    Title = "Combat features",
    Subtitle = "Automatic escape and reload helpers.",
}):Form()

local autoGrabEscapeRow = CombatFeaturesForm:Row({ SearchIndex = "Auto Grab Escape" })
autoGrabEscapeRow:Left():TitleStack({
    Title = "Auto Grab Escape",
    Subtitle = "Automatically slash to escape a grab.",
})
autoGrabEscapeRow:Right():Toggle({
    Value = CombatFeatures.autoGrabEscapeEnabled,
    ValueChanged = function(_, value)
        CombatFeatures.setAutoGrabEscapeEnabled(value)
    end,
})

local autoReloadBladesRow = CombatFeaturesForm:Row({ SearchIndex = "Auto Reload Blades" })
autoReloadBladesRow:Left():TitleStack({
    Title = "Auto Reload Blades",
    Subtitle = "Reload when the active blades are broken.",
})
autoReloadBladesRow:Right():Toggle({
    Value = CombatFeatures.autoReloadBladesEnabled,
    ValueChanged = function(_, value)
        CombatFeatures.autoReloadBladesEnabled = value
        CombatFeatures.updateCombatReloadLoop()
    end,
})

local autoFullReloadRow = CombatFeaturesForm:Row({ SearchIndex = "Auto Full Reload" })
autoFullReloadRow:Left():TitleStack({
    Title = "Auto Full Reload",
    Subtitle = "Use a refill when all blade sets or spears are empty.",
})
autoFullReloadRow:Right():Toggle({
    Value = CombatFeatures.autoFullReloadEnabled,
    ValueChanged = function(_, value)
        CombatFeatures.autoFullReloadEnabled = value
        CombatFeatures.updateCombatReloadLoop()
    end,
})

CombatFeatures.setAutoGrabEscapeEnabled(CombatFeatures.autoGrabEscapeEnabled)
CombatFeatures.updateCombatReloadLoop()
end

do
    local safetyForm = Settings:PageSection({
        Title = "Safety",
        Subtitle = "Set minimum session times used by Auto Farm.",
    }):Form()

    local missionTimerRow = safetyForm:Row({ SearchIndex = "Mission safety timer" })
    local missionTimerTitle = missionTimerRow:Left():TitleStack({
        Title = "Mission Safety Timer",
        Subtitle = string.format("Wait before defeating the final Titan: %ds.", FarmFeatures.missionSafetyTimer),
    })
    missionTimerRow:Right():Slider({
        Minimum = 40,
        Maximum = 600,
        Value = FarmFeatures.missionSafetyTimer,
        ValueChanged = function(_, value)
            FarmFeatures.missionSafetyTimer = value
            missionTimerTitle.Subtitle = string.format("Wait before defeating the final Titan: %ds.", math.floor(value + 0.5))
        end,
    })

    local raidTimerRow = safetyForm:Row({ SearchIndex = "Raid safety timer" })
    local raidTimerTitle = raidTimerRow:Left():TitleStack({
        Title = "Raid Safety Timer",
        Subtitle = string.format("Minimum raid time: %ds.", FarmFeatures.raidSafetyTimer),
    })
    raidTimerRow:Right():Slider({
        Minimum = 60,
        Maximum = 900,
        Value = FarmFeatures.raidSafetyTimer,
        ValueChanged = function(_, value)
            FarmFeatures.raidSafetyTimer = value
            raidTimerTitle.Subtitle = string.format("Minimum raid time: %ds.", math.floor(value + 0.5))
        end,
    })

    local movementSettingsForm = Settings:PageSection({
        Title = "Movement Settings",
        Subtitle = "Adjust Auto Farm movement and startup delay.",
    }):Form()

    local hoverHeightRow = movementSettingsForm:Row({ SearchIndex = "Hover height" })
    local hoverHeightTitle = hoverHeightRow:Left():TitleStack({
        Title = "Hover Height",
        Subtitle = string.format("Height above the target: %d studs.", FarmFeatures.hoverHeight),
    })
    hoverHeightRow:Right():Slider({
        Minimum = 100,
        Maximum = 800,
        Value = FarmFeatures.hoverHeight,
        ValueChanged = function(_, value)
            FarmFeatures.hoverHeight = value
            hoverHeightTitle.Subtitle = string.format("Height above the target: %d studs.", math.floor(value + 0.5))
        end,
    })

    local hoverSpeedRow = movementSettingsForm:Row({ SearchIndex = "Hover speed" })
    local hoverSpeedTitle = hoverSpeedRow:Left():TitleStack({
        Title = "Hover Speed",
        Subtitle = string.format("Movement speed: %d studs/s.", FarmFeatures.hoverSpeed),
    })
    hoverSpeedRow:Right():Slider({
        Minimum = 250,
        Maximum = 2000,
        Value = FarmFeatures.hoverSpeed,
        ValueChanged = function(_, value)
            FarmFeatures.hoverSpeed = value
            hoverSpeedTitle.Subtitle = string.format("Movement speed: %d studs/s.", math.floor(value + 0.5))
        end,
    })

    local waitBeforeFarmRow = movementSettingsForm:Row({ SearchIndex = "Wait before farming" })
    local waitBeforeFarmTitle = waitBeforeFarmRow:Left():TitleStack({
        Title = "Wait Before Farming",
        Subtitle = string.format("Start delay: %ds.", FarmFeatures.waitBeforeFarming),
    })
    waitBeforeFarmRow:Right():Slider({
        Minimum = 5,
        Maximum = 60,
        Value = FarmFeatures.waitBeforeFarming,
        ValueChanged = function(_, value)
            FarmFeatures.waitBeforeFarming = value
            waitBeforeFarmTitle.Subtitle = string.format("Start delay: %ds.", math.floor(value + 0.5))
        end,
    })

    local autoLobbyForm = Settings:PageSection({
        Title = "Auto Lobby",
        Subtitle = "Return to the Lobby after a chosen number of completed missions or raids.",
    }):Form()

    local autoLobbyToggleRow = autoLobbyForm:Row({ SearchIndex = "Auto Back to Lobby" })
    autoLobbyToggleRow:Left():TitleStack({
        Title = "Auto Back to Lobby",
        Subtitle = "Return to the Lobby after completing the selected number of missions or raids.",
    })
    autoLobbyToggleRow:Right():Toggle({
        Value = AutoLobby.enabled,
        ValueChanged = function(_, value)
            AutoLobby.enabled = value
            if not value then
                AutoLobby.completedSessions = 0
                AutoLobby.returning = false
            end
            updateAutoLobbySubtitle()
        end,
    })

    local autoLobbyAfterRow = autoLobbyForm:Row({ SearchIndex = "Back to Lobby After" })
    AutoLobby.titleStack = autoLobbyAfterRow:Left():TitleStack({
        Title = "Back to Lobby After",
        Subtitle = string.format(
            "Missions/raids before returning. Completed: %d/%d.",
            AutoLobby.completedSessions,
            AutoLobby.after
        ),
    })
    autoLobbyAfterRow:Right():Slider({
        Minimum = 1,
        Maximum = 50,
        Value = AutoLobby.after,
        ValueChanged = function(_, value)
            AutoLobby.after = math.floor(value + 0.5)
            if AutoLobby.completedSessions >= AutoLobby.after then
                AutoLobby.completedSessions = math.max(0, AutoLobby.after - 1)
            end
            updateAutoLobbySubtitle()
        end,
    })

    local soloOnlyForm = Settings:PageSection({
        Title = "Solo Only",
        Subtitle = "Leave if another player joins while Auto Farm is running.",
    }):Form()

    local soloOnlyRow = soloOnlyForm:Row({ SearchIndex = "Solo Only" })
    soloOnlyRow:Left():TitleStack({
        Title = "Solo Only",
        Subtitle = "Auto leave if another player joins while farming.",
    })
    soloOnlyRow:Right():Toggle({
        Value = SoloOnly.enabled,
        ValueChanged = function(_, value)
            SoloOnly.enabled = value
            if value then
                SoloOnly.start()
            else
                SoloOnly.stop()
                SoloOnly.checkedForSession = false
            end
        end,
    })

    local visualForm = Settings:PageSection({
        Title = "Visual",
        Subtitle = "Adjust in-game visibility effects.",
    }):Form()

    local removeFogRow = visualForm:Row({ SearchIndex = "Remove Fog" })
    removeFogRow:Left():TitleStack({
        Title = "Remove Fog",
        Subtitle = "Turn off fog in-game and keep it reduced when the game reapplies it.",
    })
    removeFogRow:Right():Toggle({
        Value = VisualFeatures.removeFogEnabled,
        ValueChanged = function(_, value)
            VisualFeatures.setFog(value)
        end,
    })
    VisualFeatures.setFog(VisualFeatures.removeFogEnabled)
end

-- Lobby -- 
local lobby = window:Section({ Title = "Lobby" })
local LobbyAutomation = lobby:Tab({
    Title = "Automation",
    Icon = cascade.Symbols.gearshape2,
})

local GearUpgradeForm = LobbyAutomation:PageSection({
    Title = "Gear Upgrader",
    Subtitle = "Automatically upgrade gear while you are in the Lobby.",
}):Form()

local gearUpgradeInfoRow = GearUpgradeForm:Row({ SearchIndex = "Upgrade visibility" })
gearUpgradeInfoRow:Left():TitleStack({
    Title = "Info!",
    Subtitle = "Upgrades may be saved before the equipment screen updates. Rejoin to see the new upgrade values.",
})

local autoUpgradeGearRow = GearUpgradeForm:Row({ SearchIndex = "Auto Upgrade Gear" })
autoUpgradeGearRow:Left():TitleStack({
    Title = "Auto Upgrade Gear",
    Subtitle = "Upgrade the selected gear until it cannot be upgraded further.",
})
autoUpgradeGearToggle = autoUpgradeGearRow:Right():Toggle({
    Value = false,
    ValueChanged = function(_, value)
        autoUpgradeGearEnabled = value
        autoUpgradeGearRunId += 1

        if value then
            local runId = autoUpgradeGearRunId
            task.spawn(function()
                local succeeded, errorMessage = pcall(runAutoUpgradeGear, runId)
                if not succeeded then
                    warn("[AOTR] Auto Upgrade Gear error: " .. tostring(errorMessage))
                    stopAutoUpgradeGear()
                end
            end)
        end
    end,
})

local gearTypeRow = GearUpgradeForm:Row({ SearchIndex = "Gear type" })
gearTypeRow:Left():TitleStack({
    Title = "Gear type",
    Subtitle = "Choose which equipment to upgrade.",
})
local gearTypeDropdown = gearTypeRow:Right():PullDownButton({
    Label = selectedGearWeapon,
    Options = {},
    ValueChanged = function(self, selectedIndex)
        selectedGearWeapon = self.Options[selectedIndex] or "Blades"
        self.Label = selectedGearWeapon
    end,
})
gearTypeDropdown:Option("Blades")
gearTypeDropdown:Option("Spears")
gearTypeDropdown.Value = 1

local AchievementsForm = LobbyAutomation:PageSection({
    Title = "Achievements",
    Subtitle = "Claim completed achievements while you are in the Lobby.",
}):Form()

local autoClaimAchievementsRow = AchievementsForm:Row({ SearchIndex = "Auto Claim Achievements" })
autoClaimAchievementsRow:Left():TitleStack({
    Title = "Auto Claim Achievements",
    Subtitle = "Try to claim all completed achievements in the Lobby.",
})
autoClaimAchievementsToggle = autoClaimAchievementsRow:Right():Toggle({
    Value = false,
    ValueChanged = function(_, value)
        autoClaimAchievementsEnabled = value
        autoClaimAchievementsRunId += 1
        if value then
            local runId = autoClaimAchievementsRunId
            task.spawn(function()
                local succeeded, errorMessage = pcall(runAutoClaimAchievements, runId)
                if not succeeded then
                    warn("[AOTR] Auto Claim Achievements error: " .. tostring(errorMessage))
                    stopAutoClaimAchievements()
                end
            end)
        end
    end,
})

local Prestige = lobby:Tab({
    Title = "Prestige",
    Icon = cascade.Symbols.star,
})

local prestigeStatusForm = Prestige:PageSection({
    Title = "Auto Prestige (Lobby only)",
    Subtitle = "Set a minimum Gold amount for each tier, then enable Auto Prestige.",
}):Form()

local prestigeStatusRow = prestigeStatusForm:Row({ SearchIndex = "Prestige status" })
prestigeStatusRow:Left():TitleStack({
    Title = "Status",
    Subtitle = "Progress and eligibility for the active character slot.",
})
prestigeStatusLabel = prestigeStatusRow:Right():Label({ Text = "Idle." })

local prestigeBoostOptions = { "Luck", "EXP", "Gold" }
for tier = 1, 5 do
    local prestigeTier = tier
    local prestigeTierForm = Prestige:PageSection({
        Title = string.format("Prestige %d → %d", tier - 1, tier),
        Subtitle = "Settings for this prestige tier.",
    }):Form()

    local goldRow = prestigeTierForm:Row({ SearchIndex = string.format("Prestige %d minimum Gold", tier) })
    goldRow:Left():TitleStack({
        Title = "Min Gold",
        Subtitle = "Wait until this amount is reached; 0 means no Gold limit.",
    })
    goldRow:Right():TextField({
        Value = tostring(prestigeMinGold[tier]),
        Placeholder = "0 = immediate",
        ValueChanged = function(_, value)
            prestigeMinGold[prestigeTier] = math.max(0, tonumber((tostring(value or ""):gsub("[%s,]", ""))) or 0)
        end,
    })

    local boostRow = prestigeTierForm:Row({ SearchIndex = string.format("Prestige %d boost", tier) })
    boostRow:Left():TitleStack({
        Title = "Boost",
        Subtitle = "Choose the boost to receive at this tier.",
    })
    boostRow:Right():PullDownButton({
        Label = prestigeBoosts[tier],
        Options = prestigeBoostOptions,
        Value = table.find(prestigeBoostOptions, prestigeBoosts[tier]) or 3,
        ValueChanged = function(self, selectedIndex)
            prestigeBoosts[prestigeTier] = self.Options[selectedIndex] or "Gold"
            self.Label = prestigeBoosts[prestigeTier]
        end,
    })
end

local prestigeControlForm = Prestige:PageSection({
    Title = "Control",
    Subtitle = "Automatically prestige when the character is eligible and the Gold limit is met.",
}):Form()

local autoPrestigeRow = prestigeControlForm:Row({ SearchIndex = "Auto Prestige" })
autoPrestigeRow:Left():TitleStack({
    Title = "Auto Prestige",
    Subtitle = "Repeat prestige while eligible and in the Lobby.",
})
autoPrestigeToggle = autoPrestigeRow:Right():Toggle({
    Value = false,
    ValueChanged = function(_, value)
        autoPrestigeEnabled = value
        autoPrestigeRunId += 1
        if value then
            local runId = autoPrestigeRunId
            task.spawn(function()
                local succeeded, errorMessage = pcall(runAutoPrestige, runId)
                if not succeeded then
                    warn("[AOTR] Auto Prestige error: " .. tostring(errorMessage))
                    stopAutoPrestige("Error: " .. tostring(errorMessage))
                end
            end)
        else
            setPrestigeStatus("Idle.")
        end
    end,
})

local GameModes = lobby:Tab({
    Title = "Gamemodes",
    Icon = cascade.Symbols.gamecontroller,
})

local RaidsForm = GameModes:PageSection({
    Title = "Raids",
    Subtitle = "Create and start a raid session.",
}):Form()
local raidObjectiveRow = RaidsForm:Row({ SearchIndex = "Raid objective" })
raidObjectiveRow:Left():TitleStack({
    Title = "Raid",
    Subtitle = "Choose the raid titan.",
})
raidObjectiveRow:Right():PullDownButton({
    Label = selectedRaidObjective,
    Options = raidObjectives,
    Value = table.find(raidObjectives, selectedRaidObjective) or 1,
    ValueChanged = function(self, selectedIndex)
        selectedRaidObjective = self.Options[selectedIndex] or raidObjectives[1]
        self.Label = selectedRaidObjective
        if selectedRaidObjective == "Colossal Titan" and selectedRaidDifficulty ~= "Aberrant" then
            selectedRaidDifficulty = "Aberrant"
            if raidDifficultyDropdown then
                raidDifficultyDropdown.Value = table.find(raidDifficulties, "Aberrant")
                raidDifficultyDropdown.Label = "Aberrant"
            end
        end
    end,
})

local raidDifficultyRow = RaidsForm:Row({ SearchIndex = "Raid difficulty" })
raidDifficultyRow:Left():TitleStack({
    Title = "Difficulty",
    Subtitle = "Colossal Titan requires Aberrant.",
})
raidDifficultyDropdown = raidDifficultyRow:Right():PullDownButton({
    Label = selectedRaidDifficulty,
    Options = raidDifficulties,
    Value = table.find(raidDifficulties, selectedRaidDifficulty) or #raidDifficulties,
    ValueChanged = function(self, selectedIndex)
        local difficulty = self.Options[selectedIndex]
        if not difficulty then
            return
        end
        if selectedRaidObjective == "Colossal Titan" and difficulty ~= "Aberrant" then
            self.Value = table.find(raidDifficulties, "Aberrant")
            self.Label = "Aberrant"
            selectedRaidDifficulty = "Aberrant"
            return
        end
        selectedRaidDifficulty = difficulty
        self.Label = difficulty
    end,
})

local raidModifiersRow = RaidsForm:Row({ SearchIndex = "Raid modifiers" })
raidModifiersRow:Left():TitleStack({
    Title = "Modifiers",
    Subtitle = "Choose modifiers to apply to the raid.",
})
raidModifiersRow:Right():PopUpButton({
    Options = missionModifiers,
    Maximum = #missionModifiers,
    Value = {},
    ValueChanged = function(self, selectedIndexes)
        selectedRaidModifiers = {}
        for _, selectedIndex in ipairs(selectedIndexes or {}) do
            local modifier = self.Options[selectedIndex]
            if modifier then
                selectedRaidModifiers[#selectedRaidModifiers + 1] = modifier
            end
        end
    end,
})

local autoCreateRaidRow = RaidsForm:Row({ SearchIndex = "Auto Create Raid Session" })
autoCreateRaidRow:Left():TitleStack({
    Title = "Auto Create Session",
    Subtitle = "Retry creating the selected raid until it starts.",
})
autoCreateRaidToggle = autoCreateRaidRow:Right():Toggle({
    Value = false,
    ValueChanged = function(_, value)
        autoCreateRaidEnabled = value
        autoCreateRaidRunId += 1
        if value then
            local runId = autoCreateRaidRunId
            task.spawn(function()
                local succeeded, errorMessage = pcall(runAutoCreateRaid, runId)
                if not succeeded then
                    warn("[AOTR] Auto Create Raid error: " .. tostring(errorMessage))
                    stopAutoCreateRaid()
                end
            end)
        end
    end,
})

local createRaidRow = RaidsForm:Row({ SearchIndex = "Create Raid Once Now" })
createRaidRow:Left():TitleStack({
    Title = "Create Once Now",
    Subtitle = "Create and start the selected raid once.",
})
createRaidRow:Right():Button({
    Label = "Create Once Now",
    State = "Primary",
    Pushed = function()
        task.spawn(function()
            local succeeded, message = createAndStartRaid()
            if not succeeded then
                warn("[AOTR] Create Raid Once Now: " .. tostring(message))
            end
        end)
    end,
})

local MissionsForm = GameModes:PageSection({
    Title = "Missions",
    Subtitle = "Create and start a mission session.",
}):Form()

local boostedMapRow = MissionsForm:Row({ SearchIndex = "Boosted map" })
boostedMapRow:Left():TitleStack({
    Title = "Boosted map",
    Subtitle = "Map with an active boost.",
})
missionBoostMapLabel = boostedMapRow:Right():Label({ Text = "Checking..." })

local function refreshMissionBoostedMap()
    local boostedMap = workspace:GetAttribute("Boosted_Map")
    if type(boostedMap) ~= "string" or boostedMap == "" then
        missionBoostMapLabel.Text = "No active boost"
        return
    end

    local remainingSeconds = math.max(0, math.floor(tonumber(workspace:GetAttribute("Boosted_Timer")) or 0))
    local minutes = math.floor(remainingSeconds / 60)
    local seconds = remainingSeconds % 60
    missionBoostMapLabel.Text = string.format("%s · %02d:%02d", boostedMap, minutes, seconds)
end

refreshMissionBoostedMap()
workspace:GetAttributeChangedSignal("Boosted_Map"):Connect(refreshMissionBoostedMap)
workspace:GetAttributeChangedSignal("Boosted_Timer"):Connect(refreshMissionBoostedMap)

local missionMapNames = {}
for _, mapInfo in ipairs(missionMaps) do
    missionMapNames[#missionMapNames + 1] = mapInfo.Name
end

local missionMapRow = MissionsForm:Row({ SearchIndex = "Mission map" })
missionMapRow:Left():TitleStack({
    Title = "Map",
    Subtitle = "Choose the mission map.",
})
local missionMapDropdown = missionMapRow:Right():PullDownButton({
    Label = selectedMissionMap,
    Options = missionMapNames,
    Value = table.find(missionMapNames, selectedMissionMap) or 1,
    ValueChanged = function(self, selectedIndex)
        selectedMissionMap = self.Options[selectedIndex] or missionMaps[1].Name
        self.Label = selectedMissionMap

        if missionObjectiveDropdown then
            local objectives = missionObjectivesFor(selectedMissionMap)
            updatingMissionObjectives = true
            for index = #missionObjectiveDropdown.Options, 1, -1 do
                missionObjectiveDropdown:Remove(index)
            end
            for _, objectiveName in ipairs(objectives) do
                missionObjectiveDropdown:Option(objectiveName)
            end

            local objectiveIndex = table.find(objectives, selectedMissionObjective)
            if not objectiveIndex then
                selectedMissionObjective = objectives[1] or "Skirmish"
                objectiveIndex = 1
            end
            missionObjectiveDropdown.Value = objectiveIndex
            missionObjectiveDropdown.Label = selectedMissionObjective
            updatingMissionObjectives = false
        end
    end,
})

local missionObjectiveRow = MissionsForm:Row({ SearchIndex = "Mission objective" })
missionObjectiveRow:Left():TitleStack({
    Title = "Objective",
    Subtitle = "Choose the objective for this map.",
})
local startingObjectives = missionObjectivesFor(selectedMissionMap)
missionObjectiveDropdown = missionObjectiveRow:Right():PullDownButton({
    Label = selectedMissionObjective,
    Options = startingObjectives,
    Value = table.find(startingObjectives, selectedMissionObjective) or 1,
    ValueChanged = function(self, selectedIndex)
        if updatingMissionObjectives then
            return
        end
        selectedMissionObjective = self.Options[selectedIndex] or "Skirmish"
        self.Label = selectedMissionObjective
    end,
})

local missionDifficultyRow = MissionsForm:Row({ SearchIndex = "Mission difficulty" })
missionDifficultyRow:Left():TitleStack({
    Title = "Difficulty",
    Subtitle = "Choose the session difficulty.",
})
missionDifficultyDropdown = missionDifficultyRow:Right():PullDownButton({
    Label = selectedMissionDifficulty,
    Options = missionDifficulties,
    Value = table.find(missionDifficulties, selectedMissionDifficulty) or 2,
    ValueChanged = function(self, selectedIndex)
        selectedMissionDifficulty = self.Options[selectedIndex] or "Normal"
        self.Label = selectedMissionDifficulty
    end,
})

local missionModifiersRow = MissionsForm:Row({ SearchIndex = "Mission modifiers" })
missionModifiersRow:Left():TitleStack({
    Title = "Modifiers",
    Subtitle = "Choose the modifiers to apply.",
})
missionModifiersRow:Right():PopUpButton({
    Options = missionModifiers,
    Maximum = #missionModifiers,
    Value = {},
    ValueChanged = function(self, selectedIndexes)
        selectedMissionModifiers = {}
        for _, selectedIndex in ipairs(selectedIndexes or {}) do
            local modifier = self.Options[selectedIndex]
            if modifier then
                selectedMissionModifiers[#selectedMissionModifiers + 1] = modifier
            end
        end
    end,
})

local autoCreateMissionRow = MissionsForm:Row({ SearchIndex = "Auto Create Session" })
autoCreateMissionRow:Left():TitleStack({
    Title = "Auto Create Session",
    Subtitle = "Retry creating the selected mission until it starts.",
})
autoCreateMissionToggle = autoCreateMissionRow:Right():Toggle({
    Value = false,
    ValueChanged = function(_, value)
        autoCreateMissionEnabled = value
        autoCreateMissionRunId += 1
        if value then
            local runId = autoCreateMissionRunId
            task.spawn(function()
                local succeeded, errorMessage = pcall(runAutoCreateMission, runId)
                if not succeeded then
                    warn("[AOTR] Auto Create Session error: " .. tostring(errorMessage))
                    stopAutoCreateMission()
                end
            end)
        end
    end,
})

local createMissionRow = MissionsForm:Row({ SearchIndex = "Create Once Now" })
createMissionRow:Left():TitleStack({
    Title = "Create Once Now",
    Subtitle = "Create and start the selected mission once.",
})
createMissionRow:Right():Button({
    Label = "Create Once Now",
    State = "Primary",
    Pushed = function()
        task.spawn(function()
            local succeeded, message = createAndStartMission()
            if not succeeded then
                warn("[AOTR] Create Once Now: " .. tostring(message))
            end
        end)
    end,
})

local WavesForm = GameModes:PageSection({
    Title = "Waves",
    Subtitle = "Create and start a wave session.",
}):Form()
local autoCreateWaveRow = WavesForm:Row({ SearchIndex = "Auto Create Wave Session" })
autoCreateWaveRow:Left():TitleStack({
    Title = "Auto Create Session",
    Subtitle = "Retry creating a wave session until it starts.",
})
autoCreateWaveToggle = autoCreateWaveRow:Right():Toggle({
    Value = false,
    ValueChanged = function(_, value)
        autoCreateWaveEnabled = value
        autoCreateWaveRunId += 1
        if value then
            local runId = autoCreateWaveRunId
            task.spawn(function()
                local succeeded, errorMessage = pcall(runAutoCreateWave, runId)
                if not succeeded then
                    warn("[AOTR] Auto Create Wave error: " .. tostring(errorMessage))
                    stopAutoCreateWave()
                end
            end)
        end
    end,
})

local createWaveRow = WavesForm:Row({ SearchIndex = "Create Wave Once Now" })
createWaveRow:Left():TitleStack({
    Title = "Create Once Now",
    Subtitle = "Create and start a wave session once.",
})
createWaveRow:Right():Button({
    Label = "Create Once Now",
    State = "Primary",
    Pushed = function()
        task.spawn(function()
            local succeeded, message = createAndStartWave()
            if not succeeded then
                warn("[AOTR] Create Wave Once Now: " .. tostring(message))
            end
        end)
    end,
})

-- Main Menu --
local mainMenu = window:Section({ Title = "Main Menu" })
local MainMenuAutomation = mainMenu:Tab({
    Title = "Automation",
    Icon = cascade.Symbols.wandAndStars,
})

local MainMenuAutomationForm = MainMenuAutomation:PageSection({
    Title = "Family Roller",
    Subtitle = "Automatic rolls family.",
}):Form()

local familyStatusRow = MainMenuAutomationForm:Row({ SearchIndex = "Status" })
familyStatusRow:Left():TitleStack({
    Title = "Status",
    Subtitle = "Current family roll status.",
})
familyStatusLabel = familyStatusRow:Right():Label({ Text = "Idle." })

local autoRollFamilyRow = MainMenuAutomationForm:Row({ SearchIndex = "Auto Roll Family" })
autoRollFamilyRow:Left():TitleStack({
    Title = "Auto Roll Family",
    Subtitle = "Roll until one of the selected families is found.",
})
autoRollFamilyToggle = autoRollFamilyRow:Right():Toggle({
    Value = false,
    ValueChanged = function(_, value)
        autoRollFamilyEnabled = value
        autoRollFamilyRunId += 1
        local runId = autoRollFamilyRunId

        if value then
            task.spawn(runFamilyRoll, runId)
        else
            Services.GuiService.SelectedObject = nil
            setFamilyStatus("Stopped.")
        end
    end,
})

local autoStoreFamilyRow = MainMenuAutomationForm:Row({ SearchIndex = "Auto Store Family" })
autoStoreFamilyRow:Left():TitleStack({
    Title = "Auto Store Family",
    Subtitle = "Store a target family and continue rolling.",
})
autoStoreFamilyRow:Right():Toggle({
    Value = false,
    ValueChanged = function(_, value)
        autoStoreFamily = value
    end,
})

local epicFamilyRow = MainMenuAutomationForm:Row({ SearchIndex = "Epic" })
epicFamilyRow:Left():TitleStack({ Title = "Epic" })
epicFamilyRow:Right():PopUpButton({
    Options = epicFamilyOptions,
    Maximum = #epicFamilyOptions,
    Value = {},
    ValueChanged = function(self, selectedIndex)
        selectedEpicFamilies = {}
        for _, index in ipairs(selectedIndex) do
            table.insert(selectedEpicFamilies, self.Options[index])
        end
    end,
})

local legendaryFamilyRow = MainMenuAutomationForm:Row({ SearchIndex = "Legendary" })
legendaryFamilyRow:Left():TitleStack({ Title = "Legendary" })
legendaryFamilyRow:Right():PopUpButton({
    Options = legendaryFamilyOptions,
    Maximum = #legendaryFamilyOptions,
    Value = {},
    ValueChanged = function(self, selectedIndex)
        selectedLegendaryFamilies = {}
        for _, index in ipairs(selectedIndex) do
            table.insert(selectedLegendaryFamilies, self.Options[index])
        end
    end,
})

local mythicFamilyRow = MainMenuAutomationForm:Row({ SearchIndex = "Mythic" })
mythicFamilyRow:Left():TitleStack({ Title = "Mythic" })
mythicFamilyRow:Right():PopUpButton({
    Options = mythicFamilyOptions,
    Maximum = #mythicFamilyOptions,
    Value = {},
    ValueChanged = function(self, selectedIndex)
        selectedMythicFamilies = {}
        for _, index in ipairs(selectedIndex) do
            table.insert(selectedMythicFamilies, self.Options[index])
        end
    end,
})

local CharacterSlotForm = MainMenuAutomation:PageSection({
    Title = "Character Slot Settings",
    Subtitle = "Choose a character slot and go to the Lobby from the Main Menu.",
}):Form()

local autoSelectStatusRow = CharacterSlotForm:Row({ SearchIndex = "Auto Select Status" })
autoSelectStatusRow:Left():TitleStack({
    Title = "Status",
    Subtitle = "Auto Select Character progress.",
})
autoSelectStatusLabel = autoSelectStatusRow:Right():Label({ Text = "Idle." })

local activeSlotRow = CharacterSlotForm:Row({ SearchIndex = "Active Slot" })
activeSlotRow:Left():TitleStack({
    Title = "Active Slot",
    Subtitle = "Character slot to select on the Main Menu.",
})
local activeSlotDropdown = activeSlotRow:Right():PullDownButton({
    Label = selectedCharacterSlot,
    Options = {},
    ValueChanged = function(self, selectedIndex)
        selectedCharacterSlot = self.Options[selectedIndex] or "A"
        self.Label = selectedCharacterSlot
    end,
})
activeSlotDropdown:Option("A")
activeSlotDropdown:Option("B")
activeSlotDropdown:Option("C")
activeSlotDropdown.Value = 1

local autoSelectCharacterRow = CharacterSlotForm:Row({ SearchIndex = "Auto Select Character" })
autoSelectCharacterRow:Left():TitleStack({
    Title = "Auto Select Character",
    Subtitle = "Select the active slot and go to the Lobby (Main Menu only).",
})
autoSelectCharacterToggle = autoSelectCharacterRow:Right():Toggle({
    Value = false,
    ValueChanged = function(_, value)
        autoSelectCharacterEnabled = value
        autoSelectCharacterRunId += 1
        if value then
            local runId = autoSelectCharacterRunId
            task.spawn(function()
                local succeeded, errorMessage = pcall(runAutoSelectCharacter, runId)
                if not succeeded then
                    warn("[AOTR] Auto Select Character error: " .. tostring(errorMessage))
                    stopAutoSelectCharacter("Error: " .. tostring(errorMessage))
                end
            end)
        else
            setAutoSelectStatus("Stopped.")
        end
    end,
})

local goToLobbyRow = CharacterSlotForm:Row({ SearchIndex = "Go to Lobby after selection" })
goToLobbyRow:Left():TitleStack({
    Title = "Go to Lobby after selection",
    Subtitle = "Teleport to the Lobby after selecting the character slot.",
})
goToLobbyRow:Right():Toggle({
    Value = goToLobbyAfterCharacterSelect,
    ValueChanged = function(_, value)
        goToLobbyAfterCharacterSelect = value
    end,
})


-- Misc --
;(function(window, App, cascade, Services, configRecorder)
local misc = window:Section({ Title = "Misc" })
local Config = misc:Tab({
    Title = "Config",
    Icon = cascade.Symbols.sliderHorizontal3,
})

local AppearanceForm = Config:PageSection({ Title = "Appearance" }):Form()

local darkModeRow = AppearanceForm:Row({ SearchIndex = "Dark mode" })
darkModeRow:Left():TitleStack({
    Title = "Dark mode",
    Subtitle = "Use a dark color palette for the application.",
})
darkModeRow:Right():Toggle({
    Value = App.Theme == cascade.Themes.Dark,
    ValueChanged = function(_, value)
        App.Theme = value and cascade.Themes.Dark or cascade.Themes.Light
    end,
})

local accentNames = { "Blue", "Red", "Orange", "Yellow", "Green", "Graphite", "Pink", "Purple" }
local accentValue = 1
for index, accentName in ipairs(accentNames) do
    if App.Accent == cascade.Accents[accentName] then
        accentValue = index
        break
    end
end

local accentColorRow = AppearanceForm:Row({ SearchIndex = "Accent color" })
accentColorRow:Left():TitleStack({
    Title = "Accent color",
    Subtitle = "Choose the application's highlight color.",
})
accentColorRow:Right():PullDownButton({
    Label = accentNames[accentValue],
    Options = accentNames,
    Value = accentValue,
    ValueChanged = function(_, selectedIndex)
        local accentName = accentNames[selectedIndex]
        if accentName and cascade.Accents[accentName] then
            App.Accent = cascade.Accents[accentName]
        end
    end,
})

local WindowSettingsForm = Config:PageSection({
    Title = "Window",
    Subtitle = "Configure window behavior and visual effects.",
}):Form()

local searchableRow = WindowSettingsForm:Row({ SearchIndex = "Searchable" })
searchableRow:Left():TitleStack({
    Title = "Searchable",
    Subtitle = "Allow pages to be searched from the title bar.",
})
searchableRow:Right():Toggle({
    Value = window.Searching,
    ValueChanged = function(_, value)
        window.Searching = value
    end,
})

local draggableRow = WindowSettingsForm:Row({ SearchIndex = "Draggable" })
draggableRow:Left():TitleStack({
    Title = "Draggable",
    Subtitle = "Allow the window to be moved.",
})
draggableRow:Right():Toggle({
    Value = window.Draggable,
    ValueChanged = function(_, value)
        window.Draggable = value
    end,
})

local resizableRow = WindowSettingsForm:Row({ SearchIndex = "Resizable" })
resizableRow:Left():TitleStack({
    Title = "Resizable",
    Subtitle = "Allow the window to be resized.",
})
resizableRow:Right():Toggle({
    Value = window.Resizable,
    ValueChanged = function(_, value)
        window.Resizable = value
    end,
})

local dropShadowRow = WindowSettingsForm:Row({ SearchIndex = "Drop shadow" })
dropShadowRow:Left():TitleStack({
    Title = "Drop shadow",
    Subtitle = "Show a shadow around the window.",
})
dropShadowRow:Right():Toggle({
    Value = window.Dropshadow,
    ValueChanged = function(_, value)
        window.Dropshadow = value
    end,
})

local backgroundBlurRow = WindowSettingsForm:Row({ SearchIndex = "Background blur" })
backgroundBlurRow:Left():TitleStack({
    Title = "Background blur",
    Subtitle = "Blur the game behind the window.",
})
backgroundBlurRow:Right():Toggle({
    Value = window.UIBlur,
    ValueChanged = function(_, value)
        window.UIBlur = value
    end,
})

local ConfigManager = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/Valox321/Custom-UI/main/Casade-Config"))(Config, Services, configRecorder)

local MiscTab = misc:Tab({
    Title = "Misc",
    Icon = cascade.Symbols.sidebarLeft,
})

local utilityForm = MiscTab:PageSection({
    Title = "Safety & Utilities",
    Subtitle = "Check account status and move between game areas.",
}):Form()

local function showUtilityNotification(title, message)
    local succeeded, notificationError = pcall(function()
        App:Notification({
            App = "AOTR",
            Title = title,
            Subtitle = message,
            Icon = cascade.Symbols.bell,
            Duration = 5,
        })
    end)

    if not succeeded then
        warn("[AOTR] Cascade notification failed: " .. tostring(notificationError))
    end
end

local shadowBanRow = utilityForm:Row({ SearchIndex = "Shadow Ban Check" })
shadowBanRow:Left():TitleStack({
    Title = "Shadow Ban Check",
    Subtitle = "Check for hidden ban indicators.",
})
shadowBanRow:Right():Button({
    Label = "Check",
    State = "Primary",
    Pushed = function()
        task.spawn(function()
            local player = Services.Players.LocalPlayer
            local blacklistedValue = player:GetAttribute("Blacklisted")
            local exploiterValue = player:GetAttribute("Exploiter")
            local blacklisted = blacklistedValue == true
            local exploiter = exploiterValue == true
            local dataReceived = blacklistedValue ~= nil or exploiterValue ~= nil
            local lobbyArea = game.PlaceId == 13379208636
                or game.PlaceId == 14916516914
                or game.PlaceId == 14932214603
            local disabledReason
            local assets = Services.ReplicatedStorage:FindFirstChild("Assets")
            local remotes = assets and assets:FindFirstChild("Remotes")
            local getRemote = remotes and remotes:FindFirstChild("GET")

            if getRemote then
                local succeeded, response1, response2, response3 = pcall(function()
                    return getRemote:InvokeServer("Functions", "Settings", "Blur", "Off")
                end)

                if succeeded then
                    local responses = table.pack(response1, response2, response3)
                    local fallbackTable
                    for index = 1, responses.n do
                        local response = responses[index]
                        if type(response) == "table" then
                            fallbackTable = fallbackTable or response
                            if response.Current_Slot ~= nil or type(response.Slots) == "table"
                                or response.Disabled ~= nil then
                                fallbackTable = response
                                break
                            end
                        end
                    end

                    if fallbackTable then
                        dataReceived = true
                        disabledReason = fallbackTable.Disabled
                    end
                end
            end

            local disabled = disabledReason ~= nil and disabledReason ~= false and disabledReason ~= ""
            if blacklisted or exploiter or disabled then
                local reason = disabled and tostring(disabledReason) or "Blacklisted/Exploiter flag"
                showUtilityNotification("SHADOW BANNED", "You are shadow banned: " .. reason)
            elseif lobbyArea or dataReceived then
                showUtilityNotification("NOT SHADOW BANNED", "Check found no ban flag.")
            else
                showUtilityNotification("UNKNOWN", "Could not verify account status.")
            end
        end)
    end,
})

local returnLobbyRow = utilityForm:Row({ SearchIndex = "Return To Lobby" })
returnLobbyRow:Left():TitleStack({
    Title = "Return To Lobby",
    Subtitle = "Go to the Lobby or rejoin it if you are already there.",
})
returnLobbyRow:Right():Button({
    Label = "Go",
    State = "Primary",
    Pushed = function()
        task.spawn(function()
            if CombatFeatures.isCombatSession() then
                local sent, sendError = CombatFeatures.sendPost("Functions", "Teleport")
                if not sent then
                    showUtilityNotification("Return To Lobby", tostring(sendError))
                end
                return
            end

            local result = invokeActorFunction("Functions", "Teleport", "Lobby")
            if not result or not result.ok then
                showUtilityNotification("Return To Lobby", "Lobby teleport failed.")
            end
        end)
    end,
})

local returnMainMenuRow = utilityForm:Row({ SearchIndex = "Return To Main Menu" })
returnMainMenuRow:Left():TitleStack({
    Title = "Return To Main Menu",
    Subtitle = "Teleport to the Main Menu.",
})
returnMainMenuRow:Right():Button({
    Label = "Go",
    State = "Primary",
    Pushed = function()
        local succeeded, teleportError = pcall(function()
            Services.TeleportService:Teleport(13379208636, Services.Players.LocalPlayer)
        end)
        if not succeeded then
            showUtilityNotification("Return To Main Menu", tostring(teleportError))
        end
    end,
})
end)(window, App, cascade, Services, configRecorder)

