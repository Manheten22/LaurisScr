local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "KeyCheckGui"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui
local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 350, 0, 120)
frame.Position = UDim2.new(0.5, -175, 0.5, -60)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.BorderSizePixel = 0
frame.Parent = screenGui
local textBox = Instance.new("TextBox")
textBox.Name = "KeyInput"
textBox.PlaceholderText = "Enter your key here"
textBox.Font = Enum.Font.SourceSans
textBox.TextSize = 24
textBox.ClearTextOnFocus = false
textBox.Size = UDim2.new(0, 240, 0, 40)
textBox.Position = UDim2.new(0, 10, 0, 10)
textBox.Parent = frame
textBox.Text = ""
local button = Instance.new("TextButton")
button.Name = "NextButton"
button.Text = "Next"
button.Font = Enum.Font.SourceSansBold
button.TextSize = 24
button.Size = UDim2.new(0, 80, 0, 40)
button.Position = UDim2.new(0, 260, 0, 10)
button.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
button.Parent = frame
local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.Text = ""
statusLabel.Font = Enum.Font.SourceSans
statusLabel.TextSize = 20
statusLabel.Size = UDim2.new(1, -20, 0, 50)
statusLabel.Position = UDim2.new(0, 10, 0, 60)
statusLabel.TextWrapped = true
statusLabel.TextColor3 = Color3.fromRGB(255,255,255)
statusLabel.BackgroundTransparency = 1
statusLabel.Parent = frame
local api = loadstring(game:HttpGet("https://sdkapi-public.luarmor.net/library.lua"))()
api.script_id = "0374efb065518f41319ffcba6adbcac0"
button.MouseButton1Click:Connect(function()
    local key = textBox.Text
    if #key ~= 32 then
        statusLabel.Text = "Invalid key format"
        return
    end
    statusLabel.Text = "Checking..."
    local status = api.check_key(key)
    if status.code == "KEY_VALID" then
        screenGui:Destroy()
        local secs = status.data.auth_expire > 0 and (status.data.auth_expire - os.time()) or math.huge
        statusLabel.Text = "VALID: expires in ".. tostring(secs) .."s\nExecs: ".. status.data.total_executions
        _G.script_key       = key
        getgenv().script_key = key
        api.load_script()
    elseif status.code == "KEY_HWID_LOCKED" then
        statusLabel.Text = "Key locked to another HWID.\nReset via bot."
    elseif status.code == "KEY_INCORRECT" then
        statusLabel.Text = "Key wrong or deleted!"
    else
        statusLabel.Text = "Error: ".. status.message .." (".. status.code ..")"
    end
end)
