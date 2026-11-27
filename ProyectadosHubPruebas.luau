local coreGui = game:GetService("CoreGui")
local players = game:GetService("Players")
local localPlayer = players.LocalPlayer

local ACCEPTED_KEYS = {
    ["LosVaguens"] = true,
    ["Vaguens"] = true
}
local verified = false
local keyFileName = "LosVaguens_Key.txt"

local whitelistedPlayers = {
    ["juest20017"] = true,
    ["andreygamer014"] = true,
    ["JKK_000X"] = true,
    ["maicolinpinqu"] = true,
    ["hoal_mebanearonsoypa"] = true,
    ["CLK_DFF"] = true,
    ["xxxcrisgamerproxx"] = true,
}

local function cleanKey(str)
    return tostring(str or ""):match("^%s*(.-)%s*$")
end

-- 1. Verificar Whitelist (O(1) lookup)
if whitelistedPlayers[localPlayer.Name] then
    verified = true
end

-- 2. Verificar Key Guardada
if not verified then
    pcall(function()
        if isfile and readfile and isfile(keyFileName) then
            local savedKey = cleanKey(readfile(keyFileName))
            if ACCEPTED_KEYS[savedKey] then
                verified = true
            end
        end
    end)
end

-- 3. Mostrar Interfaz si no está verificado (Optimizado para Móviles)
if not verified then
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "Proyectados Hub"
    screenGui.Parent = coreGui or localPlayer.PlayerGui
    screenGui.ResetOnSpawn = false

    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0.85, 0, 0.6, 0)
    mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Draggable = true
    mainFrame.Parent = screenGui

    local sizeConstraint = Instance.new("UISizeConstraint")
    sizeConstraint.MaxSize = Vector2.new(380, 290)
    sizeConstraint.MinSize = Vector2.new(280, 220)
    sizeConstraint.Parent = mainFrame

    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0, 10)
    uiCorner.Parent = mainFrame

    local uiStroke = Instance.new("UIStroke")
    uiStroke.Color = Color3.fromRGB(138, 43, 226)
    uiStroke.Thickness = 2
    uiStroke.Parent = mainFrame

    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, 0, 0, 40)
    titleLabel.Position = UDim2.new(0, 0, 0, 15)
    titleLabel.Text = "PROYECTADOS HUB"
    titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextSize = 20
    titleLabel.Parent = mainFrame

    local subTitle = Instance.new("TextLabel")
    subTitle.Size = UDim2.new(1, 0, 0, 25)
    subTitle.Position = UDim2.new(0, 0, 0, 50)
    subTitle.Text = "Introduce La Key"
    subTitle.TextColor3 = Color3.fromRGB(180, 180, 180)
    subTitle.BackgroundTransparency = 1
    subTitle.Font = Enum.Font.Gotham
    subTitle.TextSize = 14
    subTitle.Parent = mainFrame

    local textBox = Instance.new("TextBox")
    textBox.Size = UDim2.new(0.85, 0, 0, 42)
    textBox.Position = UDim2.new(0.5, 0, 0.33, 0)
    textBox.AnchorPoint = Vector2.new(0.5, 0)
    textBox.PlaceholderText = "Escribe La Key aquí..."
    textBox.Text = ""
    textBox.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    textBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    textBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
    textBox.Font = Enum.Font.Gotham
    textBox.TextSize = 15
    textBox.Parent = mainFrame

    local tbCorner = Instance.new("UICorner")
    tbCorner.CornerRadius = UDim.new(0, 8)
    tbCorner.Parent = textBox

    local submitButton = Instance.new("TextButton")
    submitButton.Size = UDim2.new(0.85, 0, 0, 42)
    submitButton.Position = UDim2.new(0.5, 0, 0.53, 0)
    submitButton.AnchorPoint = Vector2.new(0.5, 0)
    submitButton.Text = "Verificar Key"
    submitButton.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
    submitButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    submitButton.Font = Enum.Font.GothamBold
    submitButton.TextSize = 15
    submitButton.Parent = mainFrame

    local btnCorner = Instance.new("UICorner")
    btnCorner.CornerRadius = UDim.new(0, 8)
    btnCorner.Parent = submitButton

    local getKeyButton = Instance.new("TextButton")
    getKeyButton.Size = UDim2.new(0.85, 0, 0, 42)
    getKeyButton.Position = UDim2.new(0.5, 0, 0.73, 0)
    getKeyButton.AnchorPoint = Vector2.new(0.5, 0)
    getKeyButton.Text = "OBTENER KEY"
    getKeyButton.BackgroundColor3 = Color3.fromRGB(138, 43, 226)
    getKeyButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    getKeyButton.Font = Enum.Font.GothamBold
    getKeyButton.TextSize = 14
    getKeyButton.Parent = mainFrame

    local getKeyCorner = Instance.new("UICorner")
    getKeyCorner.CornerRadius = UDim.new(0, 8)
    getKeyCorner.Parent = getKeyButton

    getKeyButton.MouseButton1Click:Connect(function()
        pcall(function()
            if setclipboard then
                setclipboard("https://link-center.net/10253076/q1AAl7og4pTF")
            end
        end)
        getKeyButton.Text = "Link copiado al portapapeles"
        task.wait(2)
        if getKeyButton and getKeyButton.Parent then
            getKeyButton.Text = "OBTENER KEY"
        end
    end)

    submitButton.MouseButton1Click:Connect(function()
        local inputKey = cleanKey(textBox.Text)
        if ACCEPTED_KEYS[inputKey] then
            verified = true
            pcall(function()
                if writefile then
                    writefile(keyFileName, inputKey)
                end
            end)
            screenGui:Destroy()
        else
            textBox.Text = ""
            textBox.PlaceholderText = "No Quieres Proyectarte?"
            textBox.PlaceholderColor3 = Color3.fromRGB(255, 80, 80)
        end
    end)

    task.spawn(function()
        task.wait(60)
        if not verified then
            pcall(function()
                localPlayer:Kick("No podrás Proyectarte junto Nosotros")
            end)
        end
    end)
end

while not verified do
    task.wait(0.1)
end

-- ==========================================
-- SCRIPT PRINCIPAL PROYECTADOS HUB (UI V3 TEST)
-- ==========================================
local services = {
    Players = players,
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    VirtualUser = game:GetService("VirtualUser"),
    Workspace = workspace,
    Lighting = game:GetService("Lighting"),
    UserInputService = game:GetService("UserInputService"),
    VirtualInputManager = game:GetService("VirtualInputManager"),
    RunService = game:GetService("RunService"),
    CollectionService = game:GetService("CollectionService"),
    HttpService = game:GetService("HttpService"),
    StarterGui = game:GetService("StarterGui"),
    MarketplaceService = game:GetService("MarketplaceService"),
    Stats = game:GetService("Stats"),
    GuiService = game:GetService("GuiService"),
    LinkingService = game:GetService("LinkingService"),
    TeleportService = game:GetService("TeleportService"),
    CoreGui = coreGui
}

local utils = {}
utils.runtime = {}

for _, connection in ipairs(_G.HorarybrechMainConnections or {}) do
    pcall(function() connection:Disconnect() end)
end
_G.HorarybrechMainConnections = {}
_G.HorarybrechMainGeneration = (_G.HorarybrechMainGeneration or 0) + 1
utils.Generation = _G.HorarybrechMainGeneration

function utils.isCurrent()
    return utils.Generation == _G.HorarybrechMainGeneration
end

function utils.connect(signal, callback)
    local connection = signal:Connect(callback)
    table.insert(_G.HorarybrechMainConnections, connection)
    return connection
end

local COLOR_ERROR = Color3.fromRGB(255, 80, 80)
local COLOR_OK = Color3.fromRGB(120, 255, 150)
local COLOR_WARN = Color3.fromRGB(255, 180, 70)
local COLOR_IDLE = Color3.fromRGB(200, 200, 200)

local function showErrorStatus(label, message)
    if not label then return end
    label.Text = "Error: " .. tostring(message)
    label.TextColor3 = COLOR_ERROR
    label.Visible = true
end

local function hideStatus(label)
    if not label then return end
    label.Text = ""
    label.Visible = false
end

local lp = {
    player = localPlayer,
    userid = localPlayer.UserId,
    username = localPlayer.Name,
    displayname = localPlayer.DisplayName
}

utils.playerData = {
    Player = lp.player,
    DisplayName = lp.displayname,
    Character = lp.player.Character,
    Humanoid = nil,
    Camera = services.Workspace.CurrentCamera,
    Backpack = lp.player:WaitForChild("Backpack")
}

utils.playerData.Humanoid = utils.playerData.Character and utils.playerData.Character:FindFirstChildOfClass("Humanoid")

local rEvents = services.ReplicatedStorage:WaitForChild("rEvents", 10)
utils.remotes = {
    ChangeSpeedSize = rEvents and rEvents:WaitForChild("changeSpeedSizeRemote"),
    MuscleEvent = lp.player:WaitForChild("muscleEvent"),
    QuestsEvent = rEvents and rEvents:FindFirstChild("questsEvent"),
    PetEvolution = rEvents and (rEvents:FindFirstChild("petEvolutionEvent") or rEvents:FindFirstChild("fusePetsEvent")),
    SellPetEvent = rEvents and rEvents:FindFirstChild("sellPetEvent"),
    MachineInteract = rEvents and rEvents:WaitForChild("machineInteractRemote"),
    GuiDamageEvent = rEvents and rEvents:FindFirstChild("guiDamageEvent"),
    EquipPetEvent = rEvents and rEvents:FindFirstChild("equipPetEvent"),
    RebirthRemote = rEvents and rEvents:FindFirstChild("rebirthRemote"),
    AreaTravelRemote = rEvents and rEvents:FindFirstChild("areaTravelRemote"),
    OpenCrystalRemote = rEvents and rEvents:FindFirstChild("openCrystalRemote"),
    OpenWheelRemote = rEvents and rEvents:FindFirstChild("openFortuneWheelRemote"),
    ShowPetsEvent = rEvents and rEvents:FindFirstChild("showPetsEvent")
}

local dataPingItem = nil
pcall(function()
    dataPingItem = services.Stats.Network.ServerStatsItem["Data Ping"]
end)

local function readDataPing()
    if dataPingItem then
        local success, ping = pcall(function()
            return dataPingItem:GetValue()
        end)
        if success and type(ping) == "number" and ping == ping and ping >= 0 and ping < math.huge then
            return ping
        end
    end
    local fallbackOk, netPing = pcall(function()
        return lp.player:GetNetworkPing() * 1000
    end)
    if fallbackOk and type(netPing) == "number" and netPing == netPing and netPing >= 0 and netPing < math.huge then
        return netPing
    end
    return nil
end

function utils.formatNumber(n)
    if n >= 1e18 then return string.format("%.1fqi", n / 1e18)
    elseif n >= 1e15 then return string.format("%.1fqa", n / 1e15)
    elseif n >= 1e12 then return string.format("%.1ft", n / 1e12)
    elseif n >= 1e9 then return string.format("%.1fb", n / 1e9)
    elseif n >= 1e6 then return string.format("%.1fm", n / 1e6)
    elseif n >= 1e3 then return string.format("%.1fk", n / 1e3)
    else return tostring(n) end
end

function utils.formatWithCommas(n, formatted, separatorCount)
    formatted = tostring(math.floor(n))
    while true do
        formatted, separatorCount = formatted:gsub("^(-?%d+)(%d%d%d)", "%1.%2")
        if separatorCount == 0 then break end
    end
    return formatted
end

function utils.deleteAds()
    local function cleanContainer(container)
        if not container then return end
        for _, obj in ipairs(container:GetDescendants()) do
            if obj.Name == "RobloxForwardPortals" then
                obj:Destroy()
            end
        end
    end
    cleanContainer(services.Workspace)
    cleanContainer(lp.player:FindFirstChild("PlayerGui"))

    if _G.ads then _G.ads:Disconnect() end
    _G.ads = services.Workspace.DescendantAdded:Connect(function(descendant)
        if descendant.Name == "RobloxForwardPortals" then
            descendant:Destroy()
        end
    end)
end
utils.deleteAds()

function deleteBodyMovementScript()
    if lp.player.Character and lp.player.Character:FindFirstChild("bodyMovementScript") then
        lp.player.Character.bodyMovementScript:Destroy()
    end
end
deleteBodyMovementScript()

function utils.tpE(pos)
    pcall(function()
        local char = lp.player.Character or lp.player.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")
        hrp.CFrame = CFrame.new(pos)
        hrp.AssemblyLinearVelocity = Vector3.zero
        task.wait(0.05)
        services.VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
        task.wait(0.02)
        services.VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
    end)
end

local function interactWithMachine(targetPos)
    pcall(function()
        local char = lp.player.Character or lp.player.CharacterAdded:Wait()
        local hrp = char:WaitForChild("HumanoidRootPart")
        local hum = char:WaitForChild("Humanoid")
        
        hrp.CFrame = CFrame.new(targetPos)
        hrp.AssemblyLinearVelocity = Vector3.zero
        task.wait(0.2)
        
        local machinesFolder = services.Workspace:FindFirstChild("machinesFolder")
        if machinesFolder then
            for _, machine in ipairs(machinesFolder:GetChildren()) do
                local seat = machine:FindFirstChild("interactSeat") or machine:FindFirstChild("Seat") or machine:FindFirstChild("Part")
                if seat and (seat.Position - targetPos).Magnitude < 15 then
                    pcall(function()
                        utils.remotes.MachineInteract:InvokeServer("interact", machine)
                    end)
                    break
                end
            end
        end
        
        local startTime = os.clock()
        while os.clock() - startTime < 2.5 and not hum.Sit do
            hrp.CFrame = CFrame.new(targetPos)
            services.VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
            task.wait(0.05)
            services.VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
            task.wait(0.15)
        end
    end)
end

function formatNumberSilence(num)
    if num >= 1e18 then return string.format("%.2fQi", num/1e18) end
    if num >= 1e15 then return string.format("%.2fQa", num/1e15) end
    if num >= 1e12 then return string.format("%.2fT", num/1e12) end
    if num >= 1e9 then return string.format("%.2fB", num/1e9) end
    if num >= 1e6 then return string.format("%.2fM", num/1e6) end
    if num >= 1e3 then return string.format("%.2fK", num/1e3) end
    return string.format("%.0f", num)
end

function formatRateSilence(ratePerSecond)
    return formatNumberSilence(ratePerSecond) .. "/s | "
        .. formatNumberSilence(ratePerSecond * 60) .. "/min | "
        .. formatNumberSilence(ratePerSecond * 3600) .. "/h | "
        .. formatNumberSilence(ratePerSecond * 86400) .. "/d | "
        .. formatNumberSilence(ratePerSecond * 604800) .. "/w"
end

local function createPrivacyRedactor(player, key)
    local redactor = {
        NameEnabled = false,
        StatsEnabled = false,
        OriginalNames = setmetatable({}, {__mode = "k"}),
        OriginalStats = setmetatable({}, {__mode = "k"}),
        TrackedLabels = setmetatable({}, {__mode = "k"})
    }
    _G.HorarybrechPrivacyGenerations = _G.HorarybrechPrivacyGenerations or {}
    _G.HorarybrechPrivacyGenerations[key] = (_G.HorarybrechPrivacyGenerations[key] or 0) + 1
    local generation = _G.HorarybrechPrivacyGenerations[key]

    local pName = player.Name
    local pDisplay = player.DisplayName

    local function containsName(text)
        return string.find(text, pName, 1, true) or string.find(text, pDisplay, 1, true)
    end

    local function redact(storage, object, replacement)
        local saved = storage[object]
        if not saved or object.Text ~= saved.Redacted then
            saved = {Original = object.Text}
            storage[object] = saved
        end
        saved.Redacted = replacement
        object.Text = replacement
    end

    local function registerGuiLabel(obj)
        if obj:IsA("TextLabel") or obj:IsA("TextButton") then
            redactor.TrackedLabels[obj] = true
        end
    end

    for _, obj in ipairs(services.CoreGui:GetDescendants()) do
        registerGuiLabel(obj)
    end
    utils.connect(services.CoreGui.DescendantAdded, registerGuiLabel)

    local function restore(storage, stillDisabled)
        local savedObjects = {}
        for object, saved in pairs(storage) do
            table.insert(savedObjects, {Object = object, Text = saved.Original})
        end
        table.clear(storage)
        task.spawn(function()
            for _ = 1, 3 do
                if not stillDisabled() or not utils.isCurrent() then return end
                for _, saved in ipairs(savedObjects) do
                    if saved.Object.Parent then saved.Object.Text = saved.Text end
                end
                task.wait(0.2)
            end
        end)
    end

    local function update()
        local character = player.Character
        if redactor.NameEnabled and character then
            local nameGui = character:FindFirstChild("nameGui", true)
            if nameGui and nameGui:IsA("BillboardGui") then nameGui.Enabled = false end
        end
        if redactor.StatsEnabled then
            for object in pairs(redactor.TrackedLabels) do
                if object.Parent and containsName(object.Text) then
                    redact(redactor.OriginalNames, object, "########")
                end
            end
        end
    end

    function redactor:SetNameEnabled(enabled)
        self.NameEnabled = enabled
        if not enabled then restore(self.OriginalNames, function() return not self.NameEnabled end) end
        pcall(update)
    end

    function redactor:SetStatsEnabled(enabled)
        self.StatsEnabled = enabled
        if not enabled then restore(self.OriginalStats, function() return not self.StatsEnabled end) end
        pcall(update)
    end

    task.spawn(function()
        while _G.HorarybrechPrivacyGenerations[key] == generation and utils.isCurrent() do
            if redactor.NameEnabled or redactor.StatsEnabled then pcall(update) end
            task.wait(4)
        end
    end)
    return redactor
end

-- ==========================================
-- INICIALIZACIÓN DE INTERFAZ Y SISTEMAS BASE (ProyectadosUiV3)
-- ==========================================
utils.library = loadstring(game:HttpGet("https://raw.githubusercontent.com/horarybrech/Hub/refs/heads/main/ProyectadosUiV3.luau?cache=" .. tostring(os.time()), true))()
utils.ProyectadosHub = utils.library:AddWindow("Proyectados Hub | Muscle Legends", {
    main_color = Color3.fromRGB(138, 43, 226),
    min_size = Vector2.new(700, 700),
    can_resize = true,
})

-- ANTI-AFK CON NOTIFICACIÓN
utils.connect(lp.player.Idled, function()
    services.VirtualUser:CaptureController()
    services.VirtualUser:ClickButton2(Vector2.new())
end)

pcall(function()
    services.StarterGui:SetCore("SendNotification", {
        Title = "Anti-AFK Activado",
        Text = "Hecho por Horarybrech",
        Button1 = "Gracias",
        Duration = 5
    })
end)

utils.connect(lp.player.CharacterAdded, function(character)
    utils.playerData.Character = character
    utils.playerData.Humanoid = character:WaitForChild("Humanoid", 10)
    utils.playerData.Backpack = lp.player:WaitForChild("Backpack")
end)

local tabs = {
    farming = utils.ProyectadosHub:AddTab("Farm"),
    fullFarm = utils.ProyectadosHub:AddTab("Fast"),
    fullRebirth = utils.ProyectadosHub:AddTab("Rebirth"),
    configs = utils.ProyectadosHub:AddTab("Config"),
    boss = utils.ProyectadosHub:AddTab("Boss"),
    alienEvent = utils.ProyectadosHub:AddTab("Alien Event"),
    clips = utils.ProyectadosHub:AddTab("Kill"),
    misiones = utils.ProyectadosHub:AddTab("Extras"),
    pets = utils.ProyectadosHub:AddTab("Pet Xp"),
    other = utils.ProyectadosHub:AddTab("Util"),
    info = utils.ProyectadosHub:AddTab("Info")
}

for _, tab in pairs(tabs) do
    tab.runtime = {}
end

tabs.other.RedactConfig = {RedactName = true, RedactStats = false}
tabs.other.redactStats = tabs.other.RedactConfig.RedactStats
local privacyRedactor = createPrivacyRedactor(lp.player, "Farming")

local function formatCurrentStat(value)
    return tabs.other.redactStats and "####" or formatNumberSilence(value)
end

-- ==========================================
-- TAB: FARM (ENTRENAMIENTO BÁSICO Y ROCAS)
-- ==========================================
tabs.farming:AddLabel("BASIC TRAINING")
tabs.farming.AutoLiftSpeed = 0.06
tabs.farming:AddTextBox("AutoLift Speed:", function(text)
    local num = tonumber(text)
    if num and num > 0 then tabs.farming.AutoLiftSpeed = num end
end, {clear = false})

tabs.farming.ExerciseData = { SelectedTool = "Weight", AutoFarm = false }
tabs.farming.ToolDropdown = tabs.farming:AddDropdown("Select Exercise", function(selection)
    tabs.farming.ExerciseData.SelectedTool = selection
end)
for _, tool in ipairs({"Weight", "Pushups", "Situps", "Handstands"}) do
    tabs.farming.ToolDropdown:Add(tool)
end

tabs.farming.AutoLiftActive = false
tabs.farming.AutoLiftSwitch = tabs.farming:AddSwitch("AutoLift", function(state)
    tabs.farming.AutoLiftActive = state
    if state then
        task.spawn(function()
            while tabs.farming.AutoLiftActive and utils.isCurrent() do
                pcall(function()
                    local char = lp.player.Character
                    local hum = char and char:FindFirstChildOfClass("Humanoid")
                    if char and hum and hum.Health > 0 then
                        local toolName = tabs.farming.ExerciseData.SelectedTool or "Weight"
                        local exerciseTool = char:FindFirstChild(toolName) or utils.playerData.Backpack:FindFirstChild(toolName)
                        if exerciseTool then
                            if exerciseTool.Parent ~= char then
                                hum:EquipTool(exerciseTool)
                                task.wait(0.02)
                            end
                            exerciseTool:Activate()
                            utils.remotes.MuscleEvent:FireServer("rep")
                        end
                    end
                end)
                task.wait(tabs.farming.AutoLiftSpeed)
            end
        end)
    end
end)

tabs.farming:AddSwitch("Free Auto Lift", function(state)
    lp.player:SetAttribute("AutoLiftEnabled", state)
end)

tabs.farming:AddLabel("ROCK FARMING")
tabs.farming.RockList = {
    { Label = "Tiny Rock - 0 Dura", ModelName = "Tiny Rock", Dura = 0 },
    { Label = "Punching Rock - 0 Dura", ModelName = "Punching Rock", Dura = 0 },
    { Label = "Large Rock - 100 Dura", ModelName = "Punching Rock", Dura = 100 },
    { Label = "Golden Rock - 5k Dura", ModelName = "Punching Rock", Dura = 5000 },
    { Label = "Frost Rock - 150k Dura", ModelName = "Frozen Rock", Dura = 150000 },
    { Label = "Mythical Rock - 400k Dura", ModelName = "Frozen Rock", Dura = 400000 },
    { Label = "Eternal Rock - 750k Dura", ModelName = "Inferno Rock", Dura = 750000 },
    { Label = "Legend Rock - 1m Dura", ModelName = "Rock Of Legends", Dura = 1000000 },
    { Label = "Muscle King Rock - 5m Dura", ModelName = "Muscle King Mountain", Dura = 5000000 },
    { Label = "Jungle Rock - 10m Dura", ModelName = "Ancient Jungle Rock", Dura = 10000000 },
    { Label = "Glacial Rock - 10m Dura", ModelName = "Glacial Rock", Dura = 10000000 },
    { Label = "Industrial Rock - 25m Dura", ModelName = "Industrial Rock", Dura = 25000000 }
}

tabs.farming.RockData = {
    Data = {},
    SelectedRock = nil
}

tabs.farming.RockDropdown = tabs.farming:AddDropdown("Select Rock", function(selection)
    tabs.farming.RockData.SelectedRock = selection
end)

for _, rockInfo in ipairs(tabs.farming.RockList) do
    tabs.farming.RockData.Data[rockInfo.Label] = rockInfo
    tabs.farming.RockDropdown:Add(rockInfo.Label)
end

tabs.farming.RockFarmToggle = tabs.farming:AddSwitch("Auto Rock", function(enabled)
    getgenv().RockFarmRunning = enabled
    if enabled then
        task.spawn(function()
            local cachedRock = nil
            local lastSelected = nil
            local durabilityObj = lp.player:WaitForChild("Durability")
            while utils.isCurrent() and getgenv().RockFarmRunning do
                local selected = tabs.farming.RockData.SelectedRock
                local rockInfo = selected and tabs.farming.RockData.Data[selected]
                if rockInfo then
                    if selected ~= lastSelected then
                        cachedRock = nil
                        lastSelected = selected
                    end
                    pcall(function()
                        if durabilityObj.Value >= rockInfo.Dura then
                            if not cachedRock or not cachedRock.Parent then
                                local machinesFolder = services.Workspace:FindFirstChild("machinesFolder")
                                if machinesFolder then
                                    for _, machine in ipairs(machinesFolder:GetChildren()) do
                                        local req = machine:FindFirstChild("neededDurability")
                                        local rockPart = machine:FindFirstChild("Rock")
                                        if req and rockPart and req.Value == rockInfo.Dura and machine.Name == rockInfo.ModelName then
                                            cachedRock = rockPart
                                            break
                                        end
                                    end
                                end
                            end

                            local char = lp.player.Character
                            local hum = char and char:FindFirstChildOfClass("Humanoid")
                            local bp = utils.playerData.Backpack
                            if cachedRock and char and hum and hum.Health > 0 then
                                local punch = char:FindFirstChild("Punch") or (bp and bp:FindFirstChild("Punch"))
                                if punch then
                                    if punch.Parent ~= char then
                                        hum:EquipTool(punch)
                                    end
                                    punch:Activate()
                                end
                                if utils.remotes.MuscleEvent then
                                    utils.remotes.MuscleEvent:FireServer("punch", "leftHand")
                                    utils.remotes.MuscleEvent:FireServer("punch", "rightHand")
                                end
                                local rightHand = char:FindFirstChild("RightHand")
                                local leftHand = char:FindFirstChild("LeftHand")
                                if leftHand and rightHand then
                                    firetouchinterest(cachedRock, rightHand, 0)
                                    firetouchinterest(cachedRock, rightHand, 1)
                                    firetouchinterest(cachedRock, leftHand, 0)
                                    firetouchinterest(cachedRock, leftHand, 1)
                                end
                            end
                        end
                    end)
                end
                task.wait(0.08)
            end
        end)
    end
end)

tabs.farming:AddLabel("CHARACTER")
tabs.farming.SizeData = {Active = false}
tabs.farming:AddSwitch("Auto Size 1", function(bool)
    tabs.farming.SizeData.Active = bool
    if bool then
        task.spawn(function()
            while utils.isCurrent() and tabs.farming.SizeData.Active do
                if lp.player.Character and utils.playerData.Humanoid and utils.remotes.ChangeSpeedSize then
                    pcall(utils.remotes.ChangeSpeedSize.InvokeServer, utils.remotes.ChangeSpeedSize, "changeSize", 1)
                end
                task.wait(1)
            end
        end)
    end
end):Set(false)

-- ==========================================
-- TAB: FAST 
-- ==========================================
tabs.fullFarm:AddLabel("REAL-TIME STATS")

tabs.fullFarm.leaderstats = lp.player:WaitForChild("leaderstats")
tabs.fullFarm.strength = tabs.fullFarm.leaderstats:WaitForChild("Strength")
tabs.fullFarm.durability = lp.player:WaitForChild("Durability")
tabs.fullFarm.running = false
tabs.fullFarm.adaptiveRunning = false
tabs.fullFarm.directRunning = false
tabs.fullFarm.directPausedByPing = false
tabs.fullFarm.directHighPingLimit = 5000
tabs.fullFarm.directResumePing = 500
tabs.fullFarm.switchingMode = false
tabs.fullFarm.hasError = false
tabs.fullFarm.workerGen = 0
tabs.fullFarm.startedAt = 0
tabs.fullFarm.totalElapsed = 0
tabs.fullFarm.timerStarted = false
tabs.fullFarm.gainedBaselineSet = false

tabs.fullFarm.statSamples = {Strength = tabs.fullFarm.strength.Value, Durability = tabs.fullFarm.durability.Value}
tabs.fullFarm.statGains = {Strength = 0, Durability = 0}
tabs.fullFarm.nextAverageElapsed = 5

tabs.fullFarm.initialSendRate = 200
tabs.fullFarm.maxSendRate = 400
tabs.fullFarm.sendRate = tabs.fullFarm.initialSendRate
tabs.fullFarm.maxBurst = 12
tabs.fullFarm.Tokens = 0
tabs.fullFarm.pingLimit = 400
tabs.fullFarm.resumePing = 300
tabs.fullFarm.recoverySeconds = 1.5
tabs.fullFarm.rampInterval = 1.5
tabs.fullFarm.rampStep = 20
tabs.fullFarm.minAdaptiveRate = 15
tabs.fullFarm.fineRampStep = 5
tabs.fullFarm.backoffStep = 25
tabs.fullFarm.learnedLimit = false
tabs.fullFarm.lastPingSampleAt = os.clock()
tabs.fullFarm.lastPingSample = nil
tabs.fullFarm.lastPingRise = 0
tabs.fullFarm.stableInterval = 30
tabs.fullFarm.stableStep = 5
tabs.fullFarm.stableSince = os.clock()
tabs.fullFarm.pingThrottled = false
tabs.fullFarm.lastReduceAt = os.clock()
tabs.fullFarm.lastRampAt = os.clock()
tabs.fullFarm.LastAt = os.clock()

tabs.fullFarm.Status = tabs.fullFarm:AddLabel("Status: Inactive | Speed: 0 rep/s | Ping: -- ms")
tabs.fullFarm.Status.TextColor3 = COLOR_IDLE
tabs.fullFarm.Runtime = tabs.fullFarm:AddLabel("Runtime: 0d 0h 0m 0s")
tabs.fullFarm.StrengthStats = tabs.fullFarm:AddLabel("Strength: " .. formatCurrentStat(tabs.fullFarm.strength.Value) .. " | Gained: 0")
tabs.fullFarm.DurabilityStats = tabs.fullFarm:AddLabel("Durability: " .. formatCurrentStat(tabs.fullFarm.durability.Value) .. " | Gained: 0")
tabs.fullFarm.StrengthAverage = tabs.fullFarm:AddLabel("Str Ø: --/s | --/min | --/h | --/d | --/w")
tabs.fullFarm.DurabilityAverage = tabs.fullFarm:AddLabel("Dura Ø: --/s | --/min | --/h | --/d | --/w")

tabs.fullFarm.updateStatus = function()
    if tabs.fullFarm.hasError then return end
    tabs.fullFarm.Status.Visible = true
    local ping = readDataPing()
    local pingStr = ping and (tostring(math.floor(ping)) .. " ms") or "-- ms"

    if tabs.fullFarm.adaptiveRunning then
        if tabs.fullFarm.pingThrottled then
            tabs.fullFarm.Status.TextColor3 = COLOR_WARN
            tabs.fullFarm.Status.Text = string.format("Status: Throttled (High Ping) | Speed: %d rep/s | Ping: %s", math.floor(tabs.fullFarm.sendRate), pingStr)
        else
            tabs.fullFarm.Status.TextColor3 = COLOR_OK
            tabs.fullFarm.Status.Text = string.format("Status: Adaptive | Speed: %d rep/s | Ping: %s", math.floor(tabs.fullFarm.sendRate), pingStr)
        end
    elseif tabs.fullFarm.directRunning then
        if tabs.fullFarm.directPausedByPing then
            tabs.fullFarm.Status.TextColor3 = Color3.fromRGB(255, 100, 100)
            tabs.fullFarm.Status.Text = string.format("Status: Paused (Ping >= 5k) | Speed: 0 rep/s | Ping: %s", pingStr)
        else
            tabs.fullFarm.Status.TextColor3 = COLOR_OK
            tabs.fullFarm.Status.Text = string.format("Status: Direct | Speed: %d rep/s | Ping: %s", math.floor(tabs.fullFarm.maxSendRate), pingStr)
        end
    else
        tabs.fullFarm.Status.TextColor3 = COLOR_IDLE
        tabs.fullFarm.Status.Text = string.format("Status: Inactive | Speed: 0 rep/s | Ping: %s", pingStr)
    end
end

tabs.fullFarm.setStatusError = function(message)
    tabs.fullFarm.hasError = true
    showErrorStatus(tabs.fullFarm.Status, message)
end

tabs.fullFarm.clearStatusError = function()
    tabs.fullFarm.hasError = false
    tabs.fullFarm.updateStatus()
end

tabs.fullFarm.updateStatus()

local function getElapsed(tab)
    return tab.totalElapsed + (tab.timerStarted and os.clock() - tab.startedAt or 0)
end

local function setTimerRunning(tab, enabled)
    tab.totalElapsed = getElapsed(tab)
    tab.startedAt = os.clock()
    tab.timerStarted = enabled
end

local function recordStatGain(tab, key, value)
    local previous = tab.statSamples[key]
    tab.statSamples[key] = value
    if tab.running and tab.timerStarted and previous then
        tab.statGains[key] = tab.statGains[key] + math.max(0, value - previous)
    end
end

local function resetCalculations(tab)
    tab.totalElapsed = 0
    tab.startedAt = os.clock()
    tab.timerStarted = tab.running and tab.timerStarted
    tab.nextAverageElapsed = 5
    for key in pairs(tab.statGains) do
        tab.statGains[key] = 0
    end
    tab.statSamples.Strength = tab.strength.Value
    tab.statSamples.Durability = tab.durability.Value
    tab.StrengthAverage.Text = "Str Ø: --/s | --/min | --/h | --/d | --/w"
    tab.DurabilityAverage.Text = "Dura Ø: --/s | --/min | --/h | --/d | --/w"
    tab.updateStats()
    tab.updateRuntime()
end

local function sendTrainingReps(state, rate, maxBurst, canSend)
    local muscleEvent = utils.remotes.MuscleEvent
    if not muscleEvent then
        tabs.fullFarm.setStatusError("muscleEvent no encontrado")
        return 0
    end

    local now = os.clock()
    local elapsed = math.clamp(now - (state.LastAt or now), 0, 0.05)
    state.LastAt = now
    local effectiveBurst = math.max(maxBurst, math.ceil(rate / 30))
    state.Tokens = math.min(effectiveBurst, (state.Tokens or 0) + rate * elapsed)
    local sent = 0
    while state.Tokens >= 1 and canSend() do
        local ok, err = pcall(muscleEvent.FireServer, muscleEvent, "rep")
        if not ok then
            tabs.fullFarm.setStatusError("Fallo al enviar rep (" .. tostring(err) .. ")")
            break
        end
        state.Tokens = state.Tokens - 1
        sent = sent + 1
    end
    return sent
end

tabs.fullFarm.updateRuntime = function()
    local elapsed = getElapsed(tabs.fullFarm)
    tabs.fullFarm.Runtime.Text = string.format("Runtime: %dd %dh %dm %ds",
        math.floor(elapsed / 86400), math.floor((elapsed % 86400) / 3600),
        math.floor((elapsed % 3600) / 60), math.floor(elapsed % 60))
end

tabs.fullFarm.updateStats = function()
    local isPreparing = tabs.fullFarm.running and not tabs.fullFarm.timerStarted and not tabs.fullFarm.directPausedByPing
    tabs.fullFarm.StrengthStats.Text = "Strength: " .. formatCurrentStat(tabs.fullFarm.strength.Value)
        .. " | Gained: " .. (isPreparing and "Preparing" or formatNumberSilence(tabs.fullFarm.statGains.Strength))
    tabs.fullFarm.DurabilityStats.Text = "Durability: " .. formatCurrentStat(tabs.fullFarm.durability.Value)
        .. " | Gained: " .. (isPreparing and "Preparing" or formatNumberSilence(tabs.fullFarm.statGains.Durability))
end

tabs.fullFarm.updateAverage = function()
    local elapsed = getElapsed(tabs.fullFarm)
    if elapsed <= 0 then return end
    tabs.fullFarm.StrengthAverage.Text = "Str Ø: " .. formatRateSilence(tabs.fullFarm.statGains.Strength / elapsed)
    tabs.fullFarm.DurabilityAverage.Text = "Dura Ø: " .. formatRateSilence(tabs.fullFarm.statGains.Durability / elapsed)
end

tabs.fullFarm:AddButton("Reset Calcs", function()
    resetCalculations(tabs.fullFarm)
end)

tabs.fullFarm.startMeasurement = function()
    if not tabs.fullFarm.running or tabs.fullFarm.timerStarted then return end
    tabs.fullFarm.statSamples.Strength = tabs.fullFarm.strength.Value
    tabs.fullFarm.statSamples.Durability = tabs.fullFarm.durability.Value
    setTimerRunning(tabs.fullFarm, true)
    tabs.fullFarm.nextAverageElapsed = getElapsed(tabs.fullFarm) + 5
    tabs.fullFarm.updateStats()
end

tabs.fullFarm.updateAdaptiveRate = function()
    local tab = tabs.fullFarm
    local now = os.clock()
    local ping = readDataPing()
    local minRate = math.min(tab.minAdaptiveRate, tab.maxSendRate)
    tab.sendRate = math.clamp(tab.sendRate, minRate, tab.maxSendRate)
    
    if not ping then
        tab.pingThrottled = false
        return
    end

    if now - tab.lastPingSampleAt >= 0.5 then
        tab.lastPingRise = tab.lastPingSample and (ping - tab.lastPingSample) or 0
        tab.lastPingSample = ping
        tab.lastPingSampleAt = now
    end
    
    if ping > tab.pingLimit then
        if not tab.pingThrottled or (now - (tab.lastReduceAt or 0) >= 0.4) then
            local drop = math.max(tab.backoffStep, math.floor(tab.sendRate * 0.2))
            tab.sendRate = math.max(minRate, tab.sendRate - drop)
            tab.Tokens = math.min(tab.Tokens, 1)
            tab.lastReduceAt = now
            tab.learnedLimit = true
        end
        tab.pingThrottled = true
        tab.stableSince = now
        tab.recoveryStartedAt = nil
    elseif tab.pingThrottled then
        if ping <= tab.resumePing then
            tab.recoveryStartedAt = tab.recoveryStartedAt or now
            if now - tab.recoveryStartedAt >= tab.recoverySeconds then
                tab.pingThrottled = false
                tab.recoveryStartedAt = nil
                tab.lastRampAt = now
                tab.stableSince = now
                tab.lastPingSample = ping
                tab.lastPingRise = 0
            end
        else
            tab.recoveryStartedAt = nil
        end
    elseif now - tab.lastRampAt >= tab.rampInterval then
        local pressure = ping >= tab.resumePing or (ping >= 180 and tab.lastPingRise >= 25)
        if pressure then
            tab.sendRate = math.max(minRate, tab.sendRate - tab.backoffStep)
            tab.learnedLimit = true
            tab.stableSince = now
        elseif tab.sendRate < tab.maxSendRate then
            local step = tab.learnedLimit and tab.fineRampStep or tab.rampStep
            tab.sendRate = math.min(tab.maxSendRate, tab.sendRate + step)
            tab.stableSince = now
        end
        tab.lastRampAt = now
    end
end

tabs.fullFarm.workerLoop = function(gen)
    tabs.fullFarm.LastAt = os.clock()
    local heartbeat = services.RunService.Heartbeat
    local function isRunning()
        return tabs.fullFarm.running and tabs.fullFarm.adaptiveRunning and tabs.fullFarm.workerGen == gen and utils.isCurrent()
    end
    while isRunning() do
        tabs.fullFarm.updateAdaptiveRate()
        tabs.fullFarm.updateStatus()
        tabs.fullFarm.startMeasurement()
        sendTrainingReps(tabs.fullFarm, tabs.fullFarm.sendRate, tabs.fullFarm.maxBurst, isRunning)
        heartbeat:Wait()
    end
end

tabs.fullFarm.startWorker = function()
    tabs.fullFarm.workerGen = tabs.fullFarm.workerGen + 1
    local gen = tabs.fullFarm.workerGen
    task.spawn(function()
        tabs.fullFarm.workerLoop(gen)
    end)
end

tabs.fullFarm.workerLoopDirect = function(gen)
    tabs.fullFarm.LastAt = os.clock()
    tabs.fullFarm.directPausedByPing = false
    local heartbeat = services.RunService.Heartbeat
    local function isRunning()
        return tabs.fullFarm.running
            and tabs.fullFarm.directRunning
            and not tabs.fullFarm.directPausedByPing
            and tabs.fullFarm.workerGen == gen
            and utils.isCurrent()
    end
    while tabs.fullFarm.running and tabs.fullFarm.directRunning and tabs.fullFarm.workerGen == gen and utils.isCurrent() do
        local ping = readDataPing()
        if ping then
            if not tabs.fullFarm.directPausedByPing and ping >= tabs.fullFarm.directHighPingLimit then
                tabs.fullFarm.directPausedByPing = true
                tabs.fullFarm.Tokens = 0
                setTimerRunning(tabs.fullFarm, false)
                tabs.fullFarm.updateStats()
            elseif tabs.fullFarm.directPausedByPing and ping <= tabs.fullFarm.directResumePing then
                tabs.fullFarm.directPausedByPing = false
                tabs.fullFarm.Tokens = 0
                tabs.fullFarm.LastAt = os.clock()
            end
        end

        tabs.fullFarm.updateStatus()

        if not tabs.fullFarm.directPausedByPing then
            tabs.fullFarm.startMeasurement()
            sendTrainingReps(tabs.fullFarm, tabs.fullFarm.maxSendRate, tabs.fullFarm.maxBurst, isRunning)
        end

        heartbeat:Wait()
    end
end

tabs.fullFarm.startDirectWorker = function()
    tabs.fullFarm.workerGen = tabs.fullFarm.workerGen + 1
    local gen = tabs.fullFarm.workerGen
    task.spawn(function()
        tabs.fullFarm.workerLoopDirect(gen)
    end)
end

utils.connect(tabs.fullFarm.strength:GetPropertyChangedSignal("Value"), function()
    recordStatGain(tabs.fullFarm, "Strength", tabs.fullFarm.strength.Value)
    tabs.fullFarm.updateStats()
end)

utils.connect(tabs.fullFarm.durability:GetPropertyChangedSignal("Value"), function()
    recordStatGain(tabs.fullFarm, "Durability", tabs.fullFarm.durability.Value)
    tabs.fullFarm.updateStats()
end)

tabs.fullFarm:AddLabel("FARM CONTROLS")
tabs.fullFarm:AddTextBox("Max reps/s (Def: 400): ", function(inputText)
    if inputText == "" then
        tabs.fullFarm.clearStatusError()
        return
    end
    local value = tonumber(inputText)
    if not value or value <= 0 or value == math.huge or value == -math.huge then
        tabs.fullFarm.setStatusError("Max reps/s inválido")
        return
    end
    value = math.max(1, value)
    tabs.fullFarm.maxSendRate = value
    tabs.fullFarm.sendRate = math.min(tabs.fullFarm.sendRate, tabs.fullFarm.maxSendRate)
    tabs.fullFarm.clearStatusError()
end, {clear = false})

tabs.fullFarm:AddLabel("Auto Adaptive Ping Speed System is Active.")

tabs.fullFarm.FastRepToggle = tabs.fullFarm:AddSwitch("Fast Rep (Adaptive)", function(state)
    tabs.fullFarm.adaptiveRunning = state
    if state then
        tabs.fullFarm.directPausedByPing = false
        if tabs.fullFarm.directRunning and tabs.fullFarm.FastRepDirectToggle then
            tabs.fullFarm.switchingMode = true
            tabs.fullFarm.FastRepDirectToggle:Set(false)
            tabs.fullFarm.switchingMode = false
        end
        recordStatGain(tabs.fullFarm, "Strength", tabs.fullFarm.strength.Value)
        recordStatGain(tabs.fullFarm, "Durability", tabs.fullFarm.durability.Value)
        setTimerRunning(tabs.fullFarm, false)
        tabs.fullFarm.statSamples.Strength = tabs.fullFarm.strength.Value
        tabs.fullFarm.statSamples.Durability = tabs.fullFarm.durability.Value
        tabs.fullFarm.running = true
        tabs.fullFarm.Tokens = 0
        tabs.fullFarm.gainedBaselineSet = true
        tabs.fullFarm.maxSendRate = tabs.fullFarm.maxSendRate or 400
        tabs.fullFarm.learnedLimit = false
        tabs.fullFarm.lastPingSampleAt = os.clock()
        tabs.fullFarm.lastPingSample = nil
        tabs.fullFarm.lastPingRise = 0
        tabs.fullFarm.sendRate = math.min(tabs.fullFarm.initialSendRate, tabs.fullFarm.maxSendRate)
        tabs.fullFarm.pingThrottled = false
        tabs.fullFarm.lastReduceAt = os.clock()
        tabs.fullFarm.recoveryStartedAt = nil
        tabs.fullFarm.LastAt = os.clock()
        tabs.fullFarm.lastRampAt = os.clock()
        tabs.fullFarm.stableSince = os.clock()
        tabs.fullFarm.clearStatusError()
        tabs.fullFarm.startWorker()
    else
        if not tabs.fullFarm.switchingMode then
            recordStatGain(tabs.fullFarm, "Strength", tabs.fullFarm.strength.Value)
            recordStatGain(tabs.fullFarm, "Durability", tabs.fullFarm.durability.Value)
            setTimerRunning(tabs.fullFarm, false)
            tabs.fullFarm.running = false
            tabs.fullFarm.Tokens = 0
            tabs.fullFarm.workerGen = tabs.fullFarm.workerGen + 1
            tabs.fullFarm.clearStatusError()
            tabs.fullFarm.updateRuntime()
        end
    end
    tabs.fullFarm.updateStats()
    tabs.fullFarm.updateStatus()
end)
tabs.fullFarm.FastRepToggle:Set(false)

tabs.fullFarm.FastRepDirectToggle = tabs.fullFarm:AddSwitch("Fast Rep (Direct)", function(state)
    tabs.fullFarm.directRunning = state
    if state then
        tabs.fullFarm.directPausedByPing = false
        if tabs.fullFarm.adaptiveRunning and tabs.fullFarm.FastRepToggle then
            tabs.fullFarm.switchingMode = true
            tabs.fullFarm.FastRepToggle:Set(false)
            tabs.fullFarm.switchingMode = false
        end
        recordStatGain(tabs.fullFarm, "Strength", tabs.fullFarm.strength.Value)
        recordStatGain(tabs.fullFarm, "Durability", tabs.fullFarm.durability.Value)
        setTimerRunning(tabs.fullFarm, false)
        tabs.fullFarm.statSamples.Strength = tabs.fullFarm.strength.Value
        tabs.fullFarm.statSamples.Durability = tabs.fullFarm.durability.Value
        tabs.fullFarm.running = true
        tabs.fullFarm.Tokens = 0
        tabs.fullFarm.pingThrottled = false
        tabs.fullFarm.gainedBaselineSet = true
        tabs.fullFarm.maxSendRate = tabs.fullFarm.maxSendRate or 400
        tabs.fullFarm.LastAt = os.clock()
        tabs.fullFarm.clearStatusError()
        tabs.fullFarm.startDirectWorker()
    else
        tabs.fullFarm.directPausedByPing = false
        if not tabs.fullFarm.switchingMode then
            recordStatGain(tabs.fullFarm, "Strength", tabs.fullFarm.strength.Value)
            recordStatGain(tabs.fullFarm, "Durability", tabs.fullFarm.durability.Value)
            setTimerRunning(tabs.fullFarm, false)
            tabs.fullFarm.running = false
            tabs.fullFarm.Tokens = 0
            tabs.fullFarm.workerGen = tabs.fullFarm.workerGen + 1
            tabs.fullFarm.clearStatusError()
            tabs.fullFarm.updateRuntime()
        end
    end
    tabs.fullFarm.updateStats()
    tabs.fullFarm.updateStatus()
end)
tabs.fullFarm.FastRepDirectToggle:Set(false)

task.spawn(function()
    while utils.isCurrent() do
        if tabs.fullFarm.running or tabs.fullFarm.timerStarted then
            tabs.fullFarm.updateRuntime()
        end
        if not tabs.fullFarm.running then
            tabs.fullFarm.updateStatus()
        end
        if tabs.fullFarm.timerStarted and getElapsed(tabs.fullFarm) >= tabs.fullFarm.nextAverageElapsed then
            tabs.fullFarm.updateAverage()
            tabs.fullFarm.nextAverageElapsed = getElapsed(tabs.fullFarm) + 5
        end
        task.wait(0.25)
    end
end)

-- ==========================================
-- TAB: REBIRTH 
-- ==========================================
tabs.fullRebirth.FastRebirthV2Data = {
    Running = false,
    WorkerActive = false,
    Rebirths = lp.player.leaderstats:WaitForChild("Rebirths"),
    Strength = lp.player.leaderstats:WaitForChild("Strength"),
    UseFarmPets = true,
    UsePackPets = true,
    UseGolems = true
}

tabs.fullRebirth.Tracker = {
    Active = false,
    TargetRebirths = 0,
    StartRebirths = 0,
    StartTime = 0
}

tabs.fullRebirth:AddLabel("GOALS")
tabs.fullRebirth:AddTextBox("Target Rebirths:", function(val)
    local num = tonumber(val)
    if num then 
        tabs.fullRebirth.Tracker.TargetRebirths = math.floor(num)
    end
end, {clear = false})

tabs.fullRebirth:AddLabel("SETTINGS")
local trackerSwitchRef = tabs.fullRebirth:AddSwitch("Enable Calculator", function(state)
    tabs.fullRebirth.Tracker.Active = state
    if state then
        tabs.fullRebirth.Tracker.StartRebirths = tabs.fullRebirth.FastRebirthV2Data.Rebirths.Value
        tabs.fullRebirth.Tracker.StartTime = tick()
        
        tabs.fullRebirth.AvgTimeLabel.Text = "Pace: Calculating..."
        tabs.fullRebirth.RateLabel.Text = "Rate: --/h | --/d | --/w"
        tabs.fullRebirth.EtaLabel.Text = "ETA: Calculating..."
    else
        tabs.fullRebirth.AvgTimeLabel.Text = "Pace: Inactive"
        tabs.fullRebirth.RateLabel.Text = "Rate: --/h | --/d | --/w"
        tabs.fullRebirth.EtaLabel.Text = "ETA: 0d 0h 0m 0s"
    end
end)
trackerSwitchRef:Set(false)

tabs.fullRebirth:AddSwitch("Use Farm Pets", function(state) tabs.fullRebirth.FastRebirthV2Data.UseFarmPets = state end):Set(true)
tabs.fullRebirth:AddSwitch("Use Rebirth Pets", function(state) tabs.fullRebirth.FastRebirthV2Data.UsePackPets = state end):Set(true)
tabs.fullRebirth:AddSwitch("Use Combat Pets", function(state) tabs.fullRebirth.FastRebirthV2Data.UseGolems = state end):Set(true)

tabs.fullRebirth:AddLabel("STATS")
tabs.fullRebirth.FastRebirthV2Status = tabs.fullRebirth:AddLabel("")
hideStatus(tabs.fullRebirth.FastRebirthV2Status)
tabs.fullRebirth.FastRebirthV2Stats = tabs.fullRebirth:AddLabel("Rebirths: 0 | Gained: 0")
tabs.fullRebirth.MissingLabel = tabs.fullRebirth:AddLabel("Missing: 0")
tabs.fullRebirth.AvgTimeLabel = tabs.fullRebirth:AddLabel("Pace: Inactive")
tabs.fullRebirth.RateLabel = tabs.fullRebirth:AddLabel("Rate: --/h | --/d | --/w")
tabs.fullRebirth.EtaLabel = tabs.fullRebirth:AddLabel("ETA: 0d 0h 0m 0s")
tabs.fullRebirth.EtaLabel.TextColor3 = Color3.fromRGB(80, 255, 120)

local autoRebirthToggleRef = nil

task.spawn(function()
    local rebirthsVal = tabs.fullRebirth.FastRebirthV2Data.Rebirths
    while utils.isCurrent() do
        local currentRebirths = rebirthsVal.Value
        
        if tabs.fullRebirth.Tracker.Active then
            local totalGained = currentRebirths - tabs.fullRebirth.Tracker.StartRebirths
            tabs.fullRebirth.FastRebirthV2Stats.Text = "Rebirths: " .. utils.formatWithCommas(currentRebirths) .. " | Gained: " .. utils.formatWithCommas(totalGained)

            if totalGained > 0 then
                local now = tick()
                local secElapsed = now - tabs.fullRebirth.Tracker.StartTime
                local avgSecPerRb = secElapsed / totalGained
                local rbPerSec = totalGained / secElapsed
                
                tabs.fullRebirth.AvgTimeLabel.Text = string.format("Pace: %.2f s/rebirth", avgSecPerRb)
                tabs.fullRebirth.RateLabel.Text = string.format("Rate: %s/h | %s/d | %s/w",
                    formatNumberSilence(rbPerSec * 3600),
                    formatNumberSilence(rbPerSec * 86400),
                    formatNumberSilence(rbPerSec * 604800)
                )
                
                if tabs.fullRebirth.Tracker.TargetRebirths > 0 then
                    local missing = math.max(0, tabs.fullRebirth.Tracker.TargetRebirths - currentRebirths)
                    tabs.fullRebirth.MissingLabel.Text = "Missing: " .. utils.formatWithCommas(missing)
                    
                    local etaSec = missing * avgSecPerRb
                    tabs.fullRebirth.EtaLabel.Text = string.format("ETA: %dd %dh %dm %ds", math.floor(etaSec / 86400), math.floor((etaSec % 86400) / 3600), math.floor((etaSec % 3600) / 60), math.floor(etaSec % 60))
                    
                    if currentRebirths >= tabs.fullRebirth.Tracker.TargetRebirths and tabs.fullRebirth.FastRebirthV2Data.Running then
                        if autoRebirthToggleRef and autoRebirthToggleRef.Set then
                            autoRebirthToggleRef:Set(false)
                        end
                    end
                else
                    tabs.fullRebirth.MissingLabel.Text = "Missing: Infinite"
                    tabs.fullRebirth.EtaLabel.Text = "ETA: 0d 0h 0m 0s"
                end
            end
        else
            tabs.fullRebirth.FastRebirthV2Stats.Text = "Rebirths: " .. utils.formatWithCommas(currentRebirths) .. " | Gained: 0"
        end
        task.wait(0.5)
    end
end)

tabs.fullRebirth.PetDatabase = {
    ["Omega Overlord"] = { speed = 20, str = 0, reb = 0 },
    ["Swift Samurai"] = { speed = 15, str = 0, reb = 0 },
    ["Titanium Hydra"] = { speed = 0, str = 0, reb = 2 },
    ["Tribal Overlord"] = { speed = 0, str = 0, reb = 2 },
    ["Powercore Hound"] = { speed = 0, str = 25, reb = 0 },
    ["Mighty Monster"] = { speed = 0, str = 30, reb = 0 },
    ["Wild Wizard"] = { speed = 0, str = 20, reb = 0 },
    ["Chaos Sorcerer"] = { speed = 0, str = 15, reb = 0 },
    ["Mythic Boss Pet"] = { speed = 10, str = 20, reb = 0 },
    ["Legendary Boss Pet"] = { speed = 10, str = 10, reb = 0 },
    ["Rainbow Boss Pet"] = { speed = 10, str = 7, reb = 0 },
    ["Epic Boss Pet"] = { speed = 10, str = 0, reb = 0 },
    ["Rare Boss Pet"] = { speed = 7, str = 0, reb = 0 },
    ["Common Boss Pet"] = { speed = 5, str = 0, reb = 0 },
    ["Inferno Unicorn"] = { speed = 0, str = 25, reb = 0 },
    ["Inferno Drake"] = { speed = 40, str = 0, reb = 0 }
}

tabs.fullRebirth.equipDynamicPets = function(mode, maxPets)
    maxPets = maxPets or 12
    local ownedPets = {}
    local petsFolder = lp.player:FindFirstChild("petsFolder")
    if not petsFolder then
        error("petsFolder no encontrado")
    end
    
    local db = tabs.fullRebirth.PetDatabase
    local equipEvent = utils.remotes.EquipPetEvent or (rEvents and rEvents:FindFirstChild("equipPetEvent"))

    for _, folder in ipairs(petsFolder:GetChildren()) do
        if folder:IsA("Folder") then
            for _, pet in ipairs(folder:GetChildren()) do
                local stats = db[pet.Name]
                if stats then
                    table.insert(ownedPets, { instance = pet, stats = stats })
                end
            end
        end
    end

    if mode == "Farm" then
        table.sort(ownedPets, function(a, b)
            if a.stats.speed == b.stats.speed then return a.stats.str > b.stats.str end
            return a.stats.speed > b.stats.speed
        end)
    elseif mode == "Rebirth" then
        table.sort(ownedPets, function(a, b) return a.stats.reb > b.stats.reb end)
    elseif mode == "Combat" then
        table.sort(ownedPets, function(a, b) return a.stats.str > b.stats.str end)
    end

    if equipEvent then
        for _, folder in ipairs(petsFolder:GetChildren()) do
            if folder:IsA("Folder") and folder.Name ~= "Unique" then
                for _, pet in ipairs(folder:GetChildren()) do
                    pcall(equipEvent.FireServer, equipEvent, "unequipPet", pet)
                end
            end
        end
        task.wait(0.05)

        local equipped = 0
        for _, petData in ipairs(ownedPets) do
            if equipped >= maxPets then break end
            pcall(equipEvent.FireServer, equipEvent, "equipPet", petData.instance)
            equipped = equipped + 1
            task.wait(0.02)
        end
    end
end

tabs.fullRebirth.FastRebirthV2Worker = function()
    local data = tabs.fullRebirth.FastRebirthV2Data
    local heartbeat = services.RunService.Heartbeat
    local rebirthRemote = utils.remotes.RebirthRemote or (rEvents and rEvents:FindFirstChild("rebirthRemote"))
    
    while utils.isCurrent() and data.Running do
        if tabs.fullRebirth.Tracker.TargetRebirths > 0 and data.Rebirths.Value >= tabs.fullRebirth.Tracker.TargetRebirths then
            data.Running = false
            break
        end
        
        if data.UseFarmPets then
            local ok, err = pcall(tabs.fullRebirth.equipDynamicPets, "Farm", 12)
            if not ok then
                showErrorStatus(tabs.fullRebirth.FastRebirthV2Status, tostring(err))
            end
            task.wait(0.2)
        end
        
        local currentRebirths = data.Rebirths.Value
        local targetStrength = 5000 + currentRebirths * 2550
        local repsPerBurst = lp.player.MembershipType == Enum.MembershipType.Premium and 6 or 12
        
        while utils.isCurrent() and data.Running and data.Strength.Value < targetStrength do
            if not (tabs.fullFarm and tabs.fullFarm.running) then
                local muscleEvent = utils.remotes.MuscleEvent
                if not muscleEvent then
                    showErrorStatus(tabs.fullRebirth.FastRebirthV2Status, "muscleEvent no encontrado")
                    break
                end
                for _ = 1, repsPerBurst do
                    local ok, err = pcall(muscleEvent.FireServer, muscleEvent, "rep")
                    if not ok then
                        showErrorStatus(tabs.fullRebirth.FastRebirthV2Status, "Fallo al farmear (" .. tostring(err) .. ")")
                        break
                    end
                end
            end
            heartbeat:Wait()
        end
        
        if utils.isCurrent() and data.Running and data.Strength.Value >= targetStrength then
            if data.UsePackPets then
                local ok, err = pcall(tabs.fullRebirth.equipDynamicPets, "Rebirth", 12)
                if not ok then
                    showErrorStatus(tabs.fullRebirth.FastRebirthV2Status, tostring(err))
                end
                task.wait(0.3)
            end
            
            if rebirthRemote then
                local okReb, errReb = pcall(rebirthRemote.InvokeServer, rebirthRemote, "rebirthRequest")
                if not okReb then
                    showErrorStatus(tabs.fullRebirth.FastRebirthV2Status, "Fallo en rebirthRemote (" .. tostring(errReb) .. ")")
                end
            end
            task.wait(0.15)
            
            if data.UseGolems then
                local ok, err = pcall(tabs.fullRebirth.equipDynamicPets, "Combat", 12)
                if not ok then
                    showErrorStatus(tabs.fullRebirth.FastRebirthV2Status, tostring(err))
                end
                task.wait(0.2)
            end
        end
    end
    data.WorkerActive = false
end

tabs.fullRebirth:AddLabel("CONTROL")
autoRebirthToggleRef = tabs.fullRebirth:AddSwitch("Auto Rebirth", function(state)
    tabs.fullRebirth.FastRebirthV2Data.Running = state
    if state then
        hideStatus(tabs.fullRebirth.FastRebirthV2Status)
        if not tabs.fullRebirth.Tracker.Active and trackerSwitchRef and trackerSwitchRef.Set then
            trackerSwitchRef:Set(true)
        end
        if not tabs.fullRebirth.FastRebirthV2Data.WorkerActive then
            tabs.fullRebirth.FastRebirthV2Data.WorkerActive = true
            task.spawn(tabs.fullRebirth.FastRebirthV2Worker)
        end
    else
        hideStatus(tabs.fullRebirth.FastRebirthV2Status)
    end
end)

-- ==========================================
-- TAB: CONFIG (ZONAS Y MAQUINAS)
-- ==========================================
tabs.configs:AddLabel("MUSCLE KING ZONE")
tabs.configs.KingData = {TargetPosition = CFrame.new(-8749, 124, -5861), TeleportActive = false}

local kingSwitchRef = nil

kingSwitchRef = tabs.configs:AddSwitch("Auto Farm Muscle King", function(state)
    tabs.configs.KingData.TeleportActive = state
    if state then
        tabs.farming.ExerciseData.SelectedTool = "Weight"
        task.spawn(function()
            local targetCf = tabs.configs.KingData.TargetPosition
            local targetPos = targetCf.Position
            while utils.isCurrent() and tabs.configs.KingData.TeleportActive do
                pcall(function()
                    local char = lp.player.Character
                    local hrp = char and char:FindFirstChild("HumanoidRootPart")
                    if hrp and (hrp.Position - targetPos).Magnitude > 5 then
                        hrp.CFrame = targetCf
                        hrp.AssemblyLinearVelocity = Vector3.zero
                    end
                end)
                task.wait(0.5)
            end
        end)
    end
    if tabs.farming and tabs.farming.AutoLiftSwitch then
        tabs.farming.AutoLiftSwitch:Set(state)
    end
end):Set(false)

tabs.configs:AddLabel("SNOW ZONE")
tabs.configs.SnowLiftActive = false
tabs.configs.SnowConnection = nil
tabs.configs.SnowSquatLoopActive = false
tabs.configs.SnowSquatConnection = nil

local function travelToSnowGym()
    utils.tpE(Vector3.new(312, 19, 368))
    task.wait(0.15)
    local areaCircles = services.Workspace:WaitForChild("areaCircles")
    local zeroCircle = areaCircles:WaitForChild("zeroDegreesGymCircle")
    local areaRemote = utils.remotes.AreaTravelRemote or (rEvents and rEvents:WaitForChild("areaTravelRemote"))
    if areaRemote then
        areaRemote:InvokeServer("travelToArea", zeroCircle)
    end
end

local function setupSnowRespawn(pos, isSquat)
    local connKey = isSquat and "SnowSquatConnection" or "SnowConnection"
    if tabs.configs[connKey] then
        tabs.configs[connKey]:Disconnect()
        tabs.configs[connKey] = nil
    end
    
    tabs.configs[connKey] = lp.player.CharacterAdded:Connect(function()
        local activeCheck = isSquat and tabs.configs.SnowSquatLoopActive or tabs.configs.SnowLiftActive
        if not activeCheck or not utils.isCurrent() then return end
        task.wait(0.5)
        pcall(function()
            travelToSnowGym()
            task.wait(0.4)
            interactWithMachine(pos)
        end)
    end)
end

local function isMachineOccupied(targetPos)
    local occupied = false
    pcall(function()
        local machinesFolder = services.Workspace:FindFirstChild("machinesFolder")
        if not machinesFolder then return end
        for _, machine in ipairs(machinesFolder:GetChildren()) do
            local seat = machine:FindFirstChild("interactSeat") or machine:FindFirstChild("Seat") or machine:FindFirstChild("Part")
            if seat and (seat.Position - targetPos).Magnitude < 15 then
                for _, player in ipairs(services.Players:GetPlayers()) do
                    if player ~= lp.player and player.Character then
                        local hum = player.Character:FindFirstChildOfClass("Humanoid")
                        if hum and hum.SeatPart == seat then
                            occupied = true
                            break
                        end
                    end
                end
            end
        end
    end)
    return occupied
end

local function fallbackToMuscleKing()
    pcall(function() utils.remotes.MachineInteract:InvokeServer("leaveMachine") end)
    if tabs.fullFarm and tabs.fullFarm.FastRepToggle then tabs.fullFarm.FastRepToggle:Set(false) end
    if kingSwitchRef and kingSwitchRef.Set then
        kingSwitchRef:Set(true)
    else
        tabs.configs.KingData.TeleportActive = true
        tabs.farming.ExerciseData.SelectedTool = "Weight"
        if tabs.farming and tabs.farming.AutoLiftSwitch then
            tabs.farming.AutoLiftSwitch:Set(true)
        end
    end
end

task.spawn(function()
    local snowLiftPos = Vector3.new(-5374, 71, 10321)
    local snowSquatPos = Vector3.new(-5099, 76, 11096)
    while utils.isCurrent() do
        task.wait(2)
        if tabs.configs.SnowLiftActive or tabs.configs.SnowSquatLoopActive then
            pcall(function()
                if tabs.configs.SnowLiftActive and isMachineOccupied(snowLiftPos) then
                    tabs.configs.SnowLiftActive = false
                    if tabs.configs.SnowConnection then
                        tabs.configs.SnowConnection:Disconnect()
                        tabs.configs.SnowConnection = nil
                    end
                    fallbackToMuscleKing()
                end

                if tabs.configs.SnowSquatLoopActive and isMachineOccupied(snowSquatPos) then
                    tabs.configs.SnowSquatLoopActive = false
                    if tabs.configs.SnowSquatConnection then
                        tabs.configs.SnowSquatConnection:Disconnect()
                        tabs.configs.SnowSquatConnection = nil
                    end
                    fallbackToMuscleKing()
                end
            end)
        end
    end
end)

tabs.configs:AddSwitch("Farm Snow Lift", function(state)
    tabs.configs.SnowLiftActive = state
    local targetPos = Vector3.new(-5374, 71, 10321)
    if state then
        pcall(function()
            travelToSnowGym()
            task.wait(0.4)
            interactWithMachine(targetPos)
        end)
        setupSnowRespawn(targetPos, false)
    else
        if tabs.configs.SnowConnection then
            tabs.configs.SnowConnection:Disconnect()
            tabs.configs.SnowConnection = nil
        end
        pcall(function() utils.remotes.MachineInteract:InvokeServer("leaveMachine") end)
    end
    if tabs.fullFarm and tabs.fullFarm.FastRepToggle then tabs.fullFarm.FastRepToggle:Set(state) end
end):Set(false)

tabs.configs:AddSwitch("Farm Snow Squat", function(state)
    tabs.configs.SnowSquatLoopActive = state
    local targetPos = Vector3.new(-5099, 76, 11096)
    if state then
        pcall(function()
            travelToSnowGym()
            task.wait(0.4)
            interactWithMachine(targetPos)
        end)
        setupSnowRespawn(targetPos, true)
    else
        if tabs.configs.SnowSquatConnection then
            tabs.configs.SnowSquatConnection:Disconnect()
            tabs.configs.SnowSquatConnection = nil
        end
        pcall(function() utils.remotes.MachineInteract:InvokeServer("leaveMachine") end)
    end
    if tabs.fullFarm and tabs.fullFarm.FastRepToggle then tabs.fullFarm.FastRepToggle:Set(state) end
end):Set(false)

tabs.configs:AddLabel("ZONE REBIRTH")
tabs.configs:AddSwitch("Auto Rebirth (Zones)", function(state)
    if autoRebirthToggleRef and autoRebirthToggleRef.Set then
        autoRebirthToggleRef:Set(state)
    end
end):Set(false)

-- ==========================================
-- HELPERS COMPARTIDOS DE BOSSES
-- ==========================================
local NORMAL_CHEST_POS = Vector3.new(-1, 66, -1249)
local ALIEN_CHEST_POS = Vector3.new(-1837, 68, -10977)
local BOSS_HITBOX_SIZE = Vector3.new(60, 120, 60)

local function getAlienBossArena()
    local alienGym = services.Workspace:FindFirstChild("AlienGym")
    local map = alienGym and alienGym:FindFirstChild("Map")
    return map and map:FindFirstChild("AlienBossArena")
end

local function getEventsBossArena()
    local events = services.Workspace:FindFirstChild("Events")
    return events and events:FindFirstChild("BossArena")
end

-- ==========================================
-- TAB: BOSS (NORMAL BOSSES)
-- ==========================================
tabs.boss.NormalData = {
    Running = false,
    Generation = 0,
    HitInterval = 0.01,
    NormalBosses = {}
}

tabs.boss.CollectingChest = false

tabs.boss:AddLabel("NORMAL BOSS INFO")
tabs.boss.StatusLabel = tabs.boss:AddLabel("")
hideStatus(tabs.boss.StatusLabel)
tabs.boss.BossLabel = tabs.boss:AddLabel("Boss: None")
tabs.boss.HealthLabel = tabs.boss:AddLabel("Health: 0 / 0")

tabs.boss.getBossData = function(bossModel)
    local subBoss = bossModel:FindFirstChild("Boss")
    local stats = bossModel:FindFirstChild("stats") or (subBoss and subBoss:FindFirstChild("stats"))
    local hum = bossModel:FindFirstChildOfClass("Humanoid") or (subBoss and subBoss:FindFirstChildOfClass("Humanoid"))
    
    local health = (stats and stats:FindFirstChild("Health") and stats.Health.Value)
        or bossModel:GetAttribute("BossHealth")
        or bossModel:GetAttribute("Health")
        or (subBoss and (subBoss:GetAttribute("BossHealth") or subBoss:GetAttribute("Health")))
        or (hum and hum.Health)
        
    local maxHealth = (stats and stats:FindFirstChild("MaxHealth") and stats.MaxHealth.Value)
        or bossModel:GetAttribute("BossMaxHealth")
        or bossModel:GetAttribute("MaxHealth")
        or (subBoss and (subBoss:GetAttribute("BossMaxHealth") or subBoss:GetAttribute("MaxHealth")))
        or (hum and hum.MaxHealth)
        
    local hitbox = bossModel:FindFirstChild("BossDamageHitbox", true)
        or (subBoss and (subBoss:FindFirstChild("HumanoidRootPart") or subBoss:FindFirstChild("UpperTorso") or subBoss:FindFirstChild("Torso") or subBoss.PrimaryPart))
        or bossModel:FindFirstChild("HumanoidRootPart")
        or bossModel:FindFirstChild("UpperTorso")
        or bossModel:FindFirstChild("Torso")
        or bossModel.PrimaryPart
        or bossModel:FindFirstChildWhichIsA("BasePart", true)
        
    return health, maxHealth, hitbox
end

tabs.boss:AddLabel("NORMAL BOSSES")

tabs.boss.addNormalBossChoice = function(name)
    name = tostring(name or "")
    if name ~= "" and not tabs.boss.NormalData.NormalBosses[name] then
        tabs.boss.NormalData.NormalBosses[name] = true
    end
end

tabs.boss.findNormalBoss = function()
    for _, candidate in ipairs(services.CollectionService:GetTagged("BossEventBoss")) do
        if candidate:IsA("Model") and candidate:IsDescendantOf(services.Workspace) then
            local bossName = candidate:GetAttribute("BossDisplayName") or candidate.Name
            tabs.boss.addNormalBossChoice(bossName)
            local health, maxHealth, hitbox = tabs.boss.getBossData(candidate)
            if hitbox then return candidate, bossName, health, maxHealth, hitbox end
        end
    end
    local arena = getEventsBossArena()
    if arena then
        for _, candidate in ipairs(arena:GetChildren()) do
            if candidate:IsA("Model") then
                local bossName = candidate:GetAttribute("BossDisplayName") or candidate.Name
                if candidate:GetAttribute("BossRarityIndex") ~= nil then
                    local health, maxHealth, hitbox = tabs.boss.getBossData(candidate)
                    if hitbox then return candidate, bossName, health, maxHealth, hitbox end
                end
            end
        end
    end
    return nil
end

pcall(function()
    local config = require(services.ReplicatedStorage:WaitForChild("shared"):WaitForChild("config"):WaitForChild("BossEventConfig"))
    if config and config.RARITIES then
        for _, rarity in ipairs(config.RARITIES) do tabs.boss.addNormalBossChoice(rarity.DisplayName or rarity.Name or rarity.BossModel) end
    end
end)

local function attackBossOrbit(hitbox)
    hitbox.Size = BOSS_HITBOX_SIZE
    hitbox.Transparency = 1
    hitbox.CanCollide = false
    local char = lp.player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local punch = (char and char:FindFirstChild("Punch")) or (utils.playerData.Backpack and utils.playerData.Backpack:FindFirstChild("Punch"))
    
    if hrp then
        if punch and punch.Parent ~= char and char:FindFirstChildOfClass("Humanoid") then
            char:FindFirstChildOfClass("Humanoid"):EquipTool(punch)
        end
        local alturaDinamica = (hitbox.Size.Y * 0.5) + 15
        local velocidadOrbita = tick() * 3
        local radioEvasion = 12
        local offsetSeguro = Vector3.new(
            math.cos(velocidadOrbita) * radioEvasion,
            alturaDinamica,
            math.sin(velocidadOrbita) * radioEvasion
        )
        
        hrp.CFrame = CFrame.lookAt(hitbox.Position + offsetSeguro, hitbox.Position)
        hrp.AssemblyLinearVelocity = Vector3.zero
        
        local muscleEvent = utils.remotes.MuscleEvent
        if muscleEvent then
            muscleEvent:FireServer("punch", "leftHand")
            muscleEvent:FireServer("punch", "rightHand")
        end
        if punch then punch:Activate() end
    end
end

tabs.boss.NormalBossToggle = tabs.boss:AddSwitch("Auto Farm Normal Boss", function(state)
    tabs.boss.NormalData.Running = state
    tabs.boss.NormalData.Generation = tabs.boss.NormalData.Generation + 1
    local gen = tabs.boss.NormalData.Generation
    
    pcall(function()
        if utils.remotes.ChangeSpeedSize then
            utils.remotes.ChangeSpeedSize:InvokeServer("changeSize", state and 6 or 2)
        end
    end)

    if not state then
        hideStatus(tabs.boss.StatusLabel)
        tabs.boss.BossLabel.Text = "Boss: None"
        tabs.boss.HealthLabel.Text = "Health: 0 / 0"
        return
    end

    hideStatus(tabs.boss.StatusLabel)

    task.spawn(function()
        local bossExisted = false
        while utils.isCurrent() and tabs.boss.NormalData.Running and tabs.boss.NormalData.Generation == gen do
            local killed = false
            local ok, err = pcall(function()
                if tabs.boss.CollectingChest then return end

                local model, bossName, health, maxHealth, hitbox = tabs.boss.findNormalBoss()
                if model and hitbox then
                    bossExisted = true
                    if health and health <= 0 then
                        killed = true
                    else
                        tabs.boss.BossLabel.Text = "Boss: " .. bossName
                        if health and maxHealth then
                            tabs.boss.HealthLabel.Text = "Health: " .. formatNumberSilence(health) .. " / " .. formatNumberSilence(maxHealth)
                        else
                            tabs.boss.HealthLabel.Text = "Health: Active"
                        end
                        attackBossOrbit(hitbox)
                    end
                else
                    if bossExisted then
                        killed = true
                    else
                        tabs.boss.BossLabel.Text = "Boss: None"
                        tabs.boss.HealthLabel.Text = "Health: 0 / 0"
                    end
                end
            end)

            if not ok then
                showErrorStatus(tabs.boss.StatusLabel, tostring(err))
            end

            if killed then
                bossExisted = false
                tabs.boss.CollectingChest = true
                pcall(utils.tpE, NORMAL_CHEST_POS)
                task.wait(1.5)
                tabs.boss.CollectingChest = false
            end

            task.wait(tabs.boss.NormalData.HitInterval)
        end
    end)
end)

-- ==========================================
-- TAB: ALIEN EVENT (ALIEN BOSS & SHOP)
-- ==========================================
tabs.alienEvent.AlienBossData = {
    Running = false,
    Generation = 0,
    HitInterval = 0.01
}

tabs.alienEvent:AddLabel("ALIEN BOSS INFO")
tabs.alienEvent.StatusLabel = tabs.alienEvent:AddLabel("")
hideStatus(tabs.alienEvent.StatusLabel)
tabs.alienEvent.BossLabel = tabs.alienEvent:AddLabel("Boss: None")
tabs.alienEvent.HealthLabel = tabs.alienEvent:AddLabel("Health: 0 / 0")

tabs.alienEvent:AddLabel("ALIEN BOSS")

tabs.alienEvent.findAlienBoss = function()
    local directBoss = services.Workspace:FindFirstChild("Alien Boss")
    if directBoss and directBoss:IsA("Model") then
        local bossName = directBoss:GetAttribute("BossDisplayName") or directBoss.Name
        local health, maxHealth, hitbox = tabs.boss.getBossData(directBoss)
        if hitbox then return directBoss, bossName, health, maxHealth, hitbox end
    end

    local alienArena = getAlienBossArena()
    if alienArena then
        local explicitBoss = alienArena:FindFirstChild("Alien Boss") or alienArena:FindFirstChild("AlienBoss")
        if explicitBoss and explicitBoss:IsA("Model") then
            local bossName = explicitBoss:GetAttribute("BossDisplayName") or explicitBoss.Name
            local health, maxHealth, hitbox = tabs.boss.getBossData(explicitBoss)
            if hitbox then return explicitBoss, bossName, health, maxHealth, hitbox end
        end
    end

    return nil
end

tabs.alienEvent.AlienBossToggle = tabs.alienEvent:AddSwitch("Auto Farm Alien Boss", function(state)
    tabs.alienEvent.AlienBossData.Running = state
    tabs.alienEvent.AlienBossData.Generation = tabs.alienEvent.AlienBossData.Generation + 1
    local gen = tabs.alienEvent.AlienBossData.Generation

    pcall(function()
        if utils.remotes.ChangeSpeedSize then
            utils.remotes.ChangeSpeedSize:InvokeServer("changeSize", state and 6 or 2)
        end
    end)

    if not state then
        hideStatus(tabs.alienEvent.StatusLabel)
        tabs.alienEvent.BossLabel.Text = "Boss: None"
        tabs.alienEvent.HealthLabel.Text = "Health: 0 / 0"
        return
    end

    hideStatus(tabs.alienEvent.StatusLabel)

    task.spawn(function()
        local bossExisted = false
        while utils.isCurrent() and tabs.alienEvent.AlienBossData.Running and tabs.alienEvent.AlienBossData.Generation == gen do
            local killed = false
            local ok, err = pcall(function()
                if tabs.boss.CollectingChest then return end

                local model, bossName, health, maxHealth, hitbox = tabs.alienEvent.findAlienBoss()
                if model and hitbox then
                    bossExisted = true
                    if health and health <= 0 then
                        killed = true
                    else
                        tabs.alienEvent.BossLabel.Text = "Boss: " .. tostring(bossName)
                        if health and maxHealth then
                            tabs.alienEvent.HealthLabel.Text = "Health: " .. formatNumberSilence(health) .. " / " .. formatNumberSilence(maxHealth)
                        else
                            tabs.alienEvent.HealthLabel.Text = "Health: Active"
                        end
                        attackBossOrbit(hitbox)
                    end
                else
                    if bossExisted then
                        killed = true
                    else
                        tabs.alienEvent.BossLabel.Text = "Boss: None"
                        tabs.alienEvent.HealthLabel.Text = "Health: 0 / 0"
                    end
                end
            end)

            if not ok then
                showErrorStatus(tabs.alienEvent.StatusLabel, tostring(err))
            end

            if killed then
                bossExisted = false
                tabs.boss.CollectingChest = true
                pcall(utils.tpE, ALIEN_CHEST_POS)
                task.wait(1.5)
                tabs.boss.CollectingChest = false
            end

            task.wait(tabs.alienEvent.AlienBossData.HitInterval)
        end
    end)
end)

pcall(function()
    if utils.remotes.GuiDamageEvent then
        utils.connect(utils.remotes.GuiDamageEvent.OnClientEvent, function(action, _, damage, targetModel, _)
            if action == "bossPlayerDamageShow" and targetModel and damage then
                local alienArena = getAlienBossArena()
                local isAlienBoss = (targetModel.Name == "Alien Boss" or targetModel.Name == "AlienBoss")
                    or (alienArena and targetModel:IsDescendantOf(alienArena))
                if isAlienBoss then
                    tabs.alienEvent.HealthLabel.Text = "Last Damage: " .. formatNumberSilence(damage)
                elseif tabs.boss.NormalData.NormalBosses[targetModel.Name] then
                    tabs.boss.HealthLabel.Text = "Last Damage: " .. formatNumberSilence(damage)
                end
            end
        end)
    end
end)

-- ==========================================
-- ALIEN EVENT SHOP (AUTO COMPRA AL ACTIVAR + AUTO REFRESH Y COMPRA AL RESTOCK + ESTADO DINÁMICO DE BOTONES)
-- ==========================================
tabs.alienEvent:AddLabel("ALIEN EVENT SHOP")
tabs.alienEvent.ShopTimerLabel = tabs.alienEvent:AddLabel("Restock: --:--")
tabs.alienEvent.ShopTimerLabel.TextColor3 = Color3.fromRGB(185, 255, 70)

tabs.alienEvent.EventShop = {
    AutoBuy = false,
    SelectedMap = {},
    SelectedOrder = {},
    ItemEntries = {},
    ItemButtons = {},
    LastAttemptAt = {},
    RestockBurstUntil = 0,
    RepeatInterval = 1.5,
    Generation = 0,
    RowsHooked = nil,
    RowSignalsHooked = setmetatable({}, {__mode = "k"})
}

local ALIEN_SHOP_KEY_MAP = {
    ["lunarslug"] = "LunarSlug",
    ["alienserum"] = "AlienSerum",
    ["cosmicinvader"] = "CosmicInvader",
    ["alienslime"] = "AlienSlime",
    ["ufoaxolotl"] = "UFOAxolotl",
    ["ufobot"] = "UFOBot",
    ["galacticooverlord"] = "GalacticOverlord",
    ["galacticoverlord"] = "GalacticOverlord",
    ["aliencrate"] = "AlienCrate",
    ["alienegg"] = "AlienEgg"
}

local function normalizeShopKey(str)
    return tostring(str or ""):lower():gsub("[%s_%-]", "")
end

local function formatAlienItemDisplayName(rawName)
    local formatted = tostring(rawName or "")
        :gsub("(%l)(%u)", "%1 %2")
        :gsub("(%u+)(%u%l)", "%1 %2")
        :gsub("_+", " ")
        :gsub("^%s*(.-)%s*$", "%1")
    return formatted ~= "" and formatted or tostring(rawName)
end

local cachedAlienShopGui = nil
local function getAlienShopGui()
    if cachedAlienShopGui and cachedAlienShopGui.Parent then
        return cachedAlienShopGui
    end
    local playerGui = lp.player:FindFirstChild("PlayerGui")
    cachedAlienShopGui = playerGui and playerGui:FindFirstChild("alienShopGui")
    return cachedAlienShopGui
end

local cachedAlienRowsFolder = nil
local function getAlienShopRowsFolder()
    if cachedAlienRowsFolder and cachedAlienRowsFolder.Parent then
        return cachedAlienRowsFolder
    end
    local alienShopGui = getAlienShopGui()
    if not alienShopGui then return nil end
    local upgrades = alienShopGui:FindFirstChild("Upgrades", true)
    cachedAlienRowsFolder = (upgrades and upgrades:FindFirstChild("Rows")) or alienShopGui:FindFirstChild("Rows", true)
    return cachedAlienRowsFolder
end

local function getServerNow()
    local serverNow = os.time()
    pcall(function()
        if services.Workspace.GetServerTimeNow then
            serverNow = math.floor(services.Workspace:GetServerTimeNow())
        end
    end)
    return serverNow
end

local function getAlienShopTimerText()
    local serverNow = getServerNow()
    local remaining = 3600 - (serverNow % 3600)
    if remaining == 3600 then
        remaining = 0
    end
    return string.format("Restock: %02d:%02d", math.floor(remaining / 60), remaining % 60)
end

local cachedAlienShopRemote = nil
local function getAlienShopRemote()
    if cachedAlienShopRemote and cachedAlienShopRemote.Parent then
        return cachedAlienShopRemote
    end
    local packages = services.ReplicatedStorage:FindFirstChild("packages")
    local net = packages and packages:FindFirstChild("Net")
    local remote = net and net:FindFirstChild("RF/AlienShop")
    if remote and remote:IsA("RemoteFunction") then
        cachedAlienShopRemote = remote
        return remote
    end
    return nil
end

local function inspectAlienShopRow(row)
    local rawKey = row.Name
    local titleObj = row:FindFirstChild("Title", true)
    local displayName = (titleObj and titleObj:IsA("TextLabel") and titleObj.Text ~= "")
        and titleObj.Text
        or formatAlienItemDisplayName(rawKey)

    local headlineObj = row:FindFirstChild("Headline", true)
    local oddsObj = row:FindFirstChild("Odds", true)
    local btnLabelObj = row:FindFirstChild("ButtonLabel", true)
    local descObj = row:FindFirstChild("Description", true)
    local amountObj = row:FindFirstChild("Amount", true)

    local headlineText = (headlineObj and headlineObj:IsA("TextLabel")) and headlineObj.Text or ""
    local oddsText = (oddsObj and oddsObj:IsA("TextLabel")) and oddsObj.Text or ""
    local btnText = (btnLabelObj and btnLabelObj:IsA("TextLabel")) and btnLabelObj.Text or ""
    local descText = (descObj and descObj:IsA("TextLabel")) and descObj.Text or ""
    local amountText = (amountObj and amountObj:IsA("TextLabel")) and amountObj.Text or "--"

    local hUpper = headlineText:upper()
    local bUpper = btnText:upper()
    local dLower = descText:lower()
    local keyLower = rawKey:lower()
    local nameLower = displayName:lower()

    local isOneTimeOnly = (bUpper == "OWNED")
        or keyLower:find("crown") ~= nil
        or nameLower:find("crown") ~= nil
        or nameLower:find("corona") ~= nil
        or (oddsText == "" and headlineText == "" and dLower:find("equipped") == nil and dLower:find("minutes") == nil and dLower:find("boost") == nil and dLower:find("egg") == nil and dLower:find("pet") == nil and dLower:find("crate") == nil)

    local outOfStock = (hUpper == "SOLD OUT" or hUpper == "NOT IN STOCK")
        or (bUpper == "SOLD" or bUpper == "OUT")
    local canBuyNow = (not isOneTimeOnly) and (not outOfStock) and (bUpper == "BUY" or bUpper == "")

    local statusTag = "BUY"
    if hUpper == "SOLD OUT" or bUpper == "SOLD" then
        statusTag = "SOLD"
    elseif hUpper == "NOT IN STOCK" or bUpper == "OUT" then
        statusTag = "OUT"
    end

    local oddsShort = oddsText:match("(%d+%%)") or ""

    return {
        DisplayName = displayName,
        RawKey = rawKey,
        LayoutOrder = row.LayoutOrder,
        PriceText = amountText,
        OddsShort = oddsShort,
        StatusTag = statusTag,
        Row = row,
        OutOfStock = outOfStock,
        CanBuyNow = canBuyNow,
        IsOneTimeOnly = isOneTimeOnly
    }
end

local function scanAlienShopMainThree()
    local list = {}
    local rowsFolder = getAlienShopRowsFolder()
    if not rowsFolder then return {} end

    for _, child in ipairs(rowsFolder:GetChildren()) do
        if child:IsA("GuiObject") then
            local info = inspectAlienShopRow(child)
            if not info.IsOneTimeOnly then
                table.insert(list, info)
            end
        end
    end

    table.sort(list, function(a, b)
        if a.LayoutOrder ~= b.LayoutOrder then
            return a.LayoutOrder < b.LayoutOrder
        end
        return a.DisplayName < b.DisplayName
    end)

    local results = {}
    for i = 1, math.min(3, #list) do
        results[list[i].DisplayName] = list[i]
    end
    return results
end

local function formatShopCardButtonText(info, isSelected)
    local selMark = isSelected and "✔ " or "+ "
    local oddsPart = (info.OddsShort ~= "") and (" | " .. info.OddsShort) or ""
    return string.format("%s[%s] %s | %s%s", selMark, info.StatusTag, info.DisplayName, tostring(info.PriceText), oddsPart)
end

tabs.alienEvent.SelectedItemsLabel = tabs.alienEvent:AddLabel("Selected (0): None")
tabs.alienEvent.SelectedItemsLabel.TextColor3 = Color3.fromRGB(180, 150, 255)

tabs.alienEvent.updateSelectedShopLabel = function()
    local shop = tabs.alienEvent.EventShop
    local parts = {}
    for _, itemName in ipairs(shop.SelectedOrder) do
        if shop.SelectedMap[itemName] then
            table.insert(parts, itemName)
        end
    end
    if #parts == 0 then
        tabs.alienEvent.SelectedItemsLabel.Text = "Selected (0): None"
    else
        tabs.alienEvent.SelectedItemsLabel.Text = string.format("Selected (%d): %s", #parts, table.concat(parts, ", "))
    end
end

local function setUiButtonText(btn, text, color)
    if not btn then return end
    pcall(function()
        if type(btn) == "table" then
            if btn.SetText then
                btn:SetText(text)
            elseif btn.Text ~= nil then
                btn.Text = text
            end
            local inst = btn.Button or btn.Instance or btn.Object
            if typeof(inst) == "Instance" then
                if inst:IsA("TextButton") or inst:IsA("TextLabel") then
                    inst.Text = text
                    if color then inst.TextColor3 = color end
                else
                    local lbl = inst:FindFirstChildWhichIsA("TextLabel", true) or inst:FindFirstChildWhichIsA("TextButton", true)
                    if lbl then
                        lbl.Text = text
                        if color then lbl.TextColor3 = color end
                    end
                end
            end
        elseif typeof(btn) == "Instance" then
            if btn:IsA("TextButton") or btn:IsA("TextLabel") then
                btn.Text = text
                if color then btn.TextColor3 = color end
            else
                local lbl = btn:FindFirstChildWhichIsA("TextLabel", true) or btn:FindFirstChildWhichIsA("TextButton", true)
                if lbl then
                    lbl.Text = text
                    if color then lbl.TextColor3 = color end
                end
            end
        end
    end)
end

local function updateShopRowButton(itemName)
    local shop = tabs.alienEvent.EventShop
    local btn = shop.ItemButtons[itemName]
    if not btn then return end

    local isSelected = shop.SelectedMap[itemName] == true
    local info = shop.ItemEntries[itemName]

    -- Si el ítem ya no está en la rotación actual de la tienda, marcarlo como [OUT]
    if not info then
        local selMark = isSelected and "✔ " or "+ "
        local outText = string.format("%s[OUT] %s | Not in shop", selMark, itemName)
        local outColor = isSelected and Color3.fromRGB(185, 130, 255) or Color3.fromRGB(140, 140, 150)
        setUiButtonText(btn, outText, outColor)
        return
    end

    local newText = formatShopCardButtonText(info, isSelected)
    local textColor = Color3.fromRGB(220, 220, 230)
    if isSelected then
        textColor = Color3.fromRGB(185, 130, 255)
    elseif info.CanBuyNow then
        textColor = COLOR_OK
    elseif info.OutOfStock then
        textColor = Color3.fromRGB(255, 120, 120)
    end

    setUiButtonText(btn, newText, textColor)
end

local function toggleShopItemSelection(itemName)
    local shop = tabs.alienEvent.EventShop
    if not itemName or itemName == "" then return end

    if shop.SelectedMap[itemName] then
        shop.SelectedMap[itemName] = nil
        for i = #shop.SelectedOrder, 1, -1 do
            if shop.SelectedOrder[i] == itemName then
                table.remove(shop.SelectedOrder, i)
            end
        end
    else
        shop.SelectedMap[itemName] = true
        table.insert(shop.SelectedOrder, itemName)
    end

    updateShopRowButton(itemName)
    tabs.alienEvent.updateSelectedShopLabel()
end

tabs.alienEvent:AddButton("Clear Selected Items", function()
    local shop = tabs.alienEvent.EventShop
    shop.SelectedMap = {}
    shop.SelectedOrder = {}
    for itemName in pairs(shop.ItemButtons) do
        updateShopRowButton(itemName)
    end
    tabs.alienEvent.updateSelectedShopLabel()
end)

tabs.alienEvent.ShopStatusLabel = tabs.alienEvent:AddLabel("")
hideStatus(tabs.alienEvent.ShopStatusLabel)

local function getTargetShopItems()
    local targets = {}
    for _, itemName in ipairs(tabs.alienEvent.EventShop.SelectedOrder) do
        if tabs.alienEvent.EventShop.SelectedMap[itemName] then
            table.insert(targets, itemName)
        end
    end
    return targets
end

local function executeShopPurchase(rowInfo, fallbackKey, alienShopRemote)
    if not alienShopRemote then return false end
    local rawKey = rowInfo and rowInfo.RawKey
    local normInput = normalizeShopKey(rawKey or fallbackKey)
    local mappedKey = ALIEN_SHOP_KEY_MAP[normInput]
    local finalKey = rawKey or mappedKey or fallbackKey
    local ok = pcall(alienShopRemote.InvokeServer, alienShopRemote, finalKey)
    if not ok and mappedKey and mappedKey ~= finalKey then
        ok = pcall(alienShopRemote.InvokeServer, alienShopRemote, mappedKey)
    end
    return ok
end

local function runAutoShopPurchaseCycle(forceImmediate)
    local shop = tabs.alienEvent.EventShop
    if not shop.AutoBuy or not utils.isCurrent() then return end

    local targets = getTargetShopItems()
    local alienShopRemote = getAlienShopRemote()

    if #targets == 0 then
        showErrorStatus(tabs.alienEvent.ShopStatusLabel, "Selecciona al menos 1 objeto")
        return
    end
    if not alienShopRemote then
        showErrorStatus(tabs.alienEvent.ShopStatusLabel, "ReplicatedStorage.packages.Net['RF/AlienShop'] no encontrado")
        return
    end

    local now = os.clock()
    local inRestockBurst = forceImmediate or (now <= (shop.RestockBurstUntil or 0))
    local liveRows = scanAlienShopMainThree()
    for k, v in pairs(liveRows) do
        shop.ItemEntries[k] = v
    end

    for _, itemName in ipairs(targets) do
        local normKey = normalizeShopKey(itemName)
        local rowInfo = liveRows[itemName] or shop.ItemEntries[itemName]
        local fallbackKey = itemName:gsub("[%s%-]+", "")
        local canBuy = inRestockBurst or (not rowInfo) or rowInfo.CanBuyNow

        if canBuy then
            if forceImmediate or not shop.LastAttemptAt[normKey] or (now - shop.LastAttemptAt[normKey]) >= shop.RepeatInterval then
                executeShopPurchase(rowInfo, fallbackKey, alienShopRemote)
                shop.LastAttemptAt[normKey] = os.clock()
            end
        end
    end

    hideStatus(tabs.alienEvent.ShopStatusLabel)
end

local function triggerShopRestockAndBuy()
    local shop = tabs.alienEvent.EventShop
    shop.LastAttemptAt = {}
    shop.RestockBurstUntil = os.clock() + 15
    if tabs.alienEvent.refreshShopItems then
        tabs.alienEvent.refreshShopItems()
    end
    if shop.AutoBuy then
        task.spawn(function()
            runAutoShopPurchaseCycle(true)
            task.wait(0.35)
            if tabs.alienEvent.refreshShopItems then
                tabs.alienEvent.refreshShopItems()
            end
        end)
    end
end

tabs.alienEvent:AddSwitch("Auto Buy Event Shop", function(state)
    local shop = tabs.alienEvent.EventShop
    shop.AutoBuy = state
    shop.Generation = shop.Generation + 1
    local gen = shop.Generation

    if not state then
        hideStatus(tabs.alienEvent.ShopStatusLabel)
        return
    end

    -- Al activar: refrescar tienda y ejecutar auto compra inmediatamente
    shop.LastAttemptAt = {}
    shop.RestockBurstUntil = os.clock() + 10
    if tabs.alienEvent.refreshShopItems then
        tabs.alienEvent.refreshShopItems()
    end

    task.spawn(function()
        runAutoShopPurchaseCycle(true)
        task.wait(0.35)
        if tabs.alienEvent.refreshShopItems then
            tabs.alienEvent.refreshShopItems()
        end

        while utils.isCurrent() and shop.AutoBuy and shop.Generation == gen do
            task.wait(1)
            if not (utils.isCurrent() and shop.AutoBuy and shop.Generation == gen) then break end
            runAutoShopPurchaseCycle(false)
        end
    end)
end):Set(false)

tabs.alienEvent:AddLabel("SHOP ITEMS (TOP 3 MAIN)")
tabs.alienEvent.EmptyShopHint = tabs.alienEvent:AddLabel("Abre la Alien Shop una vez para cargar los ítems")
tabs.alienEvent.EmptyShopHint.TextColor3 = Color3.fromRGB(170, 170, 185)

local function hookShopRowChanges(row)
    local shop = tabs.alienEvent.EventShop
    if not row or shop.RowSignalsHooked[row] then return end
    shop.RowSignalsHooked[row] = true

    for _, labelName in ipairs({"Title", "Headline", "ButtonLabel", "Amount", "Odds"}) do
        local lbl = row:FindFirstChild(labelName, true)
        if lbl and lbl:IsA("TextLabel") then
            local prevText = lbl.Text
            utils.connect(lbl:GetPropertyChangedSignal("Text"), function()
                local newText = lbl.Text
                local wasSold = prevText:upper():find("SOLD") or prevText:upper():find("OUT")
                local nowAvailable = newText:upper() == "BUY" or newText == ""
                prevText = newText

                task.defer(function()
                    if tabs.alienEvent.refreshShopItems then
                        tabs.alienEvent.refreshShopItems()
                    end
                    -- Si la fila pasó de agotada a disponible (restock), comprar inmediatamente
                    if wasSold and nowAvailable and shop.AutoBuy then
                        triggerShopRestockAndBuy()
                    end
                end)
            end)
        end
    end
end

tabs.alienEvent.refreshShopItems = function()
    local shop = tabs.alienEvent.EventShop
    local rowsFolder = getAlienShopRowsFolder()

    if rowsFolder and shop.RowsHooked ~= rowsFolder then
        shop.RowsHooked = rowsFolder
        utils.connect(rowsFolder.ChildAdded, function(child)
            hookShopRowChanges(child)
            task.defer(function()
                tabs.alienEvent.refreshShopItems()
                if shop.AutoBuy then
                    triggerShopRestockAndBuy()
                end
            end)
        end)
        utils.connect(rowsFolder.ChildRemoved, function()
            task.defer(tabs.alienEvent.refreshShopItems)
        end)
    end

    if rowsFolder then
        for _, child in ipairs(rowsFolder:GetChildren()) do
            if child:IsA("GuiObject") then
                hookShopRowChanges(child)
            end
        end
    end

    tabs.alienEvent.ShopTimerLabel.Text = getAlienShopTimerText()

    local entries = scanAlienShopMainThree()
    shop.ItemEntries = entries

    local orderedEntries = {}
    for _, info in pairs(entries) do
        table.insert(orderedEntries, info)
    end
    table.sort(orderedEntries, function(a, b)
        if a.LayoutOrder ~= b.LayoutOrder then
            return a.LayoutOrder < b.LayoutOrder
        end
        return a.DisplayName < b.DisplayName
    end)

    tabs.alienEvent.EmptyShopHint.Visible = (#orderedEntries == 0)

    for _, info in ipairs(orderedEntries) do
        local itemName = info.DisplayName
        if not shop.ItemButtons[itemName] then
            local btn = tabs.alienEvent:AddButton(formatShopCardButtonText(info, shop.SelectedMap[itemName] == true), function()
                toggleShopItemSelection(itemName)
            end)
            shop.ItemButtons[itemName] = btn
        end
    end

    -- Actualizar todos los botones existentes (incluyendo los que salieron de rotación)
    for existingName in pairs(shop.ItemButtons) do
        updateShopRowButton(existingName)
    end

    tabs.alienEvent.updateSelectedShopLabel()
end

-- Actualización automática cada segundo y refresco + compra inmediata al reiniciarse la tienda
local lastShopHour = -1
task.spawn(function()
    while utils.isCurrent() do
        tabs.alienEvent.ShopTimerLabel.Text = getAlienShopTimerText()

        local currentHour = math.floor(getServerNow() / 3600)
        if lastShopHour ~= -1 and currentHour ~= lastShopHour then
            triggerShopRestockAndBuy()
            task.delay(1.2, function()
                if utils.isCurrent() then
                    triggerShopRestockAndBuy()
                end
            end)
        elseif next(tabs.alienEvent.EventShop.ItemButtons) == nil then
            local liveRows = scanAlienShopMainThree()
            if next(liveRows) ~= nil then
                tabs.alienEvent.refreshShopItems()
            end
        end

        lastShopHour = currentHour
        task.wait(1)
    end
end)

pcall(function()
    local playerGui = lp.player:FindFirstChild("PlayerGui")
    if playerGui then
        utils.connect(playerGui.ChildAdded, function(child)
            if child.Name == "alienShopGui" then
                cachedAlienShopGui = child
                cachedAlienRowsFolder = nil
                task.wait(0.4)
                tabs.alienEvent.refreshShopItems()
                if tabs.alienEvent.EventShop.AutoBuy then
                    runAutoShopPurchaseCycle(true)
                end
            end
        end)
    end
end)

task.delay(1.5, function()
    tabs.alienEvent.refreshShopItems()
end)

-- ==========================================
-- TAB: KILL (PVP)
-- ==========================================
tabs.clips:AddLabel("KILL AURA (DEATH RING)")
local AuraConfig = { Enabled = false, Range = 20, RingPart = nil }

tabs.clips:AddTextBox("Aura Range (1-140):", function(text)
    local num = tonumber(text)
    if num then 
        AuraConfig.Range = math.clamp(num, 1, 140) 
        if AuraConfig.RingPart then
            AuraConfig.RingPart.Size = Vector3.new(0.2, AuraConfig.Range * 2, AuraConfig.Range * 2)
        end
    end
end, {clear = false})

local function updateRing()
    if AuraConfig.RingPart then AuraConfig.RingPart:Destroy() end
    if not AuraConfig.Enabled then return end
    
    AuraConfig.RingPart = Instance.new("Part")
    AuraConfig.RingPart.Name = "ProyectadosAuraRing"
    AuraConfig.RingPart.Shape = Enum.PartType.Cylinder
    AuraConfig.RingPart.Material = Enum.Material.Neon
    AuraConfig.RingPart.Color = Color3.fromRGB(138, 43, 226)
    AuraConfig.RingPart.Transparency = 0.6
    AuraConfig.RingPart.Anchored = true
    AuraConfig.RingPart.CanCollide = false
    AuraConfig.RingPart.Size = Vector3.new(0.2, AuraConfig.Range * 2, AuraConfig.Range * 2)
    AuraConfig.RingPart.Parent = services.Workspace
end

AuraConfig.Toggle = tabs.clips:AddSwitch("Toggle Kill Aura", function(state)
    AuraConfig.Enabled = state
    updateRing()
    
    if state then
        task.spawn(function()
            local heartbeat = services.RunService.Heartbeat
            local ringAngle = CFrame.Angles(0, 0, math.rad(90))
            while AuraConfig.Enabled and utils.isCurrent() do
                local char = lp.player.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                
                if hrp then
                    if AuraConfig.RingPart then
                        AuraConfig.RingPart.CFrame = hrp.CFrame * ringAngle
                    end
                    
                    local myPos = hrp.Position
                    local range = AuraConfig.Range
                    local leftHand = char:FindFirstChild("LeftHand")
                    local rightHand = char:FindFirstChild("RightHand")
                    local muscleEvent = utils.remotes.MuscleEvent

                    for _, player in ipairs(services.Players:GetPlayers()) do
                        if player ~= lp.player and player.Character then
                            local targetHrp = player.Character:FindFirstChild("HumanoidRootPart")
                            local targetHum = player.Character:FindFirstChildOfClass("Humanoid")
                            if targetHrp and targetHum and targetHum.Health > 0 and (myPos - targetHrp.Position).Magnitude <= range then
                                pcall(function()
                                    if leftHand and rightHand then
                                        firetouchinterest(targetHrp, leftHand, 0)
                                        firetouchinterest(targetHrp, leftHand, 1)
                                    end
                                    if muscleEvent then
                                        muscleEvent:FireServer("punch", "leftHand")
                                        muscleEvent:FireServer("punch", "rightHand")
                                    end
                                end)
                            end
                        end
                    end
                end
                heartbeat:Wait()
            end
        end)
    end
end)

-- ==========================================
-- TAB: EXTRAS (QUESTS, BOOSTS & EXTRAS)
-- ==========================================
tabs.misiones:AddLabel("QUESTS")
tabs.misiones.AutoQuestActive = false
tabs.misiones:AddSwitch("Auto Collect Quests", function(state)
    tabs.misiones.AutoQuestActive = state
    if state then
        task.spawn(function()
            local questsEvent = utils.remotes.QuestsEvent or (rEvents and rEvents:FindFirstChild("questsEvent"))
            while tabs.misiones.AutoQuestActive and utils.isCurrent() do
                pcall(function()
                    if questsEvent then
                        local questsFolder = lp.player:FindFirstChild("Quests")
                        if questsFolder then
                            for _, child in ipairs(questsFolder:GetChildren()) do
                                if child.Name ~= "completedQuests" then
                                    questsEvent:FireServer("collectQuest", child)
                                    questsEvent:FireServer("collectQuest", child.Name)
                                    questsEvent:FireServer("collectDailyQuest", child)
                                    questsEvent:FireServer("collectDailyQuest", child.Name)
                                    questsEvent:FireServer("collectEnchantQuest", child)
                                    questsEvent:FireServer("collectEnchantQuest", child.Name)
                                end
                            end
                        end
                    end
                end)
                task.wait(1.5)
            end
        end)
    end
end):Set(false)

tabs.misiones:AddLabel("BOOSTS & CONSUMABLES")
tabs.misiones.eggsowned = tabs.misiones:AddLabel("Protein Eggs: 0")
tabs.misiones.shakesowned = tabs.misiones:AddLabel("Tropical Shakes: 0")
tabs.misiones.autoEgg = false
tabs.misiones.autoShake = false
tabs.misiones.eatAllBoostsRunning = false

tabs.misiones.x2str = tabs.misiones:AddLabel("x2 Strength: 0d 0h 0m 0s")
tabs.misiones.x125dur = tabs.misiones:AddLabel("x1.25 Durability: 0d 0h 0m 0s")

local function formatBoostTime(seconds)
    return string.format("%dd %dh %dm %ds", math.floor(seconds / 86400), math.floor((seconds % 86400) / 3600), math.floor((seconds % 3600) / 60), seconds % 60)
end

-- Unificado: actualiza inventario y timers en un mismo ciclo
task.spawn(function()
    local tickToggle = false
    while utils.isCurrent() do
        local boostFolder = lp.player:FindFirstChild("boostTimersFolder")
        local eggBoost = boostFolder and boostFolder:FindFirstChild("Protein Egg")
        local shakeBoost = boostFolder and boostFolder:FindFirstChild("Tropical Shake")
        
        local eggSec = (eggBoost and eggBoost:IsA("IntValue")) and eggBoost.Value or 0
        local shakeSec = (shakeBoost and shakeBoost:IsA("IntValue")) and shakeBoost.Value or 0
        
        tabs.misiones.x2str.Text = "x2 Strength: " .. formatBoostTime(eggSec)
        tabs.misiones.x125dur.Text = "x1.25 Durability: " .. formatBoostTime(shakeSec)

        tickToggle = not tickToggle
        if tickToggle then
            local eggCount = 0
            local shakeCount = 0
            local bp = utils.playerData.Backpack
            if bp then
                for _, item in ipairs(bp:GetChildren()) do
                    if item.Name == "Protein Egg" then eggCount = eggCount + 1
                    elseif item.Name == "Tropical Shake" then shakeCount = shakeCount + 1 end
                end
            end
            tabs.misiones.eggsowned.Text = "Protein Eggs: " .. eggCount
            tabs.misiones.shakesowned.Text = "Tropical Shakes: " .. shakeCount
        end
        task.wait(0.5)
    end
end)

tabs.misiones:AddSwitch("Auto Eat Eggs", function(state)
    tabs.misiones.autoEgg = state
    if state then
        task.spawn(function()
            local muscleEvent = utils.remotes.MuscleEvent
            while utils.isCurrent() and tabs.misiones.autoEgg do
                pcall(function()
                    local char = lp.player.Character
                    local bp = utils.playerData.Backpack
                    local tool = (char and char:FindFirstChild("Protein Egg")) or (bp and bp:FindFirstChild("Protein Egg"))
                    if tool and muscleEvent then
                        for _ = 1, 10 do muscleEvent:FireServer("proteinEgg", tool) end
                    end
                end)
                task.wait(0.5)
            end
        end)
    end
end)

tabs.misiones:AddSwitch("Auto Eat Shakes", function(state)
    tabs.misiones.autoShake = state
    if state then
        task.spawn(function()
            local muscleEvent = utils.remotes.MuscleEvent
            while utils.isCurrent() and tabs.misiones.autoShake do
                pcall(function()
                    local char = lp.player.Character
                    local bp = utils.playerData.Backpack
                    local tool = (char and char:FindFirstChild("Tropical Shake")) or (bp and bp:FindFirstChild("Tropical Shake"))
                    if tool and muscleEvent then
                        for _ = 1, 10 do muscleEvent:FireServer("tropicalShake", tool) end
                    end
                end)
                task.wait(0.5)
            end
        end)
    end
end)

local boostItemList = {
    {"Tropical Shake", "tropicalShake"},
    {"Energy Shake", "energyShake"},
    {"Protein Bar", "proteinBar"},
    {"TOUGH Bar", "toughBar"},
    {"Protein Shake", "proteinShake"},
    {"ULTRA Shake", "ultraShake"},
    {"Energy Bar", "energyBar"},
}

tabs.misiones:AddSwitch("Eat All Boosts (Expect Lag)", function(state)
    tabs.misiones.eatAllBoostsRunning = state
    if state then
        task.spawn(function()
            local muscleEvent = utils.remotes.MuscleEvent
            while utils.isCurrent() and tabs.misiones.eatAllBoostsRunning do
                pcall(function()
                    local char = lp.player.Character
                    local bp = utils.playerData.Backpack
                    if muscleEvent then
                        for _, bInfo in ipairs(boostItemList) do
                            local bName, bAction = bInfo[1], bInfo[2]
                            local bTool = (char and char:FindFirstChild(bName)) or (bp and bp:FindFirstChild(bName))
                            if bTool then
                                for _ = 1, 10 do
                                    muscleEvent:FireServer(bAction, bTool)
                                end
                            end
                        end
                    end
                end)
                task.wait(0.1)
            end
        end)
    end
end):Set(false)

tabs.misiones:AddLabel("CRYSTALS")
tabs.misiones:AddSwitch("Auto Open Zero Degrees Crystal", function(state)
    _G.AutoAbrirCristales = state
    if state then
        task.spawn(function()
            local event = utils.remotes.OpenCrystalRemote or (rEvents and rEvents:FindFirstChild("openCrystalRemote"))
            while _G.AutoAbrirCristales and utils.isCurrent() do
                pcall(function()
                    if event then
                        event:InvokeServer("openCrystalBulk", "Zero Degrees Crystal", 10)
                    end
                end)
                task.wait(4)
            end
        end)
    end
end):Set(false)

tabs.misiones:AddLabel("FORTUNE WHEEL")
tabs.misiones:AddSwitch("Auto Spin Wheel", function(bool)
    _G.AutoSpinWheel = bool
    if bool then
        task.spawn(function()
            local rspin = utils.remotes.OpenWheelRemote or (rEvents and rEvents:FindFirstChild("openFortuneWheelRemote"))
            local chances = services.ReplicatedStorage.shared.catalogs.fortuneWheelChances["Fortune Wheel"]
            while _G.AutoSpinWheel and utils.isCurrent() do
                pcall(rspin.InvokeServer, rspin, "openFortuneWheel", chances)
                task.wait(1)
            end
        end)
    end
end)

tabs.misiones:AddLabel("TELEPORTS")
tabs.misiones:AddButton("tp to enchant", function() utils.tpE(Vector3.new(72, 14, 422)) end)

-- ==========================================
-- TAB: PET XP (TRACKER COMPACTO CON [EQ] PRIMERO Y AUTO SELL SIN EXCLUSIVE)
-- ==========================================
tabs.pets:AddLabel("PET PROGRESS TRACKER")

tabs.pets.SelectedDisplay = nil
tabs.pets.PetMap = {}
tabs.pets.PetToDisplay = {}

local levelXpLabel = tabs.pets:AddLabel("Lv. -- | XP: 0 / 0 (0.0%)")
levelXpLabel.TextColor3 = Color3.fromRGB(255, 215, 0)

local etaCombinedLabel = tabs.pets:AddLabel("Next: -- | Max (350): --")
etaCombinedLabel.TextColor3 = Color3.fromRGB(80, 255, 120)

local petTracker = {
    ConnectionXP = nil,
    ConnectionLvl = nil,
    SelectedPet = nil,
    ManualSelection = false,
    History = {},
    SmoothedRate = 0,
    LastLevel = 0
}

local function getEquippedPetsMapAndList()
    local list = {}
    local seen = {}
    local petsFolder = lp.player:FindFirstChild("petsFolder")

    local function registerPet(petInst)
        if petInst and typeof(petInst) == "Instance" and petInst.Parent and not seen[petInst] then
            if not petsFolder or petInst:IsDescendantOf(petsFolder) then
                seen[petInst] = true
                table.insert(list, petInst)
            end
        end
    end

    local equippedFolder = lp.player:FindFirstChild("equippedPets")
    if equippedFolder then
        for _, slot in ipairs(equippedFolder:GetChildren()) do
            if slot:IsA("ObjectValue") and slot.Value then
                registerPet(slot.Value)
            end
            for _, desc in ipairs(slot:GetDescendants()) do
                if desc:IsA("ObjectValue") and desc.Value then
                    registerPet(desc.Value)
                end
            end
        end
    end

    if petsFolder then
        for _, folder in ipairs(petsFolder:GetChildren()) do
            if folder:IsA("Folder") then
                for _, pet in ipairs(folder:GetChildren()) do
                    local eqVal = pet:FindFirstChild("equipped") or pet:FindFirstChild("Equipped") or pet:FindFirstChild("isEquipped")
                    if (eqVal and eqVal:IsA("BoolValue") and eqVal.Value)
                        or pet:GetAttribute("equipped") == true
                        or pet:GetAttribute("Equipped") == true
                        or pet:GetAttribute("isEquipped") == true then
                        registerPet(pet)
                    end
                end
            end
        end
    end

    return list, seen
end

local function isPetEquipped(pet)
    if not pet then return false end
    local _, seen = getEquippedPetsMapAndList()
    return seen[pet] == true
end

local function formatTimeETA(seconds)
    if seconds == math.huge or seconds < 0 then return "Paused" end
    local days = math.floor(seconds / 86400)
    local hours = math.floor((seconds % 86400) / 3600)
    local mins = math.floor((seconds % 3600) / 60)
    local secs = math.floor(seconds % 60)
    
    if days > 0 then return string.format("%dd %dh %dm", days, hours, mins)
    elseif hours > 0 then return string.format("%dh %dm %ds", hours, mins, secs)
    else return string.format("%dm %ds", mins, secs) end
end

local function getPetData(pet)
    local lvlObj = pet:FindFirstChild("level") or pet:FindFirstChild("Level")
    local xpObj = pet:FindFirstChild("exp") or pet:FindFirstChild("Exp") or pet:FindFirstChild("xp") or pet:FindFirstChild("XP") or pet:FindFirstChild("currentXP")
    local maxObj = pet:FindFirstChild("maxXP") or pet:FindFirstChild("MaxXP") or pet:FindFirstChild("maxExp") or pet:FindFirstChild("xpNeeded") or pet:FindFirstChild("XPNeeded")
    
    local currentLvl = lvlObj and tonumber(lvlObj.Value) or 1
    local currentXp = xpObj and tonumber(xpObj.Value) or 0
    local maxXp = 0
    
    if maxObj and tonumber(maxObj.Value) then
        maxXp = tonumber(maxObj.Value)
    else
        maxXp = math.floor(16.747 * currentLvl)
        if maxXp < 100 then maxXp = 100 end
    end
    return currentLvl, currentXp, maxXp
end

local function getPetCustomName(pet)
    local chosenObj = pet:FindFirstChild("chosenName")
    if chosenObj and chosenObj:IsA("StringValue") and chosenObj.Value ~= "" then
        return chosenObj.Value
    end
    return pet.Name
end

local ROMAN_NUMERALS = {
    {1000, "M"}, {900, "CM"}, {500, "D"}, {400, "CD"},
    {100, "C"}, {90, "XC"}, {50, "L"}, {40, "XL"},
    {10, "X"}, {9, "IX"}, {5, "V"}, {4, "IV"}, {1, "I"}
}

local function toRoman(num)
    if type(num) ~= "number" or num <= 0 then return "" end
    local roman = ""
    for _, v in ipairs(ROMAN_NUMERALS) do
        while num >= v[1] do
            roman = roman .. v[2]
            num = num - v[1]
        end
    end
    return roman
end

local function buildPetDisplayLabel(pet, forceEquipped)
    local lvl = getPetData(pet)
    local baseName = getPetCustomName(pet)
    local eqState = (forceEquipped ~= nil) and forceEquipped or isPetEquipped(pet)
    local eqPrefix = eqState and "[EQ] " or ""
    local displayStr = string.format("%s%s [Lv.%d]", eqPrefix, baseName, lvl)

    local enchantObj = pet:FindFirstChild("enchant") or pet:FindFirstChild("Enchant") or pet:FindFirstChild("enchantment")
    local enchantLvlObj = pet:FindFirstChild("enchantLevel") or pet:FindFirstChild("EnchantLevel") or pet:FindFirstChild("enchantLvl")

    local enchantName = ""
    if enchantObj and enchantObj.Value ~= nil then
        enchantName = tostring(enchantObj.Value)
    else
        local attrEnchant = pet:GetAttribute("enchant") or pet:GetAttribute("Enchant")
        if attrEnchant then enchantName = tostring(attrEnchant) end
    end

    local enchantLvl = 0
    if enchantLvlObj and enchantLvlObj.Value ~= nil then
        enchantLvl = tonumber(enchantLvlObj.Value) or 0
    else
        local attrLvl = pet:GetAttribute("enchantLevel") or pet:GetAttribute("EnchantLevel")
        if attrLvl then enchantLvl = tonumber(attrLvl) or 0 end
    end

    if enchantName ~= "" and enchantName ~= "None" and enchantName ~= "nil" and enchantName ~= "false" then
        local romanLvl = toRoman(enchantLvl)
        if romanLvl ~= "" then
            displayStr = displayStr .. string.format(" [%s %s]", enchantName, romanLvl)
        else
            displayStr = displayStr .. string.format(" [%s]", enchantName)
        end
    end

    return displayStr
end

local TOTAL_CURVE_MINS = 150 * 60
local function getMinsForLevel(lvl)
    return TOTAL_CURVE_MINS * math.pow((lvl - 1) / 349, 2)
end
local MINS_MAX_350 = getMinsForLevel(350)

local function updateTracker(pet)
    if not pet or not pet.Parent then
        levelXpLabel.Text = "Lv. -- | XP: 0 / 0 (0.0%)"
        etaCombinedLabel.Text = "Next: -- | Max (350): --"
        return
    end
    
    local currentLvl, currentXp, maxXp = getPetData(pet)
    local now = os.clock()
    
    if currentLvl ~= petTracker.LastLevel then
        petTracker.History = {}
        petTracker.LastLevel = currentLvl
    end
    
    local lastSample = petTracker.History[#petTracker.History]
    if not lastSample or lastSample.xp ~= currentXp or (now - lastSample.time) >= 1 then
        table.insert(petTracker.History, {xp = currentXp, time = now})
    end

    while #petTracker.History > 0 and (now - petTracker.History[1].time > 30) do
        table.remove(petTracker.History, 1)
    end
    
    local rawXpPerSec = 0
    if #petTracker.History >= 2 then
        local first = petTracker.History[1]
        local last = petTracker.History[#petTracker.History]
        local dt = last.time - first.time
        if dt >= 1.5 then
            rawXpPerSec = (last.xp - first.xp) / dt
        end
    end

    if rawXpPerSec > 0 then
        if petTracker.SmoothedRate <= 0 then
            petTracker.SmoothedRate = rawXpPerSec
        else
            petTracker.SmoothedRate = (petTracker.SmoothedRate * 0.75) + (rawXpPerSec * 0.25)
        end
    elseif #petTracker.History >= 2 then
        local first = petTracker.History[1]
        local last = petTracker.History[#petTracker.History]
        if (last.xp - first.xp) <= 0 and (last.time - first.time) >= 8 then
            petTracker.SmoothedRate = 0
        end
    end

    local xpPerSec = petTracker.SmoothedRate
    
    if currentLvl >= 350 then
        levelXpLabel.Text = "Lv. 350 | XP: MAX LEVEL"
        etaCombinedLabel.Text = "Next: COMPLETED | Max (350): COMPLETED"
        return
    end
    
    local progress = math.clamp(currentXp / math.max(1, maxXp), 0, 1)
    levelXpLabel.Text = string.format("Lv. %d | XP: %s / %s (%.1f%%)", currentLvl, utils.formatWithCommas(currentXp), utils.formatWithCommas(maxXp), progress * 100)
    
    if xpPerSec > 0 then
        local xpNeededNext = math.max(0, maxXp - currentXp)
        local secToNext = xpNeededNext / xpPerSec
        
        local minsCurrent = getMinsForLevel(currentLvl)
        local minsNext = getMinsForLevel(currentLvl + 1)
        
        local minsRemainingCurve = (MINS_MAX_350 - minsCurrent) - (progress * (minsNext - minsCurrent))
        local secToMax = minsRemainingCurve * 60
        
        etaCombinedLabel.Text = string.format("Next: %s | Max (350): %s", formatTimeETA(secToNext), formatTimeETA(secToMax))
    else
        etaCombinedLabel.Text = "Next: Paused | Max (350): Paused"
    end
end

local function bindPetToTracker(pet, isManual)
    if petTracker.ConnectionXP then
        petTracker.ConnectionXP:Disconnect()
        petTracker.ConnectionXP = nil
    end
    if petTracker.ConnectionLvl then
        petTracker.ConnectionLvl:Disconnect()
        petTracker.ConnectionLvl = nil
    end

    petTracker.SelectedPet = pet
    petTracker.ManualSelection = isManual == true
    petTracker.History = {}
    petTracker.SmoothedRate = 0
    petTracker.LastLevel = 0

    if not pet or not pet.Parent then
        levelXpLabel.Text = "Lv. -- | XP: 0 / 0 (0.0%)"
        etaCombinedLabel.Text = "Next: -- | Max (350): --"
        return
    end

    updateTracker(pet)

    local lvlObj = pet:FindFirstChild("level") or pet:FindFirstChild("Level")
    local xpObj = pet:FindFirstChild("exp") or pet:FindFirstChild("Exp") or pet:FindFirstChild("xp") or pet:FindFirstChild("XP") or pet:FindFirstChild("currentXP")

    if xpObj and xpObj:IsA("ValueBase") then
        petTracker.ConnectionXP = xpObj.Changed:Connect(function()
            updateTracker(pet)
        end)
    end
    if lvlObj and lvlObj:IsA("ValueBase") then
        petTracker.ConnectionLvl = lvlObj.Changed:Connect(function()
            updateTracker(pet)
        end)
    end
end

local function selectBestEquippedPet(forceAuto)
    local equippedList = getEquippedPetsMapAndList()
    if #equippedList == 0 then
        if not petTracker.ManualSelection then
            bindPetToTracker(nil, false)
        elseif petTracker.SelectedPet then
            updateTracker(petTracker.SelectedPet)
        end
        return
    end

    local targetPet = nil
    local highestLevelUnderCap = -1
    for _, p in ipairs(equippedList) do
        local lvl = getPetData(p)
        if lvl < 350 and lvl > highestLevelUnderCap then
            highestLevelUnderCap = lvl
            targetPet = p
        end
    end

    if not targetPet then
        targetPet = equippedList[1]
    end

    if forceAuto or not petTracker.ManualSelection or not petTracker.SelectedPet or not petTracker.SelectedPet.Parent or not isPetEquipped(petTracker.SelectedPet) then
        if petTracker.SelectedPet ~= targetPet then
            bindPetToTracker(targetPet, false)
        else
            updateTracker(targetPet)
        end
    end
end

tabs.pets.PetDropdown = tabs.pets:AddDropdown("Select Pet (or Auto-Equipped)", function(displayStr)
    tabs.pets.SelectedDisplay = displayStr
    local pet = tabs.pets.PetMap[displayStr]
    if pet then
        bindPetToTracker(pet, true)
    end
end)

tabs.pets:AddButton("Track Equipped Pet Now", function()
    petTracker.ManualSelection = false
    tabs.pets.refreshPets()
    selectBestEquippedPet(true)
end)

tabs.pets.PetCleaner = {
    AutoDelete = false,
    KeepHighestLevel = true,
    SelectedTypes = {},
    SelectedOrder = {},
    DropdownAdded = {},
    Generation = 0,
    TotalDeleted = 0,
    IsDeleting = false
}

local function deleteSelectedPetTypes(maxBatchSize)
    local cleaner = tabs.pets.PetCleaner
    if cleaner.IsDeleting then
        return 0, nil
    end

    local sellRemote = utils.remotes.SellPetEvent or (rEvents and rEvents:FindFirstChild("sellPetEvent"))
    if not sellRemote then
        return 0, "sellPetEvent no encontrado"
    end

    local petsFolder = lp.player:FindFirstChild("petsFolder")
    if not petsFolder then
        return 0, "petsFolder no encontrado"
    end

    cleaner.IsDeleting = true
    local batchCap = maxBatchSize or 6
    local deletedThisPass = 0

    local okExec, errExec = pcall(function()
        local _, equippedSet = getEquippedPetsMapAndList()

        local grouped = {}
        for _, folder in ipairs(petsFolder:GetChildren()) do
            if folder:IsA("Folder") and folder.Name ~= "Exclusive" then
                for _, pet in ipairs(folder:GetChildren()) do
                    if cleaner.SelectedTypes[pet.Name] and not equippedSet[pet] then
                        local lvlObj = pet:FindFirstChild("level") or pet:FindFirstChild("Level")
                        local lvl = lvlObj and tonumber(lvlObj.Value) or 1
                        grouped[pet.Name] = grouped[pet.Name] or {}
                        table.insert(grouped[pet.Name], { instance = pet, level = lvl })
                    end
                end
            end
        end

        for _, list in pairs(grouped) do
            if deletedThisPass >= batchCap then break end

            if cleaner.KeepHighestLevel and #list > 1 then
                table.sort(list, function(a, b)
                    return a.level < b.level
                end)
            end

            local limit = #list
            if cleaner.KeepHighestLevel and limit > 0 then
                limit = limit - 1
            end

            for i = 1, limit do
                if deletedThisPass >= batchCap then break end
                local targetPet = list[i].instance
                if targetPet and targetPet.Parent then
                    local ok = pcall(sellRemote.FireServer, sellRemote, "sellPet", targetPet)
                    if ok then
                        deletedThisPass = deletedThisPass + 1
                        cleaner.TotalDeleted = cleaner.TotalDeleted + 1
                        task.wait(0.15)
                    end
                end
            end
        end
    end)

    cleaner.IsDeleting = false
    if not okExec then
        return deletedThisPass, tostring(errExec)
    end
    return deletedThisPass, nil
end

tabs.pets:AddLabel("AUTO SELL / DELETE PETS")
tabs.pets.CleanerSelectedLabel = tabs.pets:AddLabel("Delete Selected (0): None")
tabs.pets.CleanerSelectedLabel.TextColor3 = Color3.fromRGB(255, 130, 130)

tabs.pets.updateCleanerSelectedLabel = function()
    local cleaner = tabs.pets.PetCleaner
    local parts = {}
    for _, petType in ipairs(cleaner.SelectedOrder) do
        if cleaner.SelectedTypes[petType] then
            table.insert(parts, petType)
        end
    end
    if #parts == 0 then
        tabs.pets.CleanerSelectedLabel.Text = "Delete Selected (0): None"
    else
        tabs.pets.CleanerSelectedLabel.Text = string.format("Delete Selected (%d): %s", #parts, table.concat(parts, ", "))
    end
end

tabs.pets.CleanerDropdown = tabs.pets:AddDropdown("Select Pet Type to Delete (Multi)", function(selection)
    local cleaner = tabs.pets.PetCleaner
    if not selection or selection == "" then return end
    local petType = selection:match("^(.-)%s*%(%d+%)$") or selection

    if cleaner.SelectedTypes[petType] then
        cleaner.SelectedTypes[petType] = nil
        for i = #cleaner.SelectedOrder, 1, -1 do
            if cleaner.SelectedOrder[i] == petType then
                table.remove(cleaner.SelectedOrder, i)
            end
        end
    else
        cleaner.SelectedTypes[petType] = true
        table.insert(cleaner.SelectedOrder, petType)
    end
    tabs.pets.updateCleanerSelectedLabel()
end)

tabs.pets.refreshPets = function()
    pcall(function()
        if tabs.pets.PetDropdown.Clear then
            tabs.pets.PetDropdown:Clear()
        end
    end)

    local cleanerCleared = false
    pcall(function()
        if tabs.pets.CleanerDropdown.Clear then
            tabs.pets.CleanerDropdown:Clear()
            cleanerCleared = true
        end
    end)
    if cleanerCleared then
        tabs.pets.PetCleaner.DropdownAdded = {}
    end
    
    tabs.pets.PetMap = {}
    tabs.pets.PetToDisplay = {}
    local typeCounts = {}
    local equippedPets = {}
    local unequippedPets = {}
    local seenPets = {}
    local _, equippedSet = getEquippedPetsMapAndList()
    
    local petsFolder = lp.player:FindFirstChild("petsFolder")
    if petsFolder then
        for _, folder in ipairs(petsFolder:GetChildren()) do
            if folder:IsA("Folder") then
                for _, pet in ipairs(folder:GetChildren()) do
                    if not seenPets[pet] then
                        seenPets[pet] = true
                        if folder.Name ~= "Exclusive" then
                            typeCounts[pet.Name] = (typeCounts[pet.Name] or 0) + 1
                        end
                        local isEq = equippedSet[pet] == true
                        local lvl = getPetData(pet)
                        local displayStr = buildPetDisplayLabel(pet, isEq)
                        local entry = {
                            pet = pet,
                            equipped = isEq,
                            level = lvl,
                            displayStr = displayStr
                        }
                        if isEq then
                            table.insert(equippedPets, entry)
                        else
                            table.insert(unequippedPets, entry)
                        end
                    end
                end
            end
        end
    end

    local function sortByLevelAndName(a, b)
        if a.level ~= b.level then
            return a.level > b.level
        end
        return a.displayStr < b.displayStr
    end

    table.sort(equippedPets, sortByLevelAndName)
    table.sort(unequippedPets, sortByLevelAndName)

    local function registerDropdownEntry(entry)
        local pet = entry.pet
        local displayStr = entry.displayStr
        if tabs.pets.PetMap[displayStr] then
            local count = 2
            while tabs.pets.PetMap[displayStr .. " (" .. count .. ")"] do
                count = count + 1
            end
            displayStr = displayStr .. " (" .. count .. ")"
        end
        tabs.pets.PetMap[displayStr] = pet
        tabs.pets.PetToDisplay[pet] = displayStr
        pcall(function() tabs.pets.PetDropdown:Add(displayStr) end)
    end

    for _, entry in ipairs(equippedPets) do
        registerDropdownEntry(entry)
    end
    for _, entry in ipairs(unequippedPets) do
        registerDropdownEntry(entry)
    end

    local sortedTypes = {}
    for petType in pairs(typeCounts) do
        table.insert(sortedTypes, petType)
    end
    table.sort(sortedTypes)

    for _, petType in ipairs(sortedTypes) do
        if not tabs.pets.PetCleaner.DropdownAdded[petType] then
            tabs.pets.PetCleaner.DropdownAdded[petType] = true
            local labelStr = string.format("%s (%d)", petType, typeCounts[petType])
            pcall(function() tabs.pets.CleanerDropdown:Add(labelStr) end)
        end
    end
    tabs.pets.updateCleanerSelectedLabel()
end

tabs.pets:AddButton("Refresh Owned Pets", function()
    tabs.pets.refreshPets()
end)

tabs.pets:AddButton("Clear Delete Selection", function()
    local cleaner = tabs.pets.PetCleaner
    cleaner.SelectedTypes = {}
    cleaner.SelectedOrder = {}
    tabs.pets.updateCleanerSelectedLabel()
end)

tabs.pets:AddSwitch("Keep Highest Level Pet", function(state)
    tabs.pets.PetCleaner.KeepHighestLevel = state
end):Set(true)

tabs.pets.CleanerStatusLabel = tabs.pets:AddLabel("")
hideStatus(tabs.pets.CleanerStatusLabel)

tabs.pets:AddButton("Delete Selected Pets Now", function()
    task.spawn(function()
        local count, err = deleteSelectedPetTypes(15)
        if err then
            showErrorStatus(tabs.pets.CleanerStatusLabel, err)
        else
            tabs.pets.CleanerStatusLabel.Text = string.format("Deleted: %d pets (Total: %d)", count, tabs.pets.PetCleaner.TotalDeleted)
            tabs.pets.CleanerStatusLabel.TextColor3 = COLOR_OK
            tabs.pets.CleanerStatusLabel.Visible = true
        end
    end)
end)

tabs.pets:AddSwitch("Auto Delete Selected Pets", function(state)
    local cleaner = tabs.pets.PetCleaner
    cleaner.AutoDelete = state
    cleaner.Generation = cleaner.Generation + 1
    local gen = cleaner.Generation

    if not state then
        hideStatus(tabs.pets.CleanerStatusLabel)
        return
    end

    task.spawn(function()
        while utils.isCurrent() and cleaner.AutoDelete and cleaner.Generation == gen do
            local hasSelection = next(cleaner.SelectedTypes) ~= nil

            if not hasSelection then
                showErrorStatus(tabs.pets.CleanerStatusLabel, "Selecciona al menos 1 tipo de pet")
                task.wait(2)
            else
                local count, err = deleteSelectedPetTypes(6)
                if err then
                    showErrorStatus(tabs.pets.CleanerStatusLabel, err)
                else
                    tabs.pets.CleanerStatusLabel.Text = string.format("Auto Delete Active | Deleted: %d", cleaner.TotalDeleted)
                    tabs.pets.CleanerStatusLabel.TextColor3 = COLOR_OK
                    tabs.pets.CleanerStatusLabel.Visible = true
                end
                task.wait(count > 0 and 2.5 or 3.5)
            end
        end
    end)
end):Set(false)

-- Escuchar cambios en equippedPets en tiempo real
pcall(function()
    local equippedFolder = lp.player:WaitForChild("equippedPets", 10)
    if equippedFolder then
        local hookedSlots = setmetatable({}, {__mode = "k"})
        local function onEquipChanged()
            task.delay(0.15, function()
                if utils.isCurrent() then
                    tabs.pets.refreshPets()
                    selectBestEquippedPet(false)
                end
            end)
        end

        local function hookSlot(slot)
            if not slot or hookedSlots[slot] then return end
            hookedSlots[slot] = true
            if slot:IsA("ObjectValue") then
                utils.connect(slot.Changed, onEquipChanged)
            end
            for _, desc in ipairs(slot:GetDescendants()) do
                if desc:IsA("ObjectValue") and not hookedSlots[desc] then
                    hookedSlots[desc] = true
                    utils.connect(desc.Changed, onEquipChanged)
                end
            end
        end

        utils.connect(equippedFolder.ChildAdded, function(child)
            onEquipChanged()
            hookSlot(child)
        end)
        utils.connect(equippedFolder.ChildRemoved, onEquipChanged)

        for _, slot in ipairs(equippedFolder:GetChildren()) do
            hookSlot(slot)
        end
    end
end)

-- Bucle de respaldo cada 1s para mantener actualizado el cálculo y detectar cambios de [EQ]
local lastEquippedMap = {}
task.spawn(function()
    while utils.isCurrent() do
        local eqList, eqMap = getEquippedPetsMapAndList()
        local changed = false
        for petInst in pairs(eqMap) do
            if not lastEquippedMap[petInst] then
                changed = true
                break
            end
        end
        if not changed then
            for petInst in pairs(lastEquippedMap) do
                if not eqMap[petInst] then
                    changed = true
                    break
                end
            end
        end

        if changed then
            lastEquippedMap = eqMap
            tabs.pets.refreshPets()
        end

        if not petTracker.SelectedPet or not petTracker.SelectedPet.Parent or (not petTracker.ManualSelection and not eqMap[petTracker.SelectedPet]) then
            selectBestEquippedPet(false)
        elseif petTracker.SelectedPet then
            updateTracker(petTracker.SelectedPet)
        end
        task.wait(1)
    end
end)

task.delay(1.5, function()
    tabs.pets.refreshPets()
    selectBestEquippedPet(true)
end)

-- ==========================================
-- TAB: UTIL (UTILIDADES Y AJUSTES)
-- ==========================================
tabs.other:AddLabel("PROTECTION")
local protection = { AntiFling = false, PositionLock = false, LockedPos = nil }

local function applyAntiFling(char)
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    if hrp:FindFirstChild("ProyectadosAntiFling") then hrp.ProyectadosAntiFling:Destroy() end
    if protection.AntiFling then
        local bv = Instance.new("BodyVelocity")
        bv.Name = "ProyectadosAntiFling"
        bv.MaxForce = Vector3.new(100000, 0, 100000)
        bv.Velocity = Vector3.zero
        bv.P = 1250
        bv.Parent = hrp
    end
end

tabs.other:AddSwitch("Anti Fling", function(state)
    protection.AntiFling = state
    applyAntiFling(lp.player.Character)
end):Set(false)

tabs.other:AddSwitch("Lock Position", function(state)
    protection.PositionLock = state
    local char = lp.player.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    if state and hrp then
        protection.LockedPos = hrp.Position
        protection.AntiFling = true
        applyAntiFling(char)
        
        if not hrp:FindFirstChild("ProyectadosPosLock") then
            local bp = Instance.new("BodyPosition")
            bp.Name = "ProyectadosPosLock"
            bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            bp.Position = protection.LockedPos
            bp.P = 100000
            bp.Parent = hrp
        end
    else
        if hrp and hrp:FindFirstChild("ProyectadosPosLock") then
            hrp.ProyectadosPosLock:Destroy()
        end
        protection.LockedPos = nil
    end
end)

utils.connect(lp.player.CharacterAdded, function(newChar)
    local hrp = newChar:WaitForChild("HumanoidRootPart", 5)
    if protection.AntiFling then applyAntiFling(newChar) end
    if protection.PositionLock and protection.LockedPos and hrp then
        local bp = Instance.new("BodyPosition")
        bp.Name = "ProyectadosPosLock"
        bp.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bp.Position = protection.LockedPos
        bp.P = 100000
        bp.Parent = hrp
    end
end)

tabs.other:AddLabel("RECONNECT SYSTEM")
tabs.other.Reconnect = {Enabled = false, Disconnected = false, NextAttemptAt = 0, Attempting = false, LinkText = ""}

tabs.other:AddTextBox("Private Server Link (optional)", function(text)
    tabs.other.Reconnect.LinkText = text
end, {clear = false})

local function getReconnectUrl(text)
    text = tostring(text or ""):match("^%s*(.-)%s*$")
    if text == "" then return nil end
    local host, path = text:match("^https?://([^/]+)(/.*)$")
    if host ~= "roblox.com" and host ~= "www.roblox.com" then return nil, "Enter a Roblox private server link" end
    local code = path:match("[?&]privateServerLinkCode=([%w_-]+)")
    if code then
        local placeId = tonumber(path:match("^/games/(%d+)"))
        if placeId ~= game.PlaceId then return nil, "Link must be for this game" end
        return "roblox://placeId=" .. tostring(placeId) .. "&linkCode=" .. code
    end
    code = path:match("[?&]code=([%w_-]+)")
    local linkType = path:match("[?&]type=([^&#]+)")
    if path:match("^/share%?") and code and linkType == "Server" then
        return "roblox://navigation/share_links?code=" .. code .. "&type=Server"
    end
    return nil, "Invalid private server link"
end

tabs.other.checkDisconnect = function()
    if not tabs.other.Reconnect.Enabled or tabs.other.Reconnect.Disconnected then return end
    local success, disconnected = pcall(function()
        local code = services.GuiService:GetErrorCode()
        return services.GuiService:GetErrorMessage() ~= "" and (
            services.GuiService:GetErrorType() == Enum.ConnectionError.DisconnectErrors
            or (code >= 256 and code < 512)
            or code >= 1024
        )
    end)
    if not success then
        local readable, visible = pcall(function()
            local promptGui = services.CoreGui:FindFirstChild("RobloxPromptGui")
            local overlay = promptGui and promptGui:FindFirstChild("promptOverlay")
            local prompt = overlay and overlay:FindFirstChild("ErrorPrompt")
            return prompt and prompt.Visible and prompt:FindFirstChild("ErrorFrame", true) ~= nil
        end)
        success, disconnected = readable, visible
    end
    if success and disconnected then
        tabs.other.Reconnect.Disconnected = true
        tabs.other.Reconnect.NextAttemptAt = os.clock() + 5
    end
end

tabs.other:AddSwitch("Auto Reconnect", function(state)
    tabs.other.Reconnect.Enabled = state
    tabs.other.Reconnect.Disconnected = false
    tabs.other.Reconnect.NextAttemptAt = 0
    if state then tabs.other.checkDisconnect() end
end):Set(false)

pcall(function()
    utils.connect(services.GuiService.ErrorMessageChanged, tabs.other.checkDisconnect)
end)

task.spawn(function()
    while utils.isCurrent() do
        if tabs.other.Reconnect.Enabled then
            tabs.other.checkDisconnect()
            local rec = tabs.other.Reconnect
            local now = os.clock()
            if rec.Disconnected and not rec.Attempting and now >= rec.NextAttemptAt then
                rec.Attempting = true
                rec.NextAttemptAt = now + 30
                pcall(function()
                    local url = getReconnectUrl(rec.LinkText)
                    if url then
                        services.LinkingService:OpenUrl(url)
                    else
                        if not pcall(function() services.TeleportService:TeleportReconnect() end) then
                            services.TeleportService:Teleport(game.PlaceId, lp.player)
                        end
                    end
                end)
                rec.Attempting = false
            end
        end
        task.wait(1)
    end
end)

tabs.other:AddLabel("WORLD")
tabs.other:AddSwitch("Walk on Water", function(state)
    if state then
        if not services.Workspace:FindFirstChild("ProyectadosWaterPart") then
            local water = Instance.new("Part")
            water.Name = "ProyectadosWaterPart"
            water.Size = Vector3.new(2048, 1, 2048)
            water.Position = Vector3.new(-2, -9.5, -2)
            water.Anchored = true
            water.Transparency = 1
            water.CanCollide = true
            water.Parent = services.Workspace
        end
    else
        local water = services.Workspace:FindFirstChild("ProyectadosWaterPart")
        if water then water:Destroy() end
    end
end):Set(false)

tabs.other:AddLabel("PERFORMANCE")
tabs.other:AddSwitch("Hide Pets", function(state)
    local showPetsEvent = utils.remotes.ShowPetsEvent or (rEvents and rEvents:WaitForChild("showPetsEvent"))
    if showPetsEvent then
        showPetsEvent:FireServer(state and "hidePets" or "showPets")
    end
end):Set(true)

tabs.other:AddButton("Anti Lag", function()
    task.spawn(function()
        pcall(function()
            services.Lighting.Brightness = 0
            services.Lighting.GlobalShadows = false
            services.Lighting.FogEnd = 9e9
            for _, v in ipairs(services.Lighting:GetChildren()) do
                if v:IsA("Sky") or v:IsA("Atmosphere") or v:IsA("BloomEffect") or v:IsA("BlurEffect") or v:IsA("ColorCorrectionEffect") or v:IsA("SunRaysEffect") then
                    v:Destroy()
                end
            end
            
            workspace.Terrain.WaterTransparency = 1
            workspace.Terrain.WaterWaveSize = 0
            workspace.Terrain.WaterWaveSpeed = 0
            
            local descendants = workspace:GetDescendants()
            for i, obj in ipairs(descendants) do
                if obj:IsA("BasePart") then
                    obj.Material = Enum.Material.SmoothPlastic
                    obj.Reflectance = 0
                    obj.CastShadow = false
                elseif obj:IsA("Decal") or obj:IsA("Texture") then
                    obj.Transparency = 1
                elseif obj:IsA("ParticleEmitter") or obj:IsA("PointLight") or obj:IsA("SpotLight") or obj:IsA("SurfaceLight") or obj:IsA("Trail") then
                    obj:Destroy()
                end
                if i % 400 == 0 then
                    task.wait()
                end
            end
        end)
    end)
end)

tabs.other:AddSwitch("Low Power Mode (Blackscreen)", function(state)
    local runService = services.RunService
    if state then
        _G.BlackscreenActive = true
        if not _G.BlackscreenGui then
            local sg = Instance.new("ScreenGui")
            sg.IgnoreGuiInset = true
            sg.DisplayOrder = -100
            sg.Parent = services.CoreGui
            
            local frame = Instance.new("Frame")
            frame.Size = UDim2.new(1, 0, 1, 0)
            frame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            frame.Parent = sg

            local text = Instance.new("TextLabel")
            text.Size = UDim2.new(1, 0, 1, 0)
            text.BackgroundTransparency = 1
            text.TextColor3 = Color3.fromRGB(138, 43, 226)
            text.Text = "PROYECTADOS HUB | LOW POWER MODE ACTIVO"
            text.Font = Enum.Font.GothamBold
            text.TextSize = 24
            text.Parent = frame

            _G.BlackscreenGui = sg
        end
        runService:Set3dRenderingEnabled(false)
    else
        _G.BlackscreenActive = false
        if _G.BlackscreenGui then
            _G.BlackscreenGui:Destroy()
            _G.BlackscreenGui = nil
        end
        runService:Set3dRenderingEnabled(true)
    end
end):Set(false)

tabs.other:AddLabel("PRIVACY")
tabs.other:AddSwitch("Hide Name", function(state) privacyRedactor:SetNameEnabled(state) end):Set(true)
tabs.other:AddSwitch("Hide UI Stats", function(state) privacyRedactor:SetStatsEnabled(state) end):Set(false)

tabs.other:AddLabel("TELEPORTS")
tabs.other:AddButton("Industrial Lift", function() utils.tpE(Vector3.new(-5491.68945, 81.2379913, 4643.85791)) end)
tabs.other:AddButton("Industrial Squat", function() utils.tpE(Vector3.new(-5217.25049, 89.8445511, 5416.01025)) end)
tabs.other:AddButton("Snow Lift", function() utils.tpE(Vector3.new(-5374, 71, 10321)) end)
tabs.other:AddButton("Snow Squat", function() utils.tpE(Vector3.new(-5099, 76, 11096)) end)

-- ==========================================
-- TAB: INFO
-- ==========================================
tabs.info:Show()
tabs.info:AddLabel("CREDITS")
tabs.info:AddLabel("Proyectados Hub V3 (Test) - By Horarybrech")
tabs.info.VersionLabel = tabs.info:AddLabel("Muscle Legends")
tabs.info.VersionLabel.TextSize = 20
tabs.info.VersionLabel.Font = Enum.Font.Arcade
