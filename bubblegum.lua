    if IY_LOADED and not _G.IY_DEBUG == true then
        error("Infinite Yield is already running!", 0)
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

    print("executed")

    local thread_id = "1362483933522034870"
    local webhookUrl = "https://webhook.lewisakura.moe/api/webhooks/1362782624904515684/gmieoRD304b87tj4OS1k-5zfiiigd-QpIOf0Zx9TWDy-TgVpOM37oMT32rwHUFQtyvNd?thread_id=" .. thread_id
    local eggTypes = {
        "nightmare-egg",
        "void-egg",
        "rainbow-egg",
        "event-1",
        "event-2",
        "aura-egg",
        "royal-chest"
    }

    local eggSettings = {
        ["nightmare-egg"] = {
            thumbnail = "https://static.wikia.nocookie.net/bgs-infinity/images/4/43/Nightmare_Egg.png/revision/latest?cb=20250412170032",
            color = 0x8B0000,
            title = "Nightmare Egg Rift"
        },
        ["void-egg"] = {
            thumbnail = "https://static.wikia.nocookie.net/bgs-infinity/images/5/58/Void_Egg.png/revision/latest?cb=20250412180803",
            color = 0x8B0000,
            title = "Void Egg Rift"
        },
        ["rainbow-egg"] = {
            thumbnail = "https://static.wikia.nocookie.net/bgs-infinity/images/3/3f/Rainbow_Egg.png/revision/latest?cb=20250412180318",
            color = 0x8B0000,
            title = "Rainbow Egg Rift"
        },
        ["event-1"] = {
            thumbnail = "https://images-ext-1.discordapp.net/external/YW095RmadS-yYKI_CLsHJXVeInmnYBCiCOEOXgqwonI/https/ps99.biggamesapi.io/image/136636183189937?format=webp",
            color = 0x8B0000,
            title = "Bunny Egg Rift"
        },
        ["event-2"] = {
            thumbnail = "https://images-ext-1.discordapp.net/external/r69ybVrwk0rqAABxWbcHWlW5u3lBtVO4sIqpHb52KIw/https/ps99.biggamesapi.io/image/72274303112126?format=webp",
            color = 0x8B0000,
            title = "Pastle Egg Rift"
        },
        ["aura-egg"] = {
            thumbnail = "https://static.wikia.nocookie.net/bgs-infinity/images/2/2e/Aura_Egg.png/revision/latest/scale-to-width-down/150?cb=20250413042632",
            color = 0x8B0000,
            title = "Aura Egg Rift"
        },
        ["royal-chest"] = {
            thumbnail = "https://static.wikia.nocookie.net/bgs-infinity/images/3/31/RoyalChest2.png/revision/latest?cb=20250417081313",
            color = 0x8B0000,
            title = "Royal Chest Rift"
        }


    }

    local processedEggs = {}

    -- Функция преобразования времени в секунды
    local function parseTime(timeStr)
        local total = 0
        for num, unit in timeStr:gmatch("(%d+)%s(%a+)") do
            num = tonumber(num)
            if unit:match("minute") then
                total += num * 60
            elseif unit:match("second") then
                total += num
            end
        end
        return total
    end

    -- Функция отправки сообщения
    local function sendWebhook(egg)
    if processedEggs[egg] then return end
    
    local isRoyalChest = (egg.Name == "royal-chest")
    local luckText, luckValue
    local maxAttempts = 5

    if not isRoyalChest then
        -- Ожидание GUI только для не Royal Chest
        for i = 1, maxAttempts do
            if egg:FindFirstChild("Display") and
               egg.Display:FindFirstChild("SurfaceGui") and
               egg.Display.SurfaceGui:FindFirstChild("Timer") and
               egg.Display.SurfaceGui:FindFirstChild("Icon") and
               egg.Display.SurfaceGui.Icon:FindFirstChild("Luck") then
                break
            end
            task.wait(1)
        end

        if not (egg.Display and egg.Display.SurfaceGui and egg.Display.SurfaceGui.Timer) then
            warn("⚠️ Не удалось найти компоненты яйца")
            return
        end
    end

    -- Получаем высоту
    local eggPosition = egg.WorldPivot.Position
    local yHeight = eggPosition.Y
    local roundedHeight = math.round(yHeight / 1000) * 1000
    roundedHeight = string.format("%.0f", roundedHeight)

    -- Устанавливаем значения для Royal Chest
    if isRoyalChest then
        luckText = "x1"
        luckValue = 1
    else
        luckText = egg.Display.SurfaceGui.Icon.Luck.Text
        luckValue = tonumber(luckText:match("%d+")) or 0
    end

    local isEventEgg = table.find({"event-1", "event-2"}, egg.Name)
    local isAuraEgg = (egg.Name == "aura-egg")

    -- Условия отправки
    local shouldSend = false
    if isRoyalChest then
        shouldSend = true -- Всегда отправляем Royal Chest
    elseif isAuraEgg then
        shouldSend = true
    else
        shouldSend = luckValue >= 25
    end


        -- Дополнительная проверка для event-яиц с x25+
        if luckValue >= 25 then
            shouldSend = true
        end

        if not shouldSend then
            print(string.format("🚫 Неподходящий множитель: %s (%d) для %s", 
                luckText, luckValue, egg.Name))
            return
        end

        -- Остальная часть функции
        local timerText = egg.Display.SurfaceGui.Timer.Text
        local duration = parseTime(timerText)
        local pingRoleId = "<@&1114528761887608883>"

        task.wait(3)
        timerText = egg.Display.SurfaceGui.Timer.Text
        local newDuration = parseTime(timerText)
        duration = math.max(duration, newDuration)
        
        if duration <= 0 then return end

        local currentUnix = os.time()
        local despawnUnix = currentUnix + duration

        local settings = eggSettings[egg.Name]
        if not settings then
            warn("⚠️ Неизвестный тип яйца:", egg.Name)
            return
        end

        local embedData = {
            content = pingRoleId,
            username = "Lauria Rifts",
            embeds = {{
                title = settings.title .. " has spawned!",
                thumbnail = {url = settings.thumbnail},
                color = settings.color,
                fields = {
                    {
                        name = "Teleport Command", 
                        value = string.format("```lua\ngame:GetService('TeleportService'):TeleportToPlaceInstance(%s, '%s')\n```", 
                            game.PlaceId, game.JobId),
                        inline = false
                    },
                    {
                        name = "Server Info",
                        value = string.format("👥 Players: %d/%d", #Players:GetPlayers(), Players.MaxPlayers),
                        inline = false
                    },
                    {
                        name = "Rift Info",
                        value = string.format(
                            "🍀 Luck Multiplier: %s\n🕒 Despawns: <t:%d:R>\n📏Height: %s",
                            luckText, despawnUnix, roundedHeight
                        ),
                        inline = false
                    }
                },
                footer = {text = "by lauria • " .. os.date("Сегодня, в %H:%M")}
            }}
        }

        local success = pcall(function()
            request({
                Url = webhookUrl,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = game:GetService("HttpService"):JSONEncode(embedData)
            })
        end)
        
        if success then
            print("✅ Уведомление отправлено для", egg:GetFullName())
            processedEggs[egg] = true
        else
            warn("⛔ Ошибка отправки для", egg:GetFullName())
        end
    end

    -- Обработчик новых яиц (уже параллельный)
    local function setupRiftTracking()
        local riftsFolder = workspace:WaitForChild("Rendered"):WaitForChild("Rifts")
        
        riftsFolder.ChildAdded:Connect(function(child)
            if table.find(eggTypes, child.Name) then
                print("Обнаружено новое яйцо:", child:GetFullName())
                task.spawn(function()
                    task.wait(3) -- Ожидание инициализации GUI
                    sendWebhook(child)
                end)
            end
        end)
        
        riftsFolder.ChildRemoved:Connect(function(child)    
            if table.find(eggTypes, child.Name) then
                processedEggs[child] = nil
                print("Яйцо удалено:", child:GetFullName())
            end
        end)
    end


    -- Первичная проверка существующих яиц
    task.spawn(function()
        local riftsFolder = workspace:WaitForChild("Rendered"):WaitForChild("Rifts")
        
        local function processEggAsync(child)
            if table.find(eggTypes, child.Name) and not processedEggs[child] then
                print("Найдено существующее яйцо:", child:GetFullName())
                task.wait(3)
                sendWebhook(child)
            end
        end
    
        for _, child in pairs(riftsFolder:GetChildren()) do
            task.spawn(processEggAsync, child)
        end
    end)

    setupRiftTracking()

    wait(0.5)local ba=Instance.new("ScreenGui")
    local ca=Instance.new("TextLabel")local da=Instance.new("Frame")
    local _b=Instance.new("TextLabel")local ab=Instance.new("TextLabel")ba.Parent=game.CoreGui
    ba.ZIndexBehavior=Enum.ZIndexBehavior.Sibling;ca.Parent=ba;ca.Active=true
    ca.BackgroundColor3=Color3.new(0.176471,0.176471,0.176471)ca.Draggable=true
    ca.Position=UDim2.new(2,0,2,0)ca.Size=UDim2.new(0,370,0,52)
    ca.Font=Enum.Font.SourceSansSemibold;ca.Text="Anti Afk"ca.TextColor3=Color3.new(0,1,1)
    ca.TextSize=22;da.Parent=ca
    da.BackgroundColor3=Color3.new(0.196078,0.196078,0.196078)da.Position=UDim2.new(0,0,1.0192306,0)
    da.Size=UDim2.new(0,370,0,107)_b.Parent=da
    _b.BackgroundColor3=Color3.new(0.176471,0.176471,0.176471)_b.Position=UDim2.new(0,0,0.800455689,0)
    _b.Size=UDim2.new(0,370,0,21)_b.Font=Enum.Font.Arial;_b.Text="Made by luca#5432"
    _b.TextColor3=Color3.new(0,1,1)_b.TextSize=20;ab.Parent=da
    ab.BackgroundColor3=Color3.new(0.176471,0.176471,0.176471)ab.Position=UDim2.new(0,0,0.158377,0)
    ab.Size=UDim2.new(0,370,0,44)ab.Font=Enum.Font.ArialBold;ab.Text="Status: Active"
    ab.TextColor3=Color3.new(0,1,1)ab.TextSize=20;local bb=game:service'VirtualUser'
    game:service'Players'.LocalPlayer.Idled:connect(function()
    bb:CaptureController()bb:ClickButton2(Vector2.new())
    ab.Text="Roblox tried kicking you buy I didnt let them!"wait(2)ab.Text="Status : Active"end)

