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
    "aura-egg",
	"rainbow-egg",
    "event-1",
    "event-2"
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
        thumbnail = "https://static.wikia.nocookie.net/bgs-infinity/images/5/5b/Common_Egg.png/revision/latest?cb=20250412180346",
        color = 0x8B0000,
        title = "Bunny Egg Rift"
    },
    ["event-2"] = {
        thumbnail = "https://static.wikia.nocookie.net/bgs-infinity/images/5/5b/Common_Egg.png/revision/latest?cb=20250412180346",
        color = 0x8B0000,
        title = "Pastle Egg Rift"
    },
    ["aura-egg"] = {
        thumbnail = "https://static.wikia.nocookie.net/bgs-infinity/images/2/2e/Aura_Egg.png/revision/latest/scale-to-width-down/150?cb=20250413042632",
        color = 0x8B0000,
        title = "Aura Egg Rift"
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
    
    -- Ожидаем полной инициализации GUI
    local maxAttempts = 5
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

    -- Получаем высоту и округляем до ближайшей 1000
    local eggPosition = egg.WorldPivot.Position
    local yHeight = eggPosition.Y
    local roundedHeight = math.round(yHeight / 1000) * 1000
    roundedHeight = string.format("%.0f", roundedHeight) -- Убираем десятичные точки

    -- Получаем числовое значение множителя
    local luckText = egg.Display.SurfaceGui.Icon.Luck.Text
    local luckValue = tonumber(luckText:match("%d+")) or 0
    local isEventEgg = table.find({"event-1", "event-2"}, egg.Name)
    local isAuraEgg = (egg.Name == "aura-egg") -- Новая проверка

    -- Условия отправки
    local shouldSend = false
    if isAuraEgg then
        shouldSend = true -- Всегда отправляем для aura-egg
    elseif isEventEgg then
        shouldSend = luckValue >= 10
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

-- Обработчик новых яиц
local function setupRiftTracking()
    local riftsFolder = workspace:WaitForChild("Rendered"):WaitForChild("Rifts")
    
    riftsFolder.ChildAdded:Connect(function(child)
        if table.find(eggTypes, child.Name) then
            print("Обнаружено новое яйцо:", child:GetFullName())    
            task.wait(3)
            sendWebhook(child)
        end
    end)
    
    riftsFolder.ChildRemoved:Connect(function(child)	
        if table.find(eggTypes, child.Name) then
            processedEggs[child] = nil
            print("Яйцо удалено:", child:GetFullName())
        end
    end)
end

-- Инициализация
game.Players.LocalPlayer.CharacterAdded:Connect(function()
    task.wait(3) -- Ожидаем загрузку персонажа
    setupRiftTracking()
end)

-- Первичная проверка существующих яиц
task.spawn(function()
    while true do
        local riftsFolder = workspace:FindFirstChild("Rendered") and workspace.Rendered:FindFirstChild("Rifts")
        if riftsFolder then
            for _, child in pairs(riftsFolder:GetChildren()) do
                if table.find(eggTypes, child.Name) and not processedEggs[child] then
                    print("Найдено существующее яйцо:", child:GetFullName())
                    task.wait(3)
                    sendWebhook(child)
                end
            end
            break
        end
    end
end)

-- Основная инициализация
setupRiftTracking()
