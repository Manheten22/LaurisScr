

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")

-- Константы для телепортации
local currentPlaceId = game.PlaceId
local menuplaceId = 10290054819
local maingameId = 99995671928896

-- Настройка уведомлений
local function notify(title, text)
    StarterGui:SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = 10
    })
end

local LocalPlayer = Players.LocalPlayer
local BossList = {
    "Dire Bear", 
    "Mother Spider", 
    "Elder Treant", 
    "Rune Golem", 
    "The Goblin King", 
    "Licht King"
}

local BossNameMap = {
    ["Eight-Handled Sword Divergent Sila Divine General Mahoraga"] = "Mahoraga",
    ["The Vessel"] = "Itadori"
}

-- Система состояний
local autofarming = false
local currentTab = "bosses"
local Active = true
local selectedBoss = nil

local eventCooldown = {
    added = {},
    removed = {}
}

local activeBosses = {}
local initialCheckDone = false



-- Тема интерфейса
local Theme = {
    Background = Color3.fromRGB(30, 30, 30),
    Topbar = Color3.fromRGB(45, 45, 45),
    ElementBackground = Color3.fromRGB(40, 40, 40),
    TextColor = Color3.fromRGB(240, 240, 240),
    AccentColor = Color3.fromRGB(0, 146, 214),
    ExitColor = Color3.fromRGB(200, 50, 50),
    StrokeColor = Color3.fromRGB(20, 20, 20)
}

---------------------------
-- Создание интерфейса --
---------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BossTrackerUI"
ScreenGui.Parent = CoreGui
ScreenGui.Enabled = false

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 320, 0, 400)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -200)
MainFrame.BackgroundColor3 = Theme.Background
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui

local mainUICorner = Instance.new("UICorner")
mainUICorner.CornerRadius = UDim.new(0, 10)
mainUICorner.Parent = MainFrame

-- Верхняя панель
local TopBar = Instance.new("Frame")
TopBar.Size = UDim2.new(1, 0, 0, 40)
TopBar.BackgroundColor3 = Theme.Topbar
TopBar.BorderSizePixel = 0
TopBar.Parent = MainFrame

local topBarUICorner = Instance.new("UICorner")
topBarUICorner.CornerRadius = UDim.new(0, 10)
topBarUICorner.Parent = TopBar

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0.4, 0, 1, 0)
Title.Position = UDim2.new(0, 10, 0, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Theme.TextColor
Title.Text = "BOSS TRACKER"
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = TopBar

-- Кнопка закрытия
local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 24, 0, 24)
CloseButton.Position = UDim2.new(1, -30, 0.5, -12)
CloseButton.BackgroundColor3 = Theme.ExitColor
CloseButton.TextColor3 = Color3.new(1, 1, 1)
CloseButton.Text = "×"
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 24
CloseButton.Parent = TopBar

local closeBtnUICorner = Instance.new("UICorner")
closeBtnUICorner.CornerRadius = UDim.new(0, 6)
closeBtnUICorner.Parent = CloseButton

-- Вкладки
local TabButtonsContainer = Instance.new("Frame")
TabButtonsContainer.Size = UDim2.new(1, 0, 0, 40)
TabButtonsContainer.Position = UDim2.new(0, 0, 0, 40)
TabButtonsContainer.BackgroundTransparency = 1
TabButtonsContainer.Parent = MainFrame

local UIListLayout_Tabs = Instance.new("UIListLayout")
UIListLayout_Tabs.FillDirection = Enum.FillDirection.Horizontal
UIListLayout_Tabs.Padding = UDim.new(0, 5)
UIListLayout_Tabs.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout_Tabs.Parent = TabButtonsContainer

local BossesTabButton = Instance.new("TextButton")
BossesTabButton.Size = UDim2.new(0, 80, 0, 30)
BossesTabButton.BackgroundColor3 = Theme.AccentColor
BossesTabButton.TextColor3 = Color3.new(1, 1, 1)
BossesTabButton.Text = "BOSSES"
BossesTabButton.Font = Enum.Font.GothamBold
BossesTabButton.TextSize = 14
BossesTabButton.Parent = TabButtonsContainer

local tabBtnUICorner1 = Instance.new("UICorner")
tabBtnUICorner1.CornerRadius = UDim.new(0, 6)
tabBtnUICorner1.Parent = BossesTabButton



local AutoFarmTabButton = Instance.new("TextButton")
AutoFarmTabButton.Size = UDim2.new(0, 80, 0, 30)
AutoFarmTabButton.BackgroundColor3 = Theme.ElementBackground
AutoFarmTabButton.TextColor3 = Theme.TextColor
AutoFarmTabButton.Text = "AUTOFARM"
AutoFarmTabButton.Font = Enum.Font.GothamBold
AutoFarmTabButton.TextSize = 14
AutoFarmTabButton.Parent = TabButtonsContainer

local tabBtnUICorner2 = Instance.new("UICorner")
tabBtnUICorner2.CornerRadius = UDim.new(0, 6)
tabBtnUICorner2.Parent = AutoFarmTabButton



local VisualTabButton = Instance.new("TextButton")
VisualTabButton.Size = UDim2.new(0, 80, 0, 30)
VisualTabButton.BackgroundColor3 = Theme.ElementBackground
VisualTabButton.TextColor3 = Theme.TextColor
VisualTabButton.Text = "VISUAL"
VisualTabButton.Font = Enum.Font.GothamBold
VisualTabButton.TextSize = 14
VisualTabButton.Parent = TabButtonsContainer

local tabBtnUICorner2 = Instance.new("UICorner")
tabBtnUICorner2.CornerRadius = UDim.new(0, 6)
tabBtnUICorner2.Parent = VisualTabButton


-- Контент
local ContentFrame = Instance.new("ScrollingFrame")
ContentFrame.Size = UDim2.new(1, -10, 1, -110)
ContentFrame.Position = UDim2.new(0, 5, 0, 80)
ContentFrame.BackgroundTransparency = 1
ContentFrame.ScrollBarThickness = 4
ContentFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
ContentFrame.Parent = MainFrame

local AutoFarmFrame = Instance.new("Frame")
AutoFarmFrame.Size = UDim2.new(1, -10, 1, -110)
AutoFarmFrame.Position = UDim2.new(0, 5, 0, 80)
AutoFarmFrame.BackgroundTransparency = 1
AutoFarmFrame.Visible = false
AutoFarmFrame.Parent = MainFrame

local VisualFrame = Instance.new("Frame")
VisualFrame.Size = UDim2.new(1, -10, 1, -110)
VisualFrame.Position = UDim2.new(0, 5, 0, 80)
VisualFrame.BackgroundTransparency = 1
VisualFrame.Visible = false
VisualFrame.Parent = MainFrame

-- Элементы автопарма
local AutoFarmButton = Instance.new("TextButton")
AutoFarmButton.Size = UDim2.new(1, -20, 0, 40)
AutoFarmButton.Position = UDim2.new(0, 10, 0, 10)
AutoFarmButton.BackgroundColor3 = Theme.AccentColor
AutoFarmButton.TextColor3 = Color3.new(1, 1, 1)
AutoFarmButton.Text = "START AUTOFARM"
AutoFarmButton.Font = Enum.Font.GothamBold
AutoFarmButton.TextSize = 16
AutoFarmButton.Parent = AutoFarmFrame

local autoFarmUICorner = Instance.new("UICorner")
autoFarmUICorner.CornerRadius = UDim.new(0, 6)
autoFarmUICorner.Parent = AutoFarmButton

--Mobs ESP кнопка
local espMobsButton = Instance.new("TextButton")
espMobsButton.Size = UDim2.new(1, -20, 0, 40)
espMobsButton.Position = UDim2.new(0, 10, 0, 10)
espMobsButton.BackgroundColor3 = Theme.ElementBackground
espMobsButton.TextColor3 = Theme.TextColor
espMobsButton.Text = "MOBS ESP"
espMobsButton.Font = Enum.Font.GothamBold
espMobsButton.TextSize = 16
espMobsButton.Parent = VisualFrame

local espMobsUICorner = Instance.new("UICorner")
espMobsUICorner.CornerRadius = UDim.new(0, 6)
espMobsUICorner.Parent = espMobsButton

--Player ESP кнопка
local espPlayerButton = Instance.new("TextButton")
espPlayerButton.Size = UDim2.new(1, -20, 0, 40)
espPlayerButton.Position = UDim2.new(0, 10, 0, 60)
espPlayerButton.BackgroundColor3 = Theme.ElementBackground
espPlayerButton.TextColor3 = Theme.TextColor
espPlayerButton.Text = "Player ESP"
espPlayerButton.Font = Enum.Font.GothamBold
espPlayerButton.TextSize = 16
espPlayerButton.Parent = VisualFrame

local espPlayerUICorner = Instance.new("UICorner")
espPlayerUICorner.CornerRadius = UDim.new(0, 6)
espPlayerUICorner.Parent = espPlayerButton

--PlayerUID кнопка
local playerUidButton = Instance.new("TextButton")
playerUidButton.Size = UDim2.new(1, -20, 0, 35)
playerUidButton.Position = UDim2.new(0, 10, 0, 110)
playerUidButton.BackgroundColor3 = Theme.ElementBackground
playerUidButton.TextColor3 = Theme.TextColor
playerUidButton.Text = "Player UID"
playerUidButton.Font = Enum.Font.Gotham
playerUidButton.TextSize = 14
playerUidButton.Parent = VisualFrame

local playerdUidUICorner = Instance.new("UICorner")
playerdUidUICorner.CornerRadius = UDim.new(0, 6)
playerdUidUICorner.Parent = playerUidButton

--PlayerUID кнопка
local flyButton = Instance.new("TextButton")
flyButton.Size = UDim2.new(1, -20, 0, 35)
flyButton.Position = UDim2.new(0, 10, 0, 150)
flyButton.BackgroundColor3 = Theme.ElementBackground
flyButton.TextColor3 = Theme.TextColor
flyButton.Text = "Fly on H button"
flyButton.Font = Enum.Font.Gotham
flyButton.TextSize = 14
flyButton.Parent = VisualFrame

local flyUICorner = Instance.new("UICorner")
flyUICorner.CornerRadius = UDim.new(0, 6)
flyUICorner.Parent = flyButton

-- Выпадающий список
local DropdownToggle = Instance.new("TextButton")
local DropdownFrame = Instance.new("Frame")
local ScrollingFrame = Instance.new("ScrollingFrame")

local function CreateDropdown()
    -- Кнопка выбора босса
    DropdownToggle.Name = "BossDropdownToggle"
    DropdownToggle.Size = UDim2.new(1, -20, 0, 35)
    DropdownToggle.Position = UDim2.new(0, 10, 0, 60)
    DropdownToggle.BackgroundColor3 = Theme.ElementBackground
    DropdownToggle.TextColor3 = Theme.TextColor
    DropdownToggle.Text = "Select Boss"
    DropdownToggle.Font = Enum.Font.Gotham
    DropdownToggle.TextSize = 14
    DropdownToggle.Parent = AutoFarmFrame

    local toggleCorner = Instance.new("UICorner")
    toggleCorner.CornerRadius = UDim.new(0, 6)
    toggleCorner.Parent = DropdownToggle

    -- Фрейм списка
    DropdownFrame.Name = "BossDropdown"
    DropdownFrame.Size = UDim2.new(1, -20, 0, 150)
    DropdownFrame.Position = UDim2.new(0, 10, 0, DropdownToggle.Position.Y.Offset + DropdownToggle.Size.Y.Offset + 5)
    DropdownFrame.BackgroundColor3 = Theme.ElementBackground
    DropdownFrame.Visible = false
    DropdownFrame.Parent = AutoFarmFrame

    local dropdownCorner = Instance.new("UICorner")
    dropdownCorner.CornerRadius = UDim.new(0, 6)
    dropdownCorner.Parent = DropdownFrame

    -- Область прокрутки
    ScrollingFrame.Name = "ScrollFrame"
    ScrollingFrame.Size = UDim2.new(1, -5, 1, -5)
    ScrollingFrame.Position = UDim2.new(0, 5, 0, 5)
    ScrollingFrame.BackgroundTransparency = 1
    ScrollingFrame.ScrollBarThickness = 4
    ScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ScrollingFrame.Parent = DropdownFrame

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 5)
    listLayout.Parent = ScrollingFrame

    -- Заполнение списка
    for _, bossName in ipairs(BossList) do
        local displayName = BossNameMap[bossName] or bossName
        local optionButton = Instance.new("TextButton")
        optionButton.Size = UDim2.new(1, -10, 0, 30)
        optionButton.BackgroundColor3 = Theme.ElementBackground
        optionButton.TextColor3 = Theme.TextColor
        optionButton.Text = displayName
        optionButton.Font = Enum.Font.Gotham
        optionButton.TextSize = 14
        optionButton.Parent = ScrollingFrame

        local optionCorner = Instance.new("UICorner")
        optionCorner.CornerRadius = UDim.new(0, 4)
        optionCorner.Parent = optionButton

        optionButton.MouseButton1Click:Connect(function()
            DropdownToggle.Text = displayName
            selectedBoss = bossName
            DropdownFrame.Visible = false
        end)
    end

    -- Управление видимостью
    DropdownToggle.MouseButton1Click:Connect(function()
        DropdownFrame.Visible = not DropdownFrame.Visible
        if DropdownFrame.Visible then
            ScrollingFrame.CanvasPosition = Vector2.new(0, 0)
        end
    end)
end

CreateDropdown()

-- Шаблон записи о боссе
local BossEntryTemplate = Instance.new("Frame")
BossEntryTemplate.Size = UDim2.new(1, 0, 0, 40)
BossEntryTemplate.BackgroundColor3 = Theme.ElementBackground
BossEntryTemplate.BorderSizePixel = 0
BossEntryTemplate.Visible = false
BossEntryTemplate.Parent = ContentFrame

local entryUICorner = Instance.new("UICorner")
entryUICorner.CornerRadius = UDim.new(0, 6)
entryUICorner.Parent = BossEntryTemplate

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Theme.StrokeColor
UIStroke.Thickness = 1
UIStroke.Parent = BossEntryTemplate

local BossName = Instance.new("TextLabel")
BossName.Name = "BossName"
BossName.Size = UDim2.new(0.7, -10, 1, 0)
BossName.Position = UDim2.new(0, 10, 0, 0)
BossName.BackgroundTransparency = 1
BossName.TextColor3 = Theme.TextColor
BossName.Font = Enum.Font.Gotham
BossName.TextSize = 14
BossName.TextXAlignment = Enum.TextXAlignment.Left
BossName.Parent = BossEntryTemplate

local StatusIndicator = Instance.new("TextLabel")
StatusIndicator.Name = "Status"
StatusIndicator.Size = UDim2.new(0.3, -10, 1, 0)
StatusIndicator.Position = UDim2.new(0.7, 0, 0, 0)
StatusIndicator.BackgroundTransparency = 1
StatusIndicator.Font = Enum.Font.GothamBold
StatusIndicator.TextSize = 18
StatusIndicator.TextXAlignment = Enum.TextXAlignment.Right
StatusIndicator.Parent = BossEntryTemplate

local ExitButton = Instance.new("TextButton")
ExitButton.Size = UDim2.new(1, -20, 0, 40)
ExitButton.Position = UDim2.new(0, 10, 1, -50)
ExitButton.BackgroundColor3 = Theme.ExitColor
ExitButton.TextColor3 = Color3.new(1, 1, 1)
ExitButton.Text = "EXIT"
ExitButton.Font = Enum.Font.GothamBold
ExitButton.TextSize = 16
ExitButton.Parent = MainFrame



---------------------------------
-- Логика перетаскивания окна --
---------------------------------
local dragging = false
local dragStart, startPos

TopBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
    end
end)


local ESP = {
    Enabled = {
        Mobs = false,
        Players = false
    },
    Connections = {},
    Folders = {
        Mobs = {},
        Players = {}
    },
    Handlers = {
        MobAdded = nil,
        PlayerAdded = nil
    },
    Settings = {
        MobColor = Color3.new(1, 0.2, 0.2),
        PlayerColor = Color3.new(0.2, 0.6, 1),
        TextSize = 14,
        MaxDistance = 10000
    }
}

-- Utility functions
local function CreateAdornment(part, color)
    local adornment = Instance.new("BoxHandleAdornment")
    adornment.Adornee = part
    adornment.AlwaysOnTop = true
    adornment.ZIndex = 1
    adornment.Size = part.Size
    adornment.Transparency = 0.5
    adornment.Color3 = color
    return adornment
end

local function CreateBillboard(text)
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Font = Enum.Font.GothamBold
    textLabel.TextSize = ESP.Settings.TextSize
    textLabel.TextColor3 = Color3.new(1, 1, 1)
    textLabel.TextStrokeTransparency = 0.5
    textLabel.TextYAlignment = Enum.TextYAlignment.Bottom
    textLabel.Text = text
    textLabel.Parent = billboard
    
    return billboard
end

-- Core ESP functions
function ESP.ToggleMobs(enable)
    ESP.Enabled.Mobs = enable
    espMobsButton.BackgroundColor3 = enable and Theme.AccentColor or Theme.ElementBackground

    if enable then
        -- Process existing mobs
        for _, mob in ipairs(Workspace.Entities:GetChildren()) do
            if mob:GetAttribute("NPC") then
                ESP.AddMobESP(mob)
            end
        end
        
        -- Connect new mobs
        ESP.Handlers.MobAdded = Workspace.Entities.ChildAdded:Connect(function(mob)
            if mob:GetAttribute("NPC") then
                ESP.AddMobESP(mob)
            end
        end)
    else
        -- Cleanup mob ESP
        for _, folder in pairs(ESP.Folders.Mobs) do
            folder:Destroy()
        end
        table.clear(ESP.Folders.Mobs)
        
        if ESP.Handlers.MobAdded then
            ESP.Handlers.MobAdded:Disconnect()
        end
    end
end

function ESP.AddMobESP(mob)
    if not ESP.Enabled.Mobs or ESP.Folders.Mobs[mob] then return end
    
    local holder = Instance.new("Folder")
    holder.Name = "MobESP_".. mob.Name
    holder.Parent = CoreGui
    ESP.Folders.Mobs[mob] = holder

    -- Создаем элементы
    for _, part in mob:GetChildren() do
        if part:IsA("BasePart") then
           -- CreateAdornment(part, ESP.Settings.MobColor).Parent = holder
        end
    end

    local billboard = CreateBillboard("Loading...")
    billboard.Adornee = mob.PrimaryPart or mob:FindFirstChild("HumanoidRootPart") or mob:WaitForChild("HumanoidRootPart", 2)
    billboard.Parent = holder

    local connection
    connection = RunService.RenderStepped:Connect(function()
        if not holder.Parent or not mob.Parent then
            connection:Disconnect()
            holder:Destroy()
            ESP.Folders.Mobs[mob] = nil
            return
        end

        local humanoid = mob:FindFirstChildOfClass("Humanoid")
        local rootPart = mob:FindFirstChild("HumanoidRootPart")
        local char = Players.LocalPlayer.Character
        local localRoot = char and char:FindFirstChild("HumanoidRootPart")

        if not humanoid or not rootPart or not localRoot then
            billboard.Enabled = false
            return
        end

        if humanoid.Health <= 0 then
            holder:Destroy()
            ESP.Folders.Mobs[mob] = nil
            return
        end

        local distance = (rootPart.Position - localRoot.Position).Magnitude
        if distance > ESP.Settings.MaxDistance then
            billboard.Enabled = false
            return
        end
        
        billboard.Enabled = true
        
        local text = string.format("Mob\nHP: %d/%d\n%d studs",
            math.floor(humanoid.Health),
            math.floor(humanoid.MaxHealth),
            math.floor(distance)
        )
        
        billboard.TextLabel.Text = text
    end)
    
    table.insert(ESP.Connections, connection)
end

function ESP.AddPlayerESP(player)
    if not ESP.Enabled.Players then return end
    if ESP.Folders.Players[player] then return end -- Не создавать, если уже существует

    local function SetupCharacter(character)
        -- Удаляем предыдущий ESP, если существует
        if ESP.Folders.Players[player] then
            ESP.Folders.Players[player]:Destroy()
            ESP.Folders.Players[player] = nil
        end

        if not character or not character.Parent then return end

        -- Ожидаем появление HumanoidRootPart
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        if not rootPart then
            local waitStart = os.clock()
            repeat
                rootPart = character:FindFirstChild("HumanoidRootPart")
                task.wait()
            until rootPart or os.clock() - waitStart > 5
            if not rootPart then return end
        end

        local holder = Instance.new("Folder")
        holder.Name = "PlayerESP_"..player.UserId
        holder.Parent = CoreGui
        ESP.Folders.Players[player] = holder

        -- Создание элементов ESP
        for _, part in character:GetChildren() do
            if part:IsA("BasePart") then
                --CreateAdornment(part, ESP.Settings.PlayerColor).Parent = holder
            end
        end

        local billboard = CreateBillboard("Loading...")
        billboard.Adornee = rootPart
        billboard.Parent = holder

        local connection
        connection = RunService.RenderStepped:Connect(function()
            if not holder.Parent or not character.Parent then
                connection:Disconnect()
                holder:Destroy()
                ESP.Folders.Players[player] = nil
                return
            end

            local humanoid = character:FindFirstChildOfClass("Humanoid")
            local localChar = Players.LocalPlayer.Character
            local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")

            if not humanoid or humanoid.Health <= 0 then
                holder:Destroy()
                ESP.Folders.Players[player] = nil
                return
            end

            if rootPart and localRoot then
                local distance = (rootPart.Position - localRoot.Position).Magnitude
                billboard.Enabled = distance <= ESP.Settings.MaxDistance

                if billboard.Enabled then
                    billboard.TextLabel.Text = string.format(
                        "%s\nHP: %d/%d\n%d studs",
                        player.Name,
                        math.floor(humanoid.Health),
                        math.floor(humanoid.MaxHealth),
                        math.floor(distance)
                    )
                end
            else
                billboard.Enabled = false
            end
        end)
        table.insert(ESP.Connections, connection)
    end

    -- Подключаем обработчики
    if player.Character then
        SetupCharacter(player.Character)
    end
    player.CharacterAdded:Connect(SetupCharacter)
end

function ESP.TogglePlayers(enable)
    ESP.Enabled.Players = enable
    espPlayerButton.BackgroundColor3 = enable and Theme.AccentColor or Theme.ElementBackground

    if enable then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= Players.LocalPlayer then
                ESP.AddPlayerESP(player)
            end
        end
        ESP.Handlers.PlayerAdded = Players.PlayerAdded:Connect(function(player)
            ESP.AddPlayerESP(player)
        end)
    else
        -- Чистка
        for player, folder in pairs(ESP.Folders.Players) do
            folder:Destroy()
        end
        table.clear(ESP.Folders.Players)
        
        if ESP.Handlers.PlayerAdded then
            ESP.Handlers.PlayerAdded:Disconnect()
        end
    end
end



---------------------------------
-- Основная логика приложения --
---------------------------------
local function UpdateBossList()
    local living = Workspace:FindFirstChild("Entities")
    if not living then
        warn("Папка Entities не найдена в Workspace!")
        return
    end

    -- Очистка предыдущих элементов
    for _, child in ipairs(ContentFrame:GetChildren()) do
        if child:IsA("Frame") and child ~= BossEntryTemplate then
            child:Destroy()
        end
    end

    -- Создаем UIListLayout для правильного позиционирования
    if not ContentFrame:FindFirstChild("ContentLayout") then
        local layout = Instance.new("UIListLayout")
        layout.Name = "ContentLayout"
        layout.Padding = UDim.new(0, 5)
        layout.SortOrder = Enum.SortOrder.LayoutOrder
        layout.Parent = ContentFrame
    end

    -- Сбор данных о боссах с частичным совпадением имен
    local bosses = {}
    for _, bossName in ipairs(BossList) do
        local isAlive = false
        local health = 0
        local maxHealth = 0
        
        -- Поиск по частичному совпадению имени
        for _, mob in ipairs(living:GetChildren()) do
            if string.find(mob.Name:lower(), bossName:lower()) then
                local humanoid = mob:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    isAlive = humanoid.Health > 0
                    health = math.floor(humanoid.Health)
                    maxHealth = math.floor(humanoid.MaxHealth)
                    break
                end
            end
        end

        table.insert(bosses, {
            name = bossName,
            isAlive = isAlive,
            health = health,
            maxHealth = maxHealth,
            priority = isAlive and 1 or 2
        })
    end

    -- Сортировка
    table.sort(bosses, function(a, b)
        if a.priority ~= b.priority then
            return a.priority < b.priority
        else
            return a.name:lower() < b.name:lower()
        end
    end)

    for _, boss in ipairs(bosses) do
        local entry = BossEntryTemplate:Clone()
        entry.Visible = true
        entry.Name = "Entry_"..boss.name
        
        -- Безопасный доступ к дочерним элементам через FindFirstChild
        local bossNameLabel = entry:FindFirstChild("BossName")
        local statusLabel = entry:FindFirstChild("Status")
        
        if bossNameLabel and statusLabel then
            bossNameLabel.Text = BossNameMap[boss.name] or boss.name
            statusLabel.Text = boss.isAlive and "🟢" or "🔴"
            
            if boss.isAlive then
                bossNameLabel.Text = bossNameLabel.Text.." | "..boss.health.."/"..boss.maxHealth
            end
        else
            warn("Не удалось найти элементы BossName или Status в записи босса")
        end
        
        entry.Parent = ContentFrame
    end

    -- Обновление прокрутки
    local layout = ContentFrame:FindFirstChild("ContentLayout")
    if layout then
        ContentFrame.CanvasSize = UDim2.new(
            0, 0,
            0, layout.AbsoluteContentSize.Y + 10
        )
    end
end

local function SwitchTab(tabName)
    currentTab = tabName
    ContentFrame.Visible = tabName == "bosses"
    AutoFarmFrame.Visible = tabName == "autofarm"
    VisualFrame.Visible = tabName == "visual"
    
    if tabName == "bosses" then
        UpdateBossList()
    end
    
    BossesTabButton.BackgroundColor3 = tabName == "bosses" and Theme.AccentColor or Theme.ElementBackground
    AutoFarmTabButton.BackgroundColor3 = tabName == "autofarm" and Theme.AccentColor or Theme.ElementBackground
    ContentFrame.CanvasPosition = Vector2.new(0, 0)
end

local function checkLivingBosses()
    if not selectedBoss then
        warn("Босс не выбран!")
        return false
    end
    
    local living = Workspace:FindFirstChild("Entities")
    if not living then
        warn("Папка Entities не найдена!")
        return false
    end

    for _, mob in ipairs(living:GetChildren()) do
        if string.find(mob.Name:lower(), selectedBoss:lower()) then
            local humanoid = mob:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                return true
            end
        end
    end
    return false
end

local function startAutoFarm()
    if autofarming or not selectedBoss then 
        if not selectedBoss then
            notify("ERROR", "Please select a boss first!")
        end
        return 
    end
    
    autofarming = true
    AutoFarmButton.Text = "STOP AUTOFARM"
    
    local function teleportLoop()
        while autofarming do
            TeleportService:Teleport(maingameId, LocalPlayer, {
                autofarming = true,
                selectedBoss = selectedBoss
            })
            
            local success = pcall(TeleportService.LocalPlayer.OnTeleport.Wait, TeleportService.LocalPlayer.OnTeleport)
            if not success or not autofarming then break end
            
            -- Ожидание появления папки Alive
            local startTime = os.time()
            local living = nil
            repeat
                task.wait(1)
                living = Workspace:FindFirstChild("Entities")
                if os.time() - startTime > 15 then
                    warn("Таймаут ожидания папки Entities!")
                    break
                end
            until living
            
            if living then
                task.wait(2)
                if checkLivingBosses() then
                    autofarming = false
                    notify("ОСТАНОВКА", "Босс обнаружен!")
                    break
                end
            end
            
            -- Телепорт обратно
            TeleportService:Teleport(menuplaceId, LocalPlayer, {
                autofarming = true,
                selectedBoss = selectedBoss
            })
            
            pcall(TeleportService.LocalPlayer.OnTeleport.Wait, TeleportService.LocalPlayer.OnTeleport)
            task.wait(8)
        end
        AutoFarmButton.Text = "START AUTOFARM"
        autofarming = false
    end
    
    coroutine.wrap(teleportLoop)()
end

AutoFarmButton.MouseButton1Click:Connect(function()
    if autofarming then
        autofarming = false
        AutoFarmButton.Text = "START AUTOFARM"
        notify("AUTOFARM", "Process stopped by user")
    else
        startAutoFarm()
    end
end)

local function processExistingBoss(child)
    local matchedBoss = nil
    for _, bossName in ipairs(BossList) do
        if string.find(child.Name:lower(), bossName:lower()) then
            matchedBoss = bossName
            break
        end
    end

    if matchedBoss then
        local displayName = BossNameMap[matchedBoss] or matchedBoss
        local humanoid = child:FindFirstChildOfClass("Humanoid")
        if humanoid then
            local currentHP = math.floor(humanoid.Health)
            local maxHP = math.floor(humanoid.MaxHealth)
            if not initialCheckDone then
                notify("BOSS INFO", displayName.." is here! HP: " .. currentHP .. " / " .. maxHP)
            end
            activeBosses[child] = matchedBoss
        end
    end
end

local function onChildAdded(child)
    if eventCooldown.added[child] then return end
    eventCooldown.added[child] = true
    processExistingBoss(child)
    UpdateBossList()
    task.delay(5, function() eventCooldown.added[child] = nil end)
end

local function onChildRemoved(child)
    if eventCooldown.removed[child] then return end
    eventCooldown.removed[child] = true

    local bossKey = activeBosses[child]
    if bossKey then
        activeBosses[child] = nil
        local stillAlive = false
        for otherChild, key in pairs(activeBosses) do
            if key == bossKey then
                stillAlive = true
                break
            end
        end
        if not stillAlive then
            local displayName = BossNameMap[bossKey] or bossKey
            notify("BOSS DEFEATED", displayName.." has been defeated!")
            UpdateBossList()
        end
    end
    task.delay(5, function() eventCooldown.removed[child] = nil end)
end

local function TrackBossEvents()
    local living = Workspace:FindFirstChild("Entities")
    if not living then return end

    if not initialCheckDone then
        for _, child in ipairs(living:GetChildren()) do
            processExistingBoss(child)
        end
        initialCheckDone = true
    end

    living.ChildAdded:Connect(onChildAdded)
    living.ChildRemoved:Connect(onChildRemoved)
end

BossesTabButton.MouseButton1Click:Connect(function()
    SwitchTab("bosses")
end)

AutoFarmTabButton.MouseButton1Click:Connect(function()
    SwitchTab("autofarm")
end)

VisualTabButton.MouseButton1Click:Connect(function()
    SwitchTab("visual")
end)

-- Изначальное состояние для кнопки: выключено
local playerUidEnabled = true

playerUidButton.MouseButton1Click:Connect(function()
    playerUidEnabled = not playerUidEnabled  -- переключаем состояние
    
    -- Получаем PlayerUID из PlayerGui
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    local playerUID = playerGui:FindFirstChild("PlayerUID")
    if playerUID then
        playerUID.Enabled = playerUidEnabled
    else
        warn("Элемент PlayerUID не найден в PlayerGui!")
    end
    
    -- Обновляем внешний вид кнопки в зависимости от состояния
    if not playerUidEnabled then
        playerUidButton.BackgroundColor3 = Theme.AccentColor
        playerUidButton.Font = Enum.Font.GothamBold
        notify("Luaria", "Player UID OFF")
    else
        playerUidButton.BackgroundColor3 = Theme.ElementBackground
        playerUidButton.Font = Enum.Font.Gotham
        notify("Luaria", "Player UID ON")
    end
end)

-- UI Handlers
espMobsButton.MouseButton1Click:Connect(function()
    ESP.ToggleMobs(not ESP.Enabled.Mobs)
end)

espPlayerButton.MouseButton1Click:Connect(function()
    ESP.TogglePlayers(not ESP.Enabled.Players)
end)


CloseButton.MouseButton1Click:Connect(function()
    ScreenGui.Enabled = false
end)

ExitButton.MouseButton1Click:Connect(function()
    -- Очистка ESP
    ESP.ToggleMobs(false)
    ESP.TogglePlayers(false)
    
    -- Исправленная обработка соединений
    if ESP.Connections then
        for _, connection in pairs(ESP.Connections) do
            pcall(function()
                if connection then
                    connection:Disconnect()
                end
            end)
        end
        ESP.Connections = {}
    end
    
    -- Удаление интерфейса
    if ScreenGui then
        ScreenGui:Destroy()
    end
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.G then
        ScreenGui.Enabled = not ScreenGui.Enabled
        if ScreenGui.Enabled then
            UpdateBossList()
            ContentFrame.CanvasPosition = Vector2.new(0, 0)
        end
    end
end)

local function Initialize()
    local teleportData = TeleportService:GetLocalPlayerTeleportData() or {}
    autofarming = teleportData.autofarming or false
    selectedBoss = teleportData.selectedBoss

    print("Данные телепортации:", teleportData)
    if currentPlaceId == maingameId and autofarming then
        task.wait(10)
        if checkLivingBosses() then
            autofarming = false
            notify("AUTOFARM STOPPED", "Target boss found!")
        else
            TeleportService:Teleport(menuplaceId, LocalPlayer, {
                autofarming = true,
                selectedBoss = selectedBoss
            })
        end
    elseif currentPlaceId == menuplaceId and autofarming then
        task.wait(10)
        TeleportService:Teleport(maingameId, LocalPlayer, {
            autofarming = true,
            selectedBoss = selectedBoss
        })
    end

    SwitchTab("bosses")
    TrackBossEvents()
    UpdateBossList()
    
    -- Автоматическое обновление каждую секунду
    while true do
        UpdateBossList()
        task.wait(1)
    end
end
if currentPlaceId == maingameId then
	task.wait(1)
	ScreenGui.Enabled = true
	task.wait(1)
	UpdateBossList()
end
coroutine.wrap(Initialize)()
local speaker = game:GetService("Players").LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local nowe = false
local speeds = 10
local flyingParts = {}
local connection

local function toggleFlight()
    nowe = not nowe
    local chr = speaker.Character or speaker.CharacterAdded:Wait()
    local hum = chr:FindFirstChildOfClass("Humanoid")
    
    if not hum or hum.Health <= 0 then return end

    if nowe then
        -- Активация полета
        hum.PlatformStand = true
        
        -- Создаем объекты для полета
        local bg = Instance.new("BodyGyro")
        bg.P = 20000
        bg.maxTorque = Vector3.new(9e9, 9e9, 9e9)
        bg.Parent = chr.HumanoidRootPart

        local bv = Instance.new("BodyVelocity")
        bv.Velocity = Vector3.new()
        bv.maxForce = Vector3.new(9e9, 9e9, 9e9)
        bv.Parent = chr.HumanoidRootPart

        table.insert(flyingParts, bg)
        table.insert(flyingParts, bv)

        -- Подключаем обработчик движения
        connection = RunService.Heartbeat:Connect(function()
            if not nowe or not chr:FindFirstChild("HumanoidRootPart") then return end
            
            local camCF = workspace.CurrentCamera.CFrame
            local moveVec = Vector3.new(
                UserInputService:IsKeyDown(Enum.KeyCode.D) and 1 or UserInputService:IsKeyDown(Enum.KeyCode.A) and -1 or 0,
                UserInputService:IsKeyDown(Enum.KeyCode.Space) and 1 or UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) and -1 or 0,
                UserInputService:IsKeyDown(Enum.KeyCode.S) and -1 or UserInputService:IsKeyDown(Enum.KeyCode.W) and 1 or 0
            )

            local newVelocity = (camCF.LookVector * moveVec.Z + 
                               camCF.RightVector * moveVec.X + 
                               camCF.UpVector * moveVec.Y) * speeds * 10
                               
            bv.Velocity = newVelocity
            bg.CFrame = camCF
        end)
    else
        -- Деактивация полета
        hum.PlatformStand = false
        hum:ChangeState(Enum.HumanoidStateType.Landed)
        
        -- Удаляем созданные объекты
        if connection then
            connection:Disconnect()
            connection = nil
        end
        
        for _, part in pairs(flyingParts) do
            if part and part.Parent then
                part:Destroy()
            end
        end
        flyingParts = {}
    end
end

-- Обработчик клавиши "-"
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.H then
        toggleFlight()
    end
end)

-- Обработчик изменения скорости
UserInputService.InputBegan:Connect(function(input, processed)
    if processed then return end
    
    if input.KeyCode == Enum.KeyCode.Equals then
        speeds = math.min(speeds + 1, 20)
    elseif input.KeyCode == Enum.KeyCode.Hyphen then
        speeds = math.max(speeds - 1, 1)
    end
end)
