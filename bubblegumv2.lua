local function notify(title, text)
    print("[NOTIFICATION]", title, text)
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = title,
            Text = text,
            Duration = 10
        })
    end)
end

if IY_LOADED and not _G.IY_DEBUG == true then
    notify("Error", "Lauria Hub is already running!")
    return
end

pcall(function() getgenv().IY_LOADED = true end)

local cloneref = cloneref or function(o) return o end
COREGUI = cloneref(game:GetService("CoreGui"))
Players = cloneref(game:GetService("Players"))

if not game:IsLoaded() then
    local notLoaded = Instance.new("Message")
    notLoaded.Parent = COREGUI
    notLoaded.Text = "Lauria is waiting for the game to load"
    game.Loaded:Wait()
    notLoaded:Destroy()
end

notify("Lauria Hub", "Setup completed")


local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
-- Для эмуляции нажатий клавиш
local VirtualInputManager = game:GetService("VirtualInputManager")

-- Переменные для авто-лутирования пикапов
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Список нужных эффектов
local effectNames = {"Light Effect", "Shine", "Stars"}

local soundNames = {"ButtonPress", "ButtonRelease"}

-- Папка с эффектами
local pickupFolder = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Particles"):WaitForChild("Pickup")

local soundFolder = ReplicatedStorage:WaitForChild("Assets"):WaitForChild("Sounds"):WaitForChild("Interface")

-- Устанавливаем LifeTime = NumberRange.new(0, 0) для каждого эффекта
for _, name in ipairs(effectNames) do
    local effect = pickupFolder:FindFirstChild(name)
    if effect and effect:IsA("ParticleEmitter") then
        effect.Lifetime = NumberRange.new(0, 0)
    end
end

for _, name in ipairs(soundNames) do
    local sound = soundFolder:FindFirstChild(name)
    if sound and sound:IsA("Sound") then
        sound.Volume = 0
    end
end

local player = game.Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:FindFirstChild("HumanoidRootPart")
if not hrp then
    warn("[PickupDebug] HumanoidRootPart не найден в персонаже!")
    return
end


local CollectPickup = ReplicatedStorage.Remotes.Pickups:WaitForChild("CollectPickup")
-- Список имен моделей, которые нужно пропускать (с пробелами)
local skipNames = {
    ["Inferno Egg"] = true, 
    ["Coming Soon"] = true,
    ["Common Egg"] = true,
    ["Spotted Egg"] = true,
    ["Iceshard Egg"] = true,
    ["Spikey Egg"] = true,
    ["Magma Egg"] = true,
    ["Crystal Egg"] = true,
    ["Lunar Egg"] = true,
    ["Void Egg"] = true,
    ["Hell Egg"] = true,
    ["Nightmare Egg"] = true,
    ["Rainbow Egg"] = true,
    ["Infinity Egg"] = true,
    ["Aura Egg"] = true,
    ["Pastel Egg"] = true,
    ["Bunny Egg"] = true
}

-- Функция для отладочных сообщений
local function debugLog(msg)
    print("[AutoLoot] " .. msg)
end

-- Список типов яиц
local eggTypes = {
    "nightmare-egg",
    "void-egg",
    "rainbow-egg",
    "event-1",
    "event-2",
    "aura-egg",
    "royal-chest"
}

-- Переменные состояния
local selectedEggs = {}
local movementConnection
local SAFE_Y_LEVEL = -100
local autofarmEnabled = false
local originalPosition
local isReturning = false
local currentTargetEgg
local isAtTargetPosition = false
local autoPlaytimeEnabled = false
-- смещение по Y при телепортации к цели
local TELEPORT_Y_OFFSET = 3

-- Функция для имитации нажатия произвольной клавиши через VirtualInputManager
local function tapKey(keyCode, duration)
    if VirtualInputManager and VirtualInputManager.SendKeyEvent then
        VirtualInputManager:SendKeyEvent(true, keyCode, false, game)
        task.wait(duration or 0.1)
        VirtualInputManager:SendKeyEvent(false, keyCode, false, game)
    else
        warn("VirtualInputManager unavailable; cannot simulate key press: ", keyCode)
    end
end

-- Функция для короткого движения вперед
local function tapMoveForward(duration)
    -- Эмулируем удержание W: Humanoid.Move работает только для движения
    local char = Players.LocalPlayer.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid:Move(Vector3.new(0, 0, 1), true)
        task.wait(duration or 0.1)
        humanoid:Move(Vector3.zero, true)
    end
end

-- Функции фриза персонажа
local function freezeCharacter()
    local hrp = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.Anchored = true end
end
local function unfreezeCharacter()
    local hrp = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.Anchored = false end
end

-- Конфигурация окна Rayfield
local config = {
    Name = "Lauria Script",
    LoadingTitle = "Lauria Script Loading",
    LoadingSubtitle = "by Developer",
    ConfigurationSaving = { Enabled = true, FolderName = "LauriaConfig", FileName = "LauriaSettings" },
    Discord = { Enabled = true, Invite = "https://discord.gg/WM7edScy" },
    KeySystem = false,
    Theme = "Default"
}
local Window = Rayfield:CreateWindow(config)

--------------------------------------------------------------------------------
-- Движение к позиции по XZ
--------------------------------------------------------------------------------
local function moveToXZ(targetXZ, onReached)
    if movementConnection then movementConnection:Disconnect(); movementConnection = nil end
    unfreezeCharacter()
    debugLog("Moving toward: " .. tostring(targetXZ))
    movementConnection = RunService.RenderStepped:Connect(function()
        if not autofarmEnabled and not isReturning then
            debugLog("Movement cancelled: autofarm and return disabled")
            movementConnection:Disconnect(); movementConnection = nil; return
        end
        local hrp = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return end
        local currentXZ = Vector3.new(hrp.Position.X, 0, hrp.Position.Z)
        local dir = Vector3.new(targetXZ.X, 0, targetXZ.Z) - currentXZ
        if dir.Magnitude < 2 then
            debugLog("Reached target XZ: " .. tostring(targetXZ))
            movementConnection:Disconnect(); movementConnection = nil; onReached()
        else
            hrp.Velocity = dir.Unit * 25
        end
    end)
end

local function returnToOriginalXZ()
    debugLog("Starting return to original position")
    isReturning = true
    local hrp = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp and originalPosition then
        moveToXZ(Vector3.new(originalPosition.X, 0, originalPosition.Z), function()
            debugLog("Reached original XZ, snapping back to full position")
            hrp.CFrame = CFrame.new(originalPosition)
            task.wait(0.1)
            isReturning = false
            unfreezeCharacter()
            tapKey(Enum.KeyCode.R, 0.1)
            debugLog("Return complete")
        end)
    else
        debugLog("No original position found, unfreezing and resetting")
        isReturning = false
        unfreezeCharacter()
        tapKey(Enum.KeyCode.R, 0.1)
        debugLog("Return complete (fallback)")
    end
end


--------------------------------------------------------------------------------
-- Работа с яйцами
--------------------------------------------------------------------------------
local function findBestEgg()
    local bestEgg, maxLuck = nil, 0
    local rifts = Workspace:FindFirstChild("Rendered") and Workspace.Rendered:FindFirstChild("Rifts")
    if not rifts then warn("Rifts folder not found!"); return nil end
    for _, name in ipairs(selectedEggs) do
        local egg = rifts:FindFirstChild(name)
        if egg and egg:IsA("Model") then
            local luckObj = egg:FindFirstChild("Display")
                and egg.Display:FindFirstChild("SurfaceGui")
                and egg.Display.SurfaceGui:FindFirstChild("Icon")
                and egg.Display.SurfaceGui.Icon:FindFirstChild("Luck")
            local luck = luckObj and tonumber(luckObj.Text:match("%d+")) or 0
            if luck > maxLuck then maxLuck, bestEgg = luck, egg end
        end
    end
    if bestEgg then
        local platform = bestEgg:FindFirstChild("EggPlatformSpawn")
        if platform then
            local part = platform:FindFirstChild("Part")
            if part and part:IsA("BasePart") then
               -- print(("EggPlatform.Part для %s находится в %s"):format(bestEgg.Name, tostring(part.Position)))
            end
        end
    end
    if bestEgg and not bestEgg:FindFirstChild("EggPlatformSpawn") then warn("EggPlatformSpawn missing in", bestEgg.Name); return nil end
    return bestEgg
end

local function getEggPosition(egg)
    local platform = egg:FindFirstChild("EggPlatformSpawn")
    if platform then
        local part = platform:FindFirstChild("Part")
        if part and part:IsA("BasePart") then return part.Position end
    end
    for _, part in ipairs(egg:GetDescendants()) do
        if part:IsA("BasePart") and part.CanCollide then return part.Position end
    end
    if egg.PrimaryPart then return egg.PrimaryPart.Position end
    local cf, size = egg:GetBoundingBox() return cf.p + Vector3.new(0, size.Y/2, 0)
end

local function teleportToPosition(cf)
    local char = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
    local hrp = char:WaitForChild("HumanoidRootPart")
    local origHeight = Workspace.FallenPartsDestroyHeight
    Workspace.FallenPartsDestroyHeight = -math.huge

    local targetCF
    if currentTargetEgg and currentTargetEgg.Name == "void-egg" then
        local hitbox = currentTargetEgg:FindFirstChild("Hitbox")
        if hitbox and hitbox:IsA("BasePart") then
            local hbPos = hitbox.CFrame.p
            targetCF = CFrame.new(hbPos.X, hbPos.Y + TELEPORT_Y_OFFSET + 5, hbPos.Z)
        else targetCF = cf * CFrame.new(0, TELEPORT_Y_OFFSET, 0) end
    else targetCF = cf * CFrame.new(0, TELEPORT_Y_OFFSET, 0) end

    hrp.CFrame = targetCF; hrp.Velocity = Vector3.new(0,0,0)
    Workspace.FallenPartsDestroyHeight = origHeight

    task.wait(0.2)
    tapMoveForward(0.1)
    freezeCharacter()
    -- Нажать R через VirtualInputManager
    tapKey(Enum.KeyCode.R, 0.1)
end

--------------------------------------------------------------------------------
-- Основной процесс автофарма
--------------------------------------------------------------------------------
local function resetState() currentTargetEgg, isAtTargetPosition = nil, false end
local function startAutofarmProcess()
    debugLog("Autofarm process started")
    coroutine.wrap(function()
        while autofarmEnabled do
            task.wait(1)
            if isReturning then
                debugLog("Currently returning, skipping this cycle")
            else
                debugLog("Autofarm cycle start")
                local egg = findBestEgg()
                if not egg then
                    debugLog("No suitable egg found, initiating return")
                    returnToOriginalXZ()
                    -- сбрасываем текущее таргет-egg и ждем возврата перед новой попыткой
                    currentTargetEgg = nil
                    task.wait(3)
                else
                    debugLog("Selected egg: " .. egg.Name)
                    if egg ~= currentTargetEgg then
                        currentTargetEgg = egg
                        local pos = getEggPosition(egg)
                        originalPosition = Players.LocalPlayer.Character.HumanoidRootPart.Position
                        debugLog("Teleporting out of sight to safe height")
                        local hrp = Players.LocalPlayer.Character.HumanoidRootPart
                        hrp.CFrame = CFrame.new(hrp.Position.X, SAFE_Y_LEVEL, hrp.Position.Z)
                        task.wait(0.2)
                        debugLog("Moving to egg position: " .. tostring(pos))
                        moveToXZ(Vector3.new(pos.X,0,pos.Z), function()
                            debugLog("Teleporting to egg: " .. egg.Name)
                            teleportToPosition(CFrame.new(pos.X, pos.Y, pos.Z))
                            isAtTargetPosition = true
                            coroutine.wrap(function()
                                while autofarmEnabled and isAtTargetPosition do
                                    if not currentTargetEgg or not currentTargetEgg:IsDescendantOf(Workspace) then
                                        debugLog("Egg collected or disappeared, resetting state")
                                        resetState()
                                        break
                                    end
                                    task.wait(1)
                                end
                            end)()
                        end)
                    end
                end
            end
        end
        debugLog("Autofarm process ended")
    end)()
end

local playtime = Players.LocalPlayer:WaitForChild("PlayerGui"):WaitForChild("ScreenGui"):WaitForChild("Playtime")
local spinner = Players.LocalPlayer.PlayerGui.ScreenGui.Spinner
local hud = Players.LocalPlayer.PlayerGui.ScreenGui.HUD

local function startAutoPlayTime()
    task.spawn(function()
        print("[AutoPlayTime] Запуск автоматического просмотра playtime")
        local playtime = Players.LocalPlayer.PlayerGui.ScreenGui.Playtime
        local spinner  = Players.LocalPlayer.PlayerGui.ScreenGui.Spinner
        local hud      = Players.LocalPlayer.PlayerGui.ScreenGui.HUD
        local gui      = playtime.Frame.Main

        while autoPlaytimeEnabled do
           -- print("[AutoPlayTime] Новый цикл проверки слотов")

            -- пробегаем по слотам 1–9
            for i = 1, 9 do
                if not autoPlaytimeEnabled then
                    print("[AutoPlayTime] Отключено, выходим")
                    return
                end

                local slot = gui:FindFirstChild(tostring(i))
                if not slot or not slot:FindFirstChild("Completed") then
                  --  print(string.format("[AutoPlayTime] Слот %d не найден или нет Completed", i))
                    continue
                end

                -- проверяем, что слот ещё не открыт
                if slot.Completed.Visible then
                 --   print(string.format("[AutoPlayTime] Слот %d уже открыт, пропускаем", i))
                    continue
                end

                -- проверяем, что кнопка и её Label == "Open"
                local button = slot:FindFirstChild("Button")
                local label  = button and button:FindFirstChild("Label")
                if not (button and button:IsA("ImageButton") and label and label.Text == "Open") then
                  --  print(string.format("[AutoPlayTime] В слоте %d нет кнопки Open или текст не соответствует", i))
                    continue
                end

                -- Открываем слот
                print(string.format("[AutoPlayTime] Открываем слот %d", i))
                local success, err = pcall(function()
                    button:SetAttribute("Pressed", true)
                    task.wait(0.1)
                    button:SetAttribute("Pressed", false)

					if spinner.Visible then
						spinner.Visible  = false
						hud.Visible      = true
					end
					task.wait(0.1)
                    spinner.Skip.Button:SetAttribute("Pressed", true)
                    task.wait(0.1)
                    spinner.Skip.Button:SetAttribute("Pressed", false)
					task.wait(0.5)
					playtime:GetPropertyChangedSignal("Visible"):Wait()
					if playtime.Visible then
						playtime.Visible = false
						local close_btn = playtime.Frame.Top.Close.Button
						close_btn:SetAttribute("Pressed", true)
						task.wait(0.1)
						close_btn:SetAttribute("Pressed", false)
						spinner.Visible  = false
						hud.Visible      = true
						--print("[AutoPlayTime] Playtime снова появился — сразу скрыт, новый цикл")
					end
                end)
                if success then
                   -- print(string.format("[AutoPlayTime] Слот %d успешно открыт", i))
                else
                    warn(string.format("[AutoPlayTime] Ошибка при открытии слота %d: %s", i, err))
                end
                    task.wait(0.2)
                break  -- выходим из for, сразу переходим к следующему циклу
            end

            -- простой таймаут перед новой проверкой
            task.wait(1)
        end

       -- print("[AutoPlayTime] Автоматический просмотр playtime остановлен")
    end)
end

local function startAutoChests()
local quickCollect = Players.LocalPlayer.PlayerGui.ScreenGui.WorldMap.QuickCollect.Button
	    task.spawn(function()
			 while AutoChestsEnabled do
				--print("quick collect")
				quickCollect:SetAttribute("Pressed", true)
				task.wait(0.1)
				quickCollect:SetAttribute("Pressed", false)
			task.wait(1)
		end
	end)
end

local function startAutoLoot()
    task.spawn(function()
        while autoLootEnabled do
            for _, folder in ipairs(Workspace.Rendered:GetChildren()) do
                if folder.Name == "Chunker" then
                    for _, model in ipairs(folder:GetChildren()) do
                        if model:IsA("Model") and not skipNames[model.Name] then
                            local meshParts = {}
                            
                            -- Сбор всех MeshPart
                            for _, part in ipairs(model:GetDescendants()) do
                                if part:IsA("MeshPart") then
                                    table.insert(meshParts, part)
                                end
                            end

                            -- Обработка только если есть MeshPart
                            if #meshParts > 0 then
                                local mesh = meshParts[1]
                                model.PrimaryPart = mesh
                                -- Отправка событий и очистка
                                CollectPickup:FireServer(model.Name)
                                CollectPickup:FireServer(model.PrimaryPart.Position)
                                model:ClearAllChildren()
                            end
                        end
                    end
                end
            end
            task.wait(0.5)
        end
    end)
end



local function startAutoSpinWheel()
    local wheelGui = Players.LocalPlayer.PlayerGui.ScreenGui.WheelSpin.Frame.Main

    -- Кнопка “Free Spin” и её Label
    local getTicketButton = wheelGui.Buttons.Free.Button
    local getTicketLabel  = getTicketButton:FindFirstChild("Label")

    -- Кнопка “Spin” и счётчик билетов
    local spinButton        = wheelGui.Spin.Button
    local ticketCountLabel  = spinButton.Amount:FindFirstChild("Label")

    task.spawn(function()
        while autoSpinWheelEnabled do
            task.wait(1)  -- пауза между проверками
            -- 1) Бесплатный спин?
            if getTicketLabel and getTicketLabel.Text == "FREE SPIN" then
                print("[AutoSpin] Free Spin available → clicking Get Ticket")
                getTicketButton:SetAttribute("Pressed", true)
                task.wait(0.1)
                getTicketButton:SetAttribute("Pressed", false)
                task.wait(0.5)
            end

            -- 2) Есть платные билеты?
            local count = tonumber(ticketCountLabel.Text) or 0
            if count >= 1 then
                print(string.format("[AutoSpin] %d paid tickets → clicking Spin", count))
                spinButton:SetAttribute("Pressed", true)
                task.wait(0.1)
                spinButton:SetAttribute("Pressed", false)
                task.wait(1)
            end
        end
    end)
end



--------------------------------------------------------------------------------
-- UI: вкладки и элементы
--------------------------------------------------------------------------------
local HomeTab = Window:CreateTab("Home","home")
HomeTab:CreateSection("Update Log")
HomeTab:CreateLabel("Label Example", 4483362458, Color3.fromRGB(255, 255, 255), false) -- Title, Icon, Color, IgnoreTheme

loadstring(game:HttpGet("https://raw.githubusercontent.com/Manheten22/LaurisScr/refs/heads/main/bubblegum.lua"))()

local AutofarmTab = Window:CreateTab("Autofarm","archive")
AutofarmTab:CreateSection("AutoFarm Settings")
AutofarmTab:CreateDropdown({Name="Select Eggs",Options=eggTypes,CurrentOption={},MultipleOptions=true,Flag="EggSelection",Callback=function(opts)selectedEggs=opts end})
AutofarmTab:CreateToggle({Name="Autofarm",CurrentValue=false,Flag="AutofarmFlag",Callback=function(Value)
    autofarmEnabled = Value
    local hrp = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if Value then unfreezeCharacter(); startAutofarmProcess() else
        if hrp then hrp.CFrame = CFrame.new(hrp.Position.X, SAFE_Y_LEVEL, hrp.Position.Z); unfreezeCharacter() end
        returnToOriginalXZ()
    end
end})

local SettingsTab = Window:CreateTab("Settings","cog")
SettingsTab:CreateSection("Settings")

SettingsTab:CreateToggle({Name="Auto Chest",CurrentValue=false,Flag="AutoChestFlag",Callback=function(Value)
    AutoChestsEnabled = Value
    if Value then
       startAutoChests()
    end
end})

SettingsTab:CreateToggle({Name="Auto Playtime",CurrentValue=false,Flag="AutoPlaytimeFlag",Callback=function(Value)
    autoPlaytimeEnabled = Value
    if Value then
       startAutoPlayTime()
    end
end})

SettingsTab:CreateToggle({Name="Auto Loot",CurrentValue=false,Flag="AutoLootFlag",Callback=function(Value)
    autoLootEnabled = Value
    if Value then
       startAutoLoot()
    end
end})

SettingsTab:CreateToggle({Name="Auto Spin Wheel",CurrentValue=false,Flag="AutoSpinWhellFlag",Callback=function(Value)
    autoSpinWheelEnabled = Value
    if Value then
       startAutoSpinWheel()
    end
end})

Workspace.Rendered.Rifts.ChildRemoved:Connect(function(child)
    if autofarmEnabled and table.find(selectedEggs,child.Name) and child==currentTargetEgg then
        resetState()
        local hrp = Players.LocalPlayer.Character and Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = CFrame.new(hrp.Position.X, SAFE_Y_LEVEL, hrp.Position.Z) end
        returnToOriginalXZ()
    end
end)
