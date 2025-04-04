local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local HttpService = game:GetService("HttpService")
local DATA_KEY = "LauriaHub_Keybinds"
local CONFIG_PATH = DATA_KEY..".cfg"

-- Настройка уведомлений
local function notify(title, text)
    StarterGui:SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = 5
    })
end

local LocalPlayer = Players.LocalPlayer

getgenv().Changelog = [[
[v1.1.0] - Latest Update
- Flight system and flight speed adjustment added
- Optimized ESP functionality with bosses
- Update Log added
- Keybind system added
]]

---------------------------
-- Настройки --
---------------------------
local speeds = 10
local autofarmspeed = 150           -- скорость движения в студиях/сек
local gotopartDelay = 0.1   -- задержка перед tween
local buttonClickDelay = 0.2 -- Задержка между нажатиями кнопок
local autoFarmEnabled = false
local activeTween
local lootbagConnection
local NONE_KEY = Enum.KeyCode.Unknown -- Специальное значение для "None"
local flyKeyBtn, playerEspKeyBtn, mobEspKeyBtn, menuKeyBtn

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
ScreenGui.Enabled = true

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 370, 0, 330)
MainFrame.Position = UDim2.new(0.5, -160, 0.5, -125)
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
Title.Text = "Lauria Hub"
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

local SettingsButton = Instance.new("TextButton")
SettingsButton.Size = UDim2.new(0, 24, 0, 24)
SettingsButton.Position = UDim2.new(1, -60, 0.5, -12)
SettingsButton.BackgroundColor3 = Theme.Topbar
SettingsButton.TextColor3 = Color3.new(1, 1, 1)
SettingsButton.Text = "⚙️"
SettingsButton.Font = Enum.Font.GothamBold
SettingsButton.TextSize = 20
SettingsButton.Parent = TopBar

local settingsBtnUICorner = Instance.new("UICorner")
settingsBtnUICorner.CornerRadius = UDim.new(0, 6)
settingsBtnUICorner.Parent = SettingsButton

--Кнопки разделы меню
local TabButtonsContainer = Instance.new("Frame")
TabButtonsContainer.Size = UDim2.new(1, 0, 0, 40)
TabButtonsContainer.Position = UDim2.new(0, 0, 0, 45)
TabButtonsContainer.BackgroundTransparency = 1
TabButtonsContainer.Parent = MainFrame

local UIListLayout_Tabs = Instance.new("UIListLayout")
UIListLayout_Tabs.FillDirection = Enum.FillDirection.Horizontal
UIListLayout_Tabs.Padding = UDim.new(0, 5)
UIListLayout_Tabs.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout_Tabs.Parent = TabButtonsContainer

local MainMenuTabButton = Instance.new("TextButton")
MainMenuTabButton.Size = UDim2.new(0, 80, 0, 30)
MainMenuTabButton.BackgroundColor3 = Theme.AccentColor
MainMenuTabButton.TextColor3 = Color3.new(1, 1, 1)
MainMenuTabButton.Text = "Menu"
MainMenuTabButton.Font = Enum.Font.GothamBold
MainMenuTabButton.TextSize = 14
MainMenuTabButton.Parent = TabButtonsContainer

local tabBtnUICorner1 = Instance.new("UICorner")
tabBtnUICorner1.CornerRadius = UDim.new(0, 6)
tabBtnUICorner1.Parent = MainMenuTabButton



local AutoFarmTabButton = Instance.new("TextButton")
AutoFarmTabButton.Size = UDim2.new(0, 80, 0, 30)
AutoFarmTabButton.BackgroundColor3 = Theme.ElementBackground
AutoFarmTabButton.TextColor3 = Theme.TextColor
AutoFarmTabButton.Text = "Autofarm"
AutoFarmTabButton.Font = Enum.Font.GothamBold
AutoFarmTabButton.TextSize = 14
AutoFarmTabButton.Parent = TabButtonsContainer

local tabBtnUICorner2 = Instance.new("UICorner")
tabBtnUICorner2.CornerRadius = UDim.new(0, 6)
tabBtnUICorner2.Parent = AutoFarmTabButton


local EspTabButton = Instance.new("TextButton")
EspTabButton.Size = UDim2.new(0, 80, 0, 30)
EspTabButton.BackgroundColor3 = Theme.ElementBackground
EspTabButton.TextColor3 = Theme.TextColor
EspTabButton.Text = "Visual"
EspTabButton.Font = Enum.Font.GothamBold
EspTabButton.TextSize = 14
EspTabButton.Parent = TabButtonsContainer

local tabBtnUICorner2 = Instance.new("UICorner")
tabBtnUICorner2.CornerRadius = UDim.new(0, 6)
tabBtnUICorner2.Parent = EspTabButton


local MovementTabButton = Instance.new("TextButton")
MovementTabButton.Size = UDim2.new(0, 80, 0, 30)
MovementTabButton.BackgroundColor3 = Theme.ElementBackground
MovementTabButton.TextColor3 = Theme.TextColor
MovementTabButton.Text = "Movement"
MovementTabButton.Font = Enum.Font.GothamBold
MovementTabButton.TextSize = 14
MovementTabButton.Parent = TabButtonsContainer

local tabBtnUICorner2 = Instance.new("UICorner")
tabBtnUICorner2.CornerRadius = UDim.new(0, 6)
tabBtnUICorner2.Parent = MovementTabButton

--контент
local MainFrameConetent = Instance.new("Frame")
MainFrameConetent.Size = UDim2.new(1, -10, 1, -10)
MainFrameConetent.Position = UDim2.new(0, 5, 0, 80)
MainFrameConetent.BackgroundTransparency = 1
MainFrameConetent.Parent = MainFrame

local AutoFarmFrame = Instance.new("Frame")
AutoFarmFrame.Size = UDim2.new(1, -10, 1, -110)
AutoFarmFrame.Position = UDim2.new(0, 5, 0, 80)
AutoFarmFrame.BackgroundTransparency = 1
AutoFarmFrame.Visible = false
AutoFarmFrame.Parent = MainFrame

local EspFrame = Instance.new("Frame")
EspFrame.Size = UDim2.new(1, -10, 1, -110)
EspFrame.Position = UDim2.new(0, 5, 0, 80)
EspFrame.BackgroundTransparency = 1
EspFrame.Visible = false
EspFrame.Parent = MainFrame

local MovementFrame = Instance.new("Frame")
MovementFrame.Size = UDim2.new(1, -10, 1, -110)
MovementFrame.Position = UDim2.new(0, 5, 0, 80)
MovementFrame.BackgroundTransparency = 1
MovementFrame.Visible = false
MovementFrame.Parent = MainFrame

local SettingsFrame = Instance.new("Frame")
SettingsFrame.Size = UDim2.new(1, -10, 1, -110)
SettingsFrame.Position = UDim2.new(0, 5, 0, 80)
SettingsFrame.BackgroundTransparency = 1
SettingsFrame.Visible = false
SettingsFrame.Parent = MainFrame

    -- В секции создания SettingsFrame добавьте:
local KeybindsFrame = Instance.new("Frame")
KeybindsFrame.Size = UDim2.new(1, -20, 0, 150)
KeybindsFrame.Position = UDim2.new(0, 10, 0, 10)
KeybindsFrame.BackgroundTransparency = 1
KeybindsFrame.Parent = SettingsFrame

local keybindsLayout = Instance.new("UIListLayout")
keybindsLayout.Padding = UDim.new(0, 5)
keybindsLayout.Parent = KeybindsFrame

------------------

-- Контейнер для логов
local ScrollFrame = Instance.new("ScrollingFrame")
ScrollFrame.Size = UDim2.new(1, -10, 1, -50) -- Уменьшили высоту для заголовка
ScrollFrame.Position = UDim2.new(0, 5, 0, 40) -- Сдвинули вниз
ScrollFrame.BackgroundTransparency = 1
ScrollFrame.ScrollBarThickness = 5
ScrollFrame.Parent = MainFrameConetent

-- Заголовок Update Log
local UpdateLogLabel = Instance.new("TextLabel")
UpdateLogLabel.Size = UDim2.new(1, -10, 0, 30)
UpdateLogLabel.Position = UDim2.new(0, 5, 0, 0)
UpdateLogLabel.BackgroundTransparency = 1
UpdateLogLabel.TextColor3 = Theme.TextColor
UpdateLogLabel.Text = "Update Log"
UpdateLogLabel.Font = Enum.Font.GothamBold
UpdateLogLabel.TextSize = 20
UpdateLogLabel.TextXAlignment = Enum.TextXAlignment.Left
UpdateLogLabel.Parent = MainFrameConetent

-- Разделительная линия
local Divider = Instance.new("Frame")
Divider.Size = UDim2.new(1, -10, 0, 1)
Divider.Position = UDim2.new(0, 5, 0, 30)
Divider.BackgroundColor3 = Theme.ElementBackground
Divider.BorderSizePixel = 0
Divider.Parent = MainFrameConetent

-- Текст логов (остается без изменений)
local LogsLabel = Instance.new("TextLabel")
LogsLabel.Size = UDim2.new(1, -5, 1, 0)
LogsLabel.Position = UDim2.new(0, 5, 0, 0)
LogsLabel.BackgroundTransparency = 1
LogsLabel.TextColor3 = Theme.TextColor
LogsLabel.Text = getgenv().Changelog
LogsLabel.Font = Enum.Font.Gotham
LogsLabel.TextSize = 16
LogsLabel.TextXAlignment = Enum.TextXAlignment.Left
LogsLabel.TextYAlignment = Enum.TextYAlignment.Top
LogsLabel.TextWrapped = true
LogsLabel.Parent = ScrollFrame

-- Автоматический размер для прокрутки
LogsLabel:GetPropertyChangedSignal("TextBounds"):Connect(function()
    ScrollFrame.CanvasSize = UDim2.new(0, 0, 0, LogsLabel.TextBounds.Y + 20)
end)

--Autofarm кнопка
local AutoFarmButton = Instance.new("TextButton")
AutoFarmButton.Size = UDim2.new(1, -20, 0, 40)
AutoFarmButton.Position = UDim2.new(0, 10, 0, 10)
AutoFarmButton.BackgroundColor3 = Theme.ElementBackground
AutoFarmButton.TextColor3 = Theme.TextColor
AutoFarmButton.Text = "Autofarm"
AutoFarmButton.Font = Enum.Font.GothamBold
AutoFarmButton.TextSize = 16
AutoFarmButton.Parent = AutoFarmFrame

local espPlayerUICorner = Instance.new("UICorner")
espPlayerUICorner.CornerRadius = UDim.new(0, 6)
espPlayerUICorner.Parent = AutoFarmButton

--Mobs ESP кнопка
local espMobsButton = Instance.new("TextButton")
espMobsButton.Size = UDim2.new(1, -20, 0, 40)
espMobsButton.Position = UDim2.new(0, 10, 0, 60)
espMobsButton.BackgroundColor3 = Theme.ElementBackground
espMobsButton.TextColor3 = Theme.TextColor
espMobsButton.Text = "Mobs ESP"
espMobsButton.Font = Enum.Font.GothamBold
espMobsButton.TextSize = 16
espMobsButton.Parent = EspFrame

local espMobsUICorner = Instance.new("UICorner")
espMobsUICorner.CornerRadius = UDim.new(0, 6)
espMobsUICorner.Parent = espMobsButton

--Player ESP кнопка
local espPlayerButton = Instance.new("TextButton")
espPlayerButton.Size = UDim2.new(1, -20, 0, 40)
espPlayerButton.Position = UDim2.new(0, 10, 0, 10)
espPlayerButton.BackgroundColor3 = Theme.ElementBackground
espPlayerButton.TextColor3 = Theme.TextColor
espPlayerButton.Text = "Player ESP"
espPlayerButton.Font = Enum.Font.GothamBold
espPlayerButton.TextSize = 16
espPlayerButton.Parent = EspFrame

local espPlayerUICorner = Instance.new("UICorner")
espPlayerUICorner.CornerRadius = UDim.new(0, 6)
espPlayerUICorner.Parent = espPlayerButton

--Fly кнопка
local flyButton = Instance.new("TextButton")
flyButton.Size = UDim2.new(1, -20, 0, 40)
flyButton.Position = UDim2.new(0, 10, 0, 10)
flyButton.BackgroundColor3 = Theme.ElementBackground
flyButton.TextColor3 = Theme.TextColor
flyButton.Text = "Fly"
flyButton.Font = Enum.Font.GothamBold
flyButton.TextSize = 14
flyButton.Parent = MovementFrame

local flyUICorner = Instance.new("UICorner")
flyUICorner.CornerRadius = UDim.new(0, 6)
flyUICorner.Parent = flyButton

local ExitButton = Instance.new("TextButton")
ExitButton.Size = UDim2.new(1, -20, 0, 40)
ExitButton.Position = UDim2.new(0, 10, 1, -50)
ExitButton.BackgroundColor3 = Theme.ExitColor
ExitButton.TextColor3 = Color3.new(1, 1, 1)
ExitButton.Text = "EXIT"
ExitButton.Font = Enum.Font.GothamBold
ExitButton.TextSize = 16
ExitButton.Parent = MainFrame


-- Добавляем слайдер скорости под кнопкой Fly
local speedBarFrame = Instance.new("Frame")
speedBarFrame.Size = UDim2.new(1, -20, 0, 20)
speedBarFrame.Position = UDim2.new(0, 10, 0, 60) -- ниже кнопки Fly (75 + 40 + 10)
speedBarFrame.BackgroundColor3 = Theme.ElementBackground
speedBarFrame.Parent = MovementFrame

local speedBarUICorner = Instance.new("UICorner")
speedBarUICorner.CornerRadius = UDim.new(0, 6)
speedBarUICorner.Parent = speedBarFrame

local speedIndicator = Instance.new("Frame")
speedIndicator.Size = UDim2.new(speeds/50, 0, 1, 0) -- начальное значение: speeds/50
speedIndicator.Position = UDim2.new(0, 0, 0, 0)
speedIndicator.BackgroundColor3 = Theme.AccentColor
speedIndicator.Parent = speedBarFrame

local speedValueLabel = Instance.new("TextBox")
speedValueLabel.Size = UDim2.new(0, 40, 1, 0)
speedValueLabel.Position = UDim2.new(1, -45, 0, 0)
speedValueLabel.BackgroundTransparency = 1
speedValueLabel.TextColor3 = Theme.TextColor
speedValueLabel.Text = tostring(speeds)
speedValueLabel.Font = Enum.Font.GothamBold
speedValueLabel.TextSize = 14
speedValueLabel.ClearTextOnFocus = false 
speedValueLabel.Parent = speedBarFrame

local stroke = Instance.new("UIStroke")
stroke.Color = Theme.StrokeColor
stroke.Thickness = 1
stroke.Parent = speedValueLabel


-- Добавьте вызов загрузки после объявления Keybinds
local Keybinds = {
    Fly = Enum.KeyCode.H,
    PlayerESP = Enum.KeyCode.P,
    MobESP = Enum.KeyCode.M,
    Menu = Enum.KeyCode.G
}



local function saveKeybinds()
    print("[SAVE] Starting save process...")
    local dataToSave = {}
    for key, keyCode in pairs(Keybinds) do
        dataToSave[key] = (keyCode == NONE_KEY) and "None" or keyCode.Name
        print(string.format("[SAVE] Key: %s, Value: %s", key, dataToSave[key]))
    end
    
    local success, err = pcall(function()
        local json = HttpService:JSONEncode(dataToSave)
        writefile(CONFIG_PATH, json)
        print("[SAVE] Successfully saved config to:", CONFIG_PATH)
    end)
    
    if not success then
        local msg = "Failed to save keybinds: "..tostring(err)
        print("[SAVE ERROR]", msg)
        notify("Save Error", msg)
    end
end
local function loadKeybinds()
    print("[LOAD] Starting load process...")
    local function setDefault()
        print("[LOAD] Setting default keybinds")
        Keybinds.Fly = Enum.KeyCode.H
        Keybinds.PlayerESP = Enum.KeyCode.P
        Keybinds.MobESP = Enum.KeyCode.M
        Keybinds.Menu = Enum.KeyCode.G
        saveKeybinds()
    end
    
    -- Проверка существования файла с обработкой ошибок
    local fileExists = pcall(function() return readfile(CONFIG_PATH) end)
    if not fileExists then
        print("[LOAD] Config file not found, creating default")
        setDefault()
        return
    end

    print("[LOAD] Reading config file...")
    local success, data = pcall(function()
        local content = readfile(CONFIG_PATH)
        print("[LOAD] Raw config content:", content)
        return HttpService:JSONDecode(content)
    end)
    
    if not success then
        print("[LOAD ERROR] Corrupted config:", data)
        notify("Load Error", "Corrupted config, using defaults")
        setDefault()
        return
    end

    print("[LOAD] Loaded config data:")
    for k,v in pairs(data) do print(" ", k, v) end

    -- Валидация и применение настроек
    for key, value in pairs(data) do
        if Keybinds[key] ~= nil then
            local keyCode = (value == "None") and NONE_KEY or Enum.KeyCode[value]
            if keyCode then
                Keybinds[key] = keyCode
                print(string.format("[LOAD] Set %s = %s", key, keyCode.Name))
            else
                warn(string.format("[LOAD] Invalid keybind: %s for %s", value, key))
            end
        end
    end
    
    -- Защищенное обновление интерфейса
    local function safeUpdateButton(button, key)
        if Keybinds[key] and button then
            local name = Keybinds[key].Name
            button.Text = name ~= "Unknown" and "["..name.."]" or "[None]"
            print(string.format("[LOAD] Updated %s button: %s", key, button.Text))
        else
            warn("[LOAD ERROR] Missing keybind or button for:", key)
        end
    end

    safeUpdateButton(flyKeyBtn, "Fly")
    safeUpdateButton(playerEspKeyBtn, "PlayerESP")
    safeUpdateButton(mobEspKeyBtn, "MobESP")
    safeUpdateButton(menuKeyBtn, "Menu")
end


-- Функция создания элементов кейбиндов
local function CreateKeybindRow(name, defaultKey)
    local defaultKey = Keybinds[keyName] or NONE_KEY
    local buttonText = defaultKey.Name ~= "Unknown" and "["..defaultKey.Name.."]" or "[None]"
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 25)
    row.BackgroundTransparency = 1
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.6, 0, 1, 0)
    label.Text = name
    label.Font = Enum.Font.Gotham
    label.TextSize = 14
    label.TextColor3 = Theme.TextColor
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.BackgroundTransparency = 1
    label.Parent = row
    
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.3, 0, 1, 0)
    button.Position = UDim2.new(0.7, 0, 0, 0)
    button.BackgroundColor3 = Theme.ElementBackground
    button.TextColor3 = Theme.TextColor
    button.Text = buttonText
    button.Font = Enum.Font.GothamBold
    button.TextSize = 14
    button.Parent = row
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = button
    
    return button, row
end


local function InitializeKeybindButtons()
    local function createRow(name, key)
        local btn, row = CreateKeybindRow(name, key)
        row.Parent = KeybindsFrame
        return btn
    end

    flyKeyBtn = createRow("Fly Key", "Fly")
    playerEspKeyBtn = createRow("Player ESP Key", "PlayerESP")
    mobEspKeyBtn = createRow("Mob ESP Key", "MobESP")
    menuKeyBtn = createRow("Menu Key", "Menu")
end

InitializeKeybindButtons()
loadKeybinds()

-- ESP система
local ESP = {
    Enabled = {
        Mobs = false,
        Players = false
    },
    Settings = {
        MaxDistance = 10000,
        MobColor = Color3.new(1, 0.2, 0.2),
        PlayerColor = Color3.new(0.2, 0.6, 1),
        TextSize = 14
    },
    Tracked = {
        Mobs = {},
        Players = {}
    },
    Connections = {}
}

-- Вспомогательные функции
local function CreateBillboard()
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
    textLabel.Parent = billboard
    
    return billboard
end

notify("Luaria Hub", "Setup")   

-- Основные функции ESP 
function ESP.ToggleMobs(enable)
    ESP.Enabled.Mobs = enable
    espMobsButton.BackgroundColor3 = enable and Theme.AccentColor or Theme.ElementBackground

    if enable then
    print("mobs esp enable")
        local Players = game:GetService("Players")
        
        -- Функция для проверки, является ли моб персонажем игрока
        local function IsPlayerCharacter(mob)
            for _, player in ipairs(Players:GetPlayers()) do
                if player.Character and player.Character == mob then
                print("is player")
                    return true
                end
            end
            return false
        end

        -- Обработка существующих мобов
        for _, mob in ipairs(Workspace.Entities:GetChildren()) do
            if mob:GetAttribute("NPC") and not IsPlayerCharacter(mob) then
                print("Added mob already")
                ESP.AddMobESP(mob)
            end
        end
        
        -- Подключение новых мобов
        ESP.Connections.MobAdded = Workspace.Entities.ChildAdded:Connect(function(mob)
            if mob:GetAttribute("NPC") and not IsPlayerCharacter(mob) then
                print("Added a new mob")
                ESP.AddMobESP(mob)
            end
        end)

        for _, mob in ipairs(Workspace.Entities:GetChildren()) do
            if not mob:GetAttribute("NPC") and not IsPlayerCharacter(mob) then
                print("Added mob already")
                ESP.AddMobESP(mob)
            end
        end
        
        -- Подключение новых мобов
        ESP.Connections.MobAdded = Workspace.Entities.ChildAdded:Connect(function(mob)
            if not mob:GetAttribute("NPC") and not IsPlayerCharacter(mob) then
                print("Added a new mob")
                ESP.AddMobESP(mob)
            end
        end)
    else
        -- Очистка
        for mob, tracker in pairs(ESP.Tracked.Mobs) do
            if tracker.Holder then
                tracker.Holder:Destroy()
            end
            for _, conn in pairs(tracker.Connections) do
                conn:Disconnect()
            end
        end
        table.clear(ESP.Tracked.Mobs)
        
        if ESP.Connections.MobAdded then
            ESP.Connections.MobAdded:Disconnect()
        end
    end
end

function ESP.AddMobESP(mob)
    if not ESP.Enabled.Mobs or ESP.Tracked.Mobs[mob] then return end

    local tracker = {
        Connections = {},
        Holder = nil
    }
    ESP.Tracked.Mobs[mob] = tracker

    local holder = Instance.new("Folder")
    holder.Name = "MobESP_"..mob.Name
    holder.Parent = CoreGui
    tracker.Holder = holder

    local billboard = CreateBillboard()
    billboard.Adornee = mob.PrimaryPart or mob:FindFirstChild("HumanoidRootPart") or mob:WaitForChild("HumanoidRootPart", 2)
    billboard.Parent = holder

    local humanoid = mob:WaitForChild("Humanoid", 2)
    local rootPart = mob:WaitForChild("HumanoidRootPart", 2)
    
    if not humanoid or not rootPart then
        holder:Destroy()
        return
    end

    local renderConn
    renderConn = RunService.RenderStepped:Connect(function()
        if not ESP.Enabled.Mobs or not holder.Parent then
            holder:Destroy()
            renderConn:Disconnect()
            return
        end

        local localPlayer = Players.LocalPlayer
        local localChar = localPlayer.Character
        local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")

        if humanoid.Health <= 0 then
            holder:Destroy()
            return
        end

        if localRoot and rootPart then
            local distance = (localRoot.Position - rootPart.Position).Magnitude
            billboard.Enabled = distance <= ESP.Settings.MaxDistance

            if billboard.Enabled then
                billboard.TextLabel.Text = string.format(
                    "Mob\nHP: %d/%d\n%d studs",
                    math.floor(humanoid.Health),
                    math.floor(humanoid.MaxHealth),
                    math.floor(distance)
                )
            end
        else
            billboard.Enabled = false
        end
    end)
    table.insert(tracker.Connections, renderConn)
end

function ESP.AddPlayerESP(player)
    if not ESP.Enabled.Players or ESP.Tracked.Players[player] then return end

    local tracker = {
        TempConnections = {},  
        PersistentConnections = {}, 
        Holder = nil,
        Alive = true
    }
    ESP.Tracked.Players[player] = tracker

    local function CleanupTemp()
        if tracker.Holder then
            tracker.Holder:Destroy()
            tracker.Holder = nil
        end
        for _, conn in pairs(tracker.TempConnections) do
            conn:Disconnect()
        end
        tracker.TempConnections = {}
    end

    local function SetupCharacter(character)
        CleanupTemp()
        if not character then return end
        
        local humanoid = character:WaitForChild("Humanoid", 2)
        local rootPart = character:WaitForChild("HumanoidRootPart", 2)
        if not humanoid or not rootPart then return end

        local holder = Instance.new("Folder")
        holder.Name = "PlayerESP_"..player.UserId
        holder.Parent = CoreGui
        tracker.Holder = holder

        local billboard = CreateBillboard()
        billboard.Adornee = rootPart
        billboard.Parent = holder

        local renderConn = RunService.RenderStepped:Connect(function()
            if not ESP.Enabled.Players or not holder.Parent then
                CleanupTemp()
                return
            end

            local localPlayer = Players.LocalPlayer
            local localChar = localPlayer.Character
            local localRoot = localChar and localChar:FindFirstChild("HumanoidRootPart")

            if humanoid.Health > 0 and rootPart and localRoot then
                local distance = (localRoot.Position - rootPart.Position).Magnitude
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
        table.insert(tracker.TempConnections, renderConn)
    end

    local charAddedConn = player.CharacterAdded:Connect(SetupCharacter)
    table.insert(tracker.PersistentConnections, charAddedConn)
    
    local charRemovingConn = player.CharacterRemoving:Connect(CleanupTemp)
    table.insert(tracker.PersistentConnections, charRemovingConn)
    
    if player.Character then
        SetupCharacter(player.Character)
    end
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
        ESP.Connections.PlayerAdded = Players.PlayerAdded:Connect(ESP.AddPlayerESP)
    else
        for player, tracker in pairs(ESP.Tracked.Players) do
            if tracker.Holder then
                tracker.Holder:Destroy()
            end
            -- Отключаем все временные подключения
            for _, conn in pairs(tracker.TempConnections or {}) do
                conn:Disconnect()
            end
            -- Отключаем все постоянные подключения
            for _, conn in pairs(tracker.PersistentConnections or {}) do
                conn:Disconnect()
            end
        end
        table.clear(ESP.Tracked.Players)
        
        if ESP.Connections.PlayerAdded then
            ESP.Connections.PlayerAdded:Disconnect()
        end
    end
end

local scriptActive = true

-- Fly System
local speaker = Players.LocalPlayer
local flyingParts = {}
local flightConnection  -- для цикла Heartbeat
local nowe = false

local function toggleFlight()
    if not scriptActive then return end
    nowe = not nowe
    local chr = speaker.Character or speaker.CharacterAdded:Wait()
    local hum = chr:FindFirstChildOfClass("Humanoid")
    if not hum or hum.Health <= 0 then return end

    if nowe then
        flyButton.BackgroundColor3 = enable and Theme.AccentColor or Theme.ElementBackground
        -- Включаем режим полёта
        hum.PlatformStand = true
        
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

        flightConnection = RunService.Heartbeat:Connect(function()
            if not scriptActive or not nowe or not chr:FindFirstChild("HumanoidRootPart") then return end
            
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
        -- Выключаем режим полёта
        hum.PlatformStand = false
        hum:ChangeState(Enum.HumanoidStateType.Landed)
        
        if flightConnection then
            flightConnection:Disconnect()
            flightConnection = nil
        end
        
        for _, part in pairs(flyingParts) do
            if part and part.Parent then
                part:Destroy()
            end
        end
        flyingParts = {}
    end
end

-- Подключение для переключения fly по H (однократно!)
local flightToggleConnection = UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.H then
        toggleFlight()
    end
end)

-- Логика перетаскивания слайдера и ручного ввода скорости
local draggingSpeed = false

speedBarFrame.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingSpeed = true
    end
end)

speedBarFrame.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingSpeed = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingSpeed and input.UserInputType == Enum.UserInputType.MouseMovement then
        local pos = input.Position.X - speedBarFrame.AbsolutePosition.X
        local barWidth = speedBarFrame.AbsoluteSize.X
        local newSpeed = math.clamp(math.floor((pos / barWidth) * 50), 1, 50)
        speeds = newSpeed
        speedIndicator.Size = UDim2.new(newSpeed/50, 0, 1, 0)
        speedValueLabel.Text = tostring(newSpeed)
    end
end)

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

speedValueLabel.FocusLost:Connect(function(enterPressed)
    local enteredText = speedValueLabel.Text 
    local num = tonumber(enteredText)
    if num then
        speeds = math.clamp(num, 1, 50)
        speedValueLabel.Text = tostring(speeds)
        speedIndicator.Size = UDim2.new(speeds/50, 0, 1, 0)
    else
        speedValueLabel.Text = tostring(speeds)
    end
end)

local function SwitchTab(tabName)
    currentTab = tabName
    MainFrameConetent.Visible = tabName == "menu"
    AutoFarmFrame.Visible = tabName == "autofarm"
    EspFrame.Visible = tabName == "esp"
    MovementFrame.Visible = tabName == "movement"
    SettingsFrame.Visible = tabName == "settings"
        
    MainMenuTabButton.BackgroundColor3 = tabName == "menu" and Theme.AccentColor or Theme.ElementBackground
    AutoFarmTabButton.BackgroundColor3 = tabName == "autofarm" and Theme.AccentColor or Theme.ElementBackground
    MovementTabButton.BackgroundColor3 = tabName == "movement" and Theme.AccentColor or Theme.ElementBackground
    EspTabButton.BackgroundColor3 = tabName == "esp" and Theme.AccentColor or Theme.ElementBackground


    ContentFrame.CanvasPosition = Vector2.new(0, 0)
end

    local listening = false
local currentKeybind = nil

local function UpdateKeybinds()
    -- Обновляем обработчики для новых кейбиндов
    if flightToggleConnection then
        flightToggleConnection:Disconnect()
    end
    
    flightToggleConnection = UserInputService.InputBegan:Connect(function(input, processed)
        if not processed and input.KeyCode == Keybinds.Fly then
            toggleFlight()
        end
    end)
end

local function ListenForKey(keybindName, button)
    listening = true
    currentKeybind = keybindName
    button.Text = "[...]"
    
    local connection
    connection = UserInputService.InputBegan:Connect(function(input, processed)
        if processed then return end
        
        -- Обработка Backspace для установки None
        if input.KeyCode == Enum.KeyCode.Backspace then
            Keybinds[keybindName] = NONE_KEY
            saveKeybinds()
            button.Text = "[None]"
            listening = false
            connection:Disconnect()
            return
        end
        
        -- Обработка отмены
        if input.KeyCode == Enum.KeyCode.Escape then
            button.Text = "["..Keybinds[keybindName].Name.."]"
            listening = false
            connection:Disconnect()
            return
        end
        
        -- Обработка клавиш
        if input.UserInputType == Enum.UserInputType.Keyboard then
            Keybinds[keybindName] = input.KeyCode
            saveKeybinds()
            UpdateKeybinds()
            button.Text = "["..input.KeyCode.Name.."]"
            listening = false
            connection:Disconnect()
        end
    end)
end



flyKeyBtn.MouseButton1Click:Connect(function()
    if not listening then ListenForKey("Fly", flyKeyBtn) end
end)

playerEspKeyBtn.MouseButton1Click:Connect(function()
    if not listening then ListenForKey("PlayerESP", playerEspKeyBtn) end
    print("player esp binded")
end)

mobEspKeyBtn.MouseButton1Click:Connect(function()
    if not listening then ListenForKey("MobESP", mobEspKeyBtn) end
    print("mobs esp binded")
end)

menuKeyBtn.MouseButton1Click:Connect(function()
    if not listening then ListenForKey("Menu", menuKeyBtn) end
end)

MainMenuTabButton.MouseButton1Click:Connect(function()
    SwitchTab("menu")
end)

AutoFarmTabButton.MouseButton1Click:Connect(function()
    SwitchTab("autofarm")
end)

EspTabButton.MouseButton1Click:Connect(function()
    SwitchTab("esp")
end)

MovementTabButton.MouseButton1Click:Connect(function()
    SwitchTab("movement")
end)

SettingsButton.MouseButton1Click:Connect(function()
    SwitchTab("settings")
end)

CloseButton.MouseButton1Click:Connect(function()
    ScreenGui.Enabled = false
end)

espMobsButton.MouseButton1Click:Connect(function()
    ESP.ToggleMobs(not ESP.Enabled.Mobs)
end)

espPlayerButton.MouseButton1Click:Connect(function()
    ESP.TogglePlayers(not ESP.Enabled.Players)
end)

flyButton.MouseButton1Click:Connect(function()
    toggleFlight()
    flyKeyBtn.Text = "["..Keybinds.Fly.Name.."]"
end)

ExitButton.MouseButton1Click:Connect(function()
    -- Отключаем ESP-систему
    ESP.ToggleMobs(false)
    ESP.TogglePlayers(false)
    
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
    
    -- Если режим полёта активен, выключаем его
    if nowe then
        toggleFlight()
    end
    
    -- Отключаем обработчик переключения fly (H key)
    if flightToggleConnection then
        flightToggleConnection:Disconnect()
        flightToggleConnection = nil
    end
    
    -- Выключаем fly-систему (больше не реагировать)
    scriptActive = false
    
    -- Удаляем интерфейс
    if ScreenGui then
        ScreenGui:Destroy()
    end
end)

-- Обновляем обработчик открытия меню
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Keybinds.Menu then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Keybinds.PlayerESP then
        ESP.TogglePlayers(not ESP.Enabled.Players)
    end
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Keybinds.MobESP then
        ESP.ToggleMobs(not ESP.Enabled.Mobs)
    end
end)
