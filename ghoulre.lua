local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")

-- Настройка уведомлений
local function notify(title, text)
    StarterGui:SetCore("SendNotification", {
        Title = title,
        Text = text,
        Duration = 10
    })
end

local LocalPlayer = Players.LocalPlayer

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
MainFrame.Size = UDim2.new(0, 320, 0, 330)
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

-- Контент
local VisualFrame = Instance.new("Frame")
VisualFrame.Size = UDim2.new(1, -10, 1, -110)
VisualFrame.Position = UDim2.new(0, 5, 0, 80)
VisualFrame.BackgroundTransparency = 1
VisualFrame.Parent = MainFrame

--Mobs ESP кнопка
local espMobsButton = Instance.new("TextButton")
espMobsButton.Size = UDim2.new(1, -20, 0, 40)
espMobsButton.Position = UDim2.new(0, 10, 0, -25)
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
espPlayerButton.Position = UDim2.new(0, 10, 0, 25)
espPlayerButton.BackgroundColor3 = Theme.ElementBackground
espPlayerButton.TextColor3 = Theme.TextColor
espPlayerButton.Text = "Player ESP"
espPlayerButton.Font = Enum.Font.GothamBold
espPlayerButton.TextSize = 16
espPlayerButton.Parent = VisualFrame

local espPlayerUICorner = Instance.new("UICorner")
espPlayerUICorner.CornerRadius = UDim.new(0, 6)
espPlayerUICorner.Parent = espPlayerButton

--Fly кнопка
local flyButton = Instance.new("TextButton")
flyButton.Size = UDim2.new(1, -20, 0, 40)
flyButton.Position = UDim2.new(0, 10, 0, 75)
flyButton.BackgroundColor3 = Theme.ElementBackground
flyButton.TextColor3 = Theme.TextColor
flyButton.Text = "Fly on H button"
flyButton.Font = Enum.Font.GothamBold
flyButton.TextSize = 14
flyButton.Parent = VisualFrame

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

-- Основные функции ESP
function ESP.ToggleMobs(enable)
    ESP.Enabled.Mobs = enable
    espMobsButton.BackgroundColor3 = enable and Theme.AccentColor or Theme.ElementBackground

    if enable then
        -- Обработка существующих мобов
        for _, mob in ipairs(Workspace.Entities:GetChildren()) do
            if mob:GetAttribute("NPC") then
                ESP.AddMobESP(mob)
            end
        end
        
        -- Подключение новых мобов
        ESP.Connections.MobAdded = Workspace.Entities.ChildAdded:Connect(function(mob)
            if mob:GetAttribute("NPC") then
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
        Connections = {},
        Holder = nil,
        Alive = true
    }
    ESP.Tracked.Players[player] = tracker

    local function Cleanup()
        if tracker.Holder then
            tracker.Holder:Destroy()
            tracker.Holder = nil
        end
        for _, conn in pairs(tracker.Connections) do
            conn:Disconnect()
        end
        table.clear(tracker.Connections)
    end

    local function SetupCharacter(character)
        Cleanup()
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

        local renderConn
        renderConn = RunService.RenderStepped:Connect(function()
            if not ESP.Enabled.Players or not holder.Parent then
                Cleanup()
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

        table.insert(tracker.Connections, renderConn)
    end

    table.insert(tracker.Connections, player.CharacterAdded:Connect(SetupCharacter))
    table.insert(tracker.Connections, player.CharacterRemoving:Connect(Cleanup))
    
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
            for _, conn in pairs(tracker.Connections) do
                conn:Disconnect()
            end
        end
        table.clear(ESP.Tracked.Players)
        
        if ESP.Connections.PlayerAdded then
            ESP.Connections.PlayerAdded:Disconnect()
        end
    end
end
espMobsButton.MouseButton1Click:Connect(function()
    ESP.ToggleMobs(not ESP.Enabled.Mobs)
end)

espPlayerButton.MouseButton1Click:Connect(function()
    ESP.TogglePlayers(not ESP.Enabled.Players)
end)

-- Обработчики интерфейса
CloseButton.MouseButton1Click:Connect(function()
    ScreenGui.Enabled = false
end)

ExitButton.MouseButton1Click:Connect(function()
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
    
    if ScreenGui then
        ScreenGui:Destroy()
    end
end)

UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.G then
        ScreenGui.Enabled = not ScreenGui.Enabled
    end
end)

-- Fly System
local speaker = game:GetService("Players").LocalPlayer
local flyingParts = {}
local connection
local nowe = false
local speeds = 10

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
