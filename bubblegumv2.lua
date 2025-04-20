    --!strict
    local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

    -- Жёстко прописанный список типов яиц
    local eggTypes = {
        "nightmare-egg",
        "void-egg",
        "rainbow-egg",
        "event-1",
        "event-2",
        "aura-egg",
        "royal-chest"
    }

    local selectedEggs = {}
    local originalWalkSpeed
    local originalJumpPower
    local antiGravityForces = {}
    local movementConnection
    local SAFE_Y_LEVEL = -100
    local isTravelingToEgg = false
    local currentTargetEgg = nil
    -- Добавим новые переменные для контроля состояния
    local isAtTargetPosition = false
    local lastTargetPosition = nil

    -- Создаем защищенную конфигурацию
    local config = {
        Name = "Lauria Script" or "Default Name", -- Защита от nil
        LoadingTitle = "Lauria Script Loading",
        LoadingSubtitle = "by Developer",
        ConfigurationSaving = {
            Enabled = true,
            FolderName = "LauriaConfig", -- Обязательный параметр
            FileName = "LauriaSettings"  -- Обязательный параметр
        },
        Discord = {
            Enabled = true,
            Invite = "https://discord.gg/WM7edScy" -- Добавляем пустую строку вместо nil
        },
        KeySystem = false,
        Theme = "Default" -- Явно указываем тему
    }

    local Window = Rayfield:CreateWindow(config)

    -- Убедимся что все элементы имеют уникальные флаги
    local ElementsFlags = {
        AutoAttack = "AutoAttackFlag",
        AimAssist = "AimAssistFlag",
        NoFog = "NoFogFlag",
        Distance = "DistanceFlag"
    }

    -- Combat Tab
    local CombatTab = Window:CreateTab("Combat", "swords")

    -- Section: Attacking
    CombatTab:CreateSection("Attacking")
    CombatTab:CreateToggle({
        Name = "⚔ Auto Attack",
        CurrentValue = false,
        Flag = ElementsFlags.AutoAttack, -- Уникальный флаг
        Callback = function(Value)
            -- Логика атаки
        end
    })

    -- Section: Aiming
    CombatTab:CreateSection("Aiming")
    CombatTab:CreateToggle({
        Name = "🎯 Look At Enemy",
        CurrentValue = false,
        Flag = ElementsFlags.AimAssist, -- Уникальный флаг
        Callback = function(Value)
            -- Логика прицеливания
        end
    })

    -- Visuals Tab
    local VisualsTab = Window:CreateTab("Visuals", "sparkles")
    VisualsTab:CreateSection("Effects")

    VisualsTab:CreateToggle({
        Name = "🌫 Remove Fog",
        CurrentValue = false,
        Flag = ElementsFlags.NoFog, -- Уникальный флаг
        Callback = function(Value)
            -- Логика удаления тумана
        end
    })
    loadstring(game:HttpGet("https://raw.githubusercontent.com/Manheten22/LaurisScr/refs/heads/main/bubblegum.lua"))()  
    -- Добавляем новую вкладку Autofarm
    local AutofarmTab = Window:CreateTab("Autofarm", "cog") -- Иконка шестеренки
    local AutofarmSection = AutofarmTab:CreateSection("AutoFarm Settings")



-- Создаём дропдаун для выбора яиц
local EggDropdown = AutofarmTab:CreateDropdown({
    Name = "Select Eggs",
    Options = eggTypes,
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "EggSelection",
    Callback = function(Options)
        selectedEggs = Options
print(selectedEggs)
    end
})

    -- Состояния Autofarm
    local autofarmEnabled = false
    local originalPosition = nil
    local currentTween = nil
    local isReturning = false

    -- Функция для поиска лучшего яйца
local function findBestEgg()
    local bestEgg = nil
    local maxLuck = 0
    
    local riftsFolder = workspace:WaitForChild("Rendered"):WaitForChild("Rifts")
    if not riftsFolder then 
        warn("Rifts folder not found!")
        return nil
    end

    print("Searching in Rifts folder. Children count:", #riftsFolder:GetChildren())
    print("Selected eggs:", table.concat(selectedEggs, ", "))

    for _, eggName in pairs(selectedEggs) do
        print("Checking egg type:", eggName)
        local egg = riftsFolder:FindFirstChild(eggName)
        
        if egg then
            print("Found egg instance:", egg:GetFullName())
            if egg:IsA("Model") then
                local display = egg:FindFirstChild("Display")
                local surfaceGui = display and display:FindFirstChild("SurfaceGui")
                local icon = surfaceGui and surfaceGui:FindFirstChild("Icon")
                local luck = icon and icon:FindFirstChild("Luck")
                
                if luck then
                    local luckText = luck.Text
                    local luckValue = tonumber(luckText:match("%d+")) or 0
                    print("Egg", eggName, "has luck:", luckValue)
                    
                    if luckValue > maxLuck then
                        maxLuck = luckValue
                        bestEgg = egg
                        print("New best egg:", eggName, "with luck:", luckValue)
                    end
                else
                    warn("Missing Luck component in", egg:GetFullName())
                end
            else
                warn("Found object but not Model:", egg.ClassName)
            end
        else
            print("Egg not found:", eggName)
        end
    end
    
    if bestEgg then
        -- Проверка наличия необходимых компонентов
        if not bestEgg:FindFirstChild("EggPlatformSpawn") then
            warn("EggPlatformSpawn missing in", bestEgg.Name)
            return nil
        end
    end
    return bestEgg
end

function moveToPosition(targetPos: Vector3, onReached: () -> ())
    local player = game.Players.LocalPlayer
    local character = player.Character
    if not character then return end

    local hrp = character:WaitForChild("HumanoidRootPart")
    local speed = 25

    -- Отключаем предыдущие соединения
    if connection then
        connection:Disconnect()
        connection = nil
    end

    connection = game["Run Service"].RenderStepped:Connect(function(dt)
        if not autofarmEnabled or isReturning then
            connection:Disconnect()
            return
        end

        local currentPos = hrp.Position
        local direction = (targetPos - currentPos).Unit
        local distance = (targetPos - currentPos).Magnitude

        if distance < 2 then
            connection:Disconnect()
            onReached()
            return
        end

        hrp.Velocity = direction * speed
    end)
end



local function returnToOriginalPosition()
    if not originalPosition then return end
    
    isReturning = true
    local hrp = game.Players.LocalPlayer.Character.HumanoidRootPart
    
    -- Включаем гравитацию и движение для возврата
    enableMovement()
    enableGravity()
    
    moveToPosition(Vector3.new(originalPosition.X, originalPosition.Y, originalPosition.Z), function()
        hrp.CFrame = CFrame.new(originalPosition)
        isReturning = false
    end)
end

local function disableMovement()
    local humanoid = game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
    if humanoid then
        originalWalkSpeed = humanoid.WalkSpeed
        originalJumpPower = humanoid.JumpPower
        humanoid.WalkSpeed = 0
        humanoid.JumpPower = 0
    end
end

local function enableMovement()
    local humanoid = game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
    if humanoid and originalWalkSpeed then
        humanoid.WalkSpeed = originalWalkSpeed
        humanoid.JumpPower = originalJumpPower
    end
end

local function disableGravity()
    local character = game.Players.LocalPlayer.Character
    for _, part in pairs(character:GetDescendants()) do
        if part:IsA("BasePart") and part.Mass > 0 then
            local mass = part:GetMass()
            local bodyForce = Instance.new("BodyForce")
            bodyForce.Force = Vector3.new(0, mass * workspace.Gravity, 0)
            bodyForce.Parent = part
            antiGravityForces[part] = bodyForce
        end
    end
end

local function enableGravity()
    for part, bodyForce in pairs(antiGravityForces) do
        if part:IsDescendantOf(game.Players.LocalPlayer.Character) then
            bodyForce:Destroy()
        end
    end
    antiGravityForces = {}
end

game.Players.LocalPlayer.CharacterAdded:Connect(function(character)
    if autofarmEnabled then
        character:WaitForChild("Humanoid")
        disableMovement()
        disableGravity()
    end
end)

    -- Основной процесс автофарма
-- Основной процесс автофарма
-- Обновленная функция поиска позиции яйца
local function getEggPosition(egg)
    -- Способ 1: Ищем любую часть с коллизией
    for _, part in pairs(egg:GetDescendants()) do
        if part:IsA("BasePart") and part.CanCollide then
            return part.WorldPivot.Position
        end
    end
    
    -- Способ 2: Используем модель целиком
    if egg:IsA("Model") then
        local _, size = egg:GetBoundingBox()
        return egg:GetPivot().Position + Vector3.new(0, size.Y/2, 0)
    end
    
    -- Способ 3: Резервный вариант
    return egg.WorldPivot.Position
end

local function teleportToEggSafely(targetCFrame)
    local player = game.Players.LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local root = character:WaitForChild("HumanoidRootPart")
    if not root then return end

    -- Сохраняем оригинальные настройки
    local originalDestroyHeight = workspace.FallenPartsDestroyHeight
    workspace.FallenPartsDestroyHeight = -math.huge

    -- Телепортация в три этапа
    root.CFrame = CFrame.new(root.Position.X, SAFE_Y_LEVEL, root.Position.Z) -- 1. Безопасный Y уровень
    task.wait(0.2)
    root.CFrame = CFrame.new(targetCFrame.X, SAFE_Y_LEVEL, targetCFrame.Z)   -- 2. Движение по X/Z
    task.wait(0.2)
    root.CFrame = targetCFrame                                                -- 3. Финальная позиция

    -- Восстановление при смерти
    character.AncestryChanged:Connect(function()
        if not character:IsDescendantOf(workspace) then
            task.wait(2)
            workspace.FallenPartsDestroyHeight = originalDestroyHeight
        end
    end)
end



-- Модифицированный процесс автофарма
local function startAutofarmProcess()
    while autofarmEnabled do
        task.wait(1)
        if isReturning then continue end

        local bestEgg = findBestEgg()
        if not bestEgg then
            -- Если яйца не найдены, возвращаемся и восстанавливаем настройки
            returnToOriginalPosition()
            enableMovement()
            enableGravity()
            break
        end

        if bestEgg and bestEgg ~= currentTargetEgg then
            isTravelingToEgg = true
            currentTargetEgg = bestEgg
            lastTargetPosition = nil

            local hrp = game.Players.LocalPlayer.Character.HumanoidRootPart
            
            -- Первичная телепортация на безопасный уровень
            hrp.CFrame = CFrame.new(hrp.Position.X, SAFE_Y_LEVEL, hrp.Position.Z)
            task.wait(0.5)

            local eggPlatform = bestEgg:FindFirstChild("EggPlatformSpawn")
            if eggPlatform then
                local platformPart = eggPlatform:FindFirstChild("Part")
                if platformPart and platformPart:IsA("BasePart") then
                    local partPos = platformPart.CFrame.Position
                    lastTargetPosition = partPos
                    
                    -- Движение к X/Z позиции
                    moveToPosition(Vector3.new(partPos.X, SAFE_Y_LEVEL, partPos.Z), function()
                        -- Финишная телепортация
                        teleportToEggSafely(CFrame.new(partPos.X, partPos.Y + 1, partPos.Z))
                        isAtTargetPosition = true
                        
                        -- Запускаем мониторинг позиции
                        coroutine.wrap(function()
                            while autofarmEnabled and isAtTargetPosition do
                                local currentPos = game.Players.LocalPlayer.Character.HumanoidRootPart.Position
                                local targetPos = Vector3.new(partPos.X, partPos.Y + 1, partPos.Z)
                                
                                -- Если расстояние превышает 5 метров, повторяем телепорт
                                if (currentPos - targetPos).Magnitude > 5 then
                                    teleportToEggSafely(CFrame.new(targetPos))
                                end
                                
                                -- Проверяем существование яйца
                                if not bestEgg:IsDescendantOf(workspace) then
                                    isAtTargetPosition = false
                                    isTravelingToEgg = false
                                    currentTargetEgg = nil
                                    return
                                end
                                
                                task.wait(1)
                            end
                        end)()
                    end)
                else
                    warn("Part not found")
                    resetState()
                end
            else
                warn("Platform not found")
                resetState()
            end
        end
    end
end

local function resetState()
    isTravelingToEgg = false
    currentTargetEgg = nil
    isAtTargetPosition = false
    lastTargetPosition = nil
end


-- Переключатель Autofarm
-- В callback переключателя
local AutofarmToggle = AutofarmTab:CreateToggle({
    Name = "Autofarm",
    CurrentValue = false,
    Flag = "AutofarmFlag",
    Callback = function(Value)
        autofarmEnabled = Value
        
        if Value then
            -- Сохраняем позицию и настраиваем персонажа
            local character = game.Players.LocalPlayer.Character
            if character then
                disableMovement()
                disableGravity()
                originalPosition = character.HumanoidRootPart.Position
            end
            startAutofarmProcess()
        else
            enableMovement()
            enableGravity()
            if currentTween then 
                currentTween:Cancel()
            end
            returnToOriginalPosition()
        end
    end
})

    -- Обработчик удаления яйца
-- Обновим обработчик удаления яйца
workspace.Rendered.Rifts.ChildRemoved:Connect(function(child)
    if autofarmEnabled and table.find(selectedEggs, child.Name) then
        if child == currentTargetEgg then
            resetState()
            returnToOriginalPosition()
            
            -- Ждем завершения возврата
            while isReturning do task.wait() end
            
            -- Проверяем наличие новых яиц
            local newEgg = findBestEgg()
            if not newEgg then
                enableMovement()
                enableGravity()
            else
                startAutofarmProcess()
            end
        end
    end
end)
