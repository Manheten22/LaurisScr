--!strict
local StartLoadTime = tick()

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

local Player = Players.LocalPlayer

local getgenv: () -> ({[string]: any}) = getfenv().getgenv

local PlaceName: string = getgenv().PlaceName or game:GetService("AssetService"):GetGamePlacesAsync(game.GameId):GetCurrentPage()[1].Name

local getexecutorname = getfenv().getexecutorname
local identifyexecutor: () -> (string) = getfenv().identifyexecutor
local request = getfenv().request
local getconnections: (RBXScriptSignal) -> ({RBXScriptConnection}) = getfenv().getconnections
local queue_on_teleport: (Code: string) -> () = getfenv().queue_on_teleport
local setfpscap: (FPS: number) -> () = getfenv().setfpscap
local isrbxactive: () -> (boolean) = getfenv().isrbxactive
local setclipboard: (Text: string) -> () = getfenv().setclipboard
local firesignal: (RBXScriptSignal) -> () = getfenv().firesignal

if not getgenv().ScriptVersion then
	getgenv().ScriptVersion = "Dev Mode"
end

local ScriptVersion = getgenv().ScriptVersion

getgenv().gethui = function()
	return game:GetService("CoreGui")
end

getgenv().FrostByteConnections = getgenv().FrostByteConnections or {}

local function HandleConnection(Connection: RBXScriptConnection?, Name: string)
	if getgenv().FrostByteConnections[Name] then
		getgenv().FrostByteConnections[Name]:Disconnect()
	end

	getgenv().FrostByteConnections[Name] = Connection
end

getgenv().HandleConnection = HandleConnection

getgenv().GetClosestChild = function(Children: {PVInstance}, Callback: ((Child: PVInstance) -> boolean)?, MaxDistance: number?)
	local Character = Player.Character

	if not Character then
		return
	end

	local HumanoidRootPart: Part = Character:FindFirstChild("HumanoidRootPart")

	if not HumanoidRootPart then
		return
	end

	local CurrentPosition: Vector3 = HumanoidRootPart.Position

	local ClosestMagnitude = MaxDistance or math.huge
	local ClosestChild

	for _, Child in Children do
		if not Child:IsA("PVInstance") then
			continue
		end

		if Callback and Callback(Child) then
			continue
		end

		local Magnitude = (Child:GetPivot().Position - CurrentPosition).Magnitude

		if Magnitude < ClosestMagnitude then
			ClosestMagnitude = Magnitude
			ClosestChild = Child
		end
	end

	return ClosestChild
end

local UnsupportedName = " (Executor Unsupported)"

local function ApplyUnsupportedName(Name: string, Condition: boolean)
	return Name..if Condition then "" else UnsupportedName
end

getgenv().ApplyUnsupportedName = ApplyUnsupportedName

if not getgenv().PlaceFileName then
	local PlaceFileName = PlaceName:gsub("%b[]", "")
	PlaceFileName = PlaceFileName:gsub("[^%a]", "")
	getgenv().PlaceFileName = PlaceFileName
end

local function SendNotification(Title: string, Text: string, Duration: number?, Button1: string?, Button2: string?, Callback: BindableFunction?)
	StarterGui:SetCore("SendNotification", {
		Title = Title,
		Text = Text,
		Duration = Duration or 10,
		Button1 = Button1,
		Button2 = Button2,
		Callback = Callback
	})
end

task.spawn(function()
	if ScriptVersion:sub(1, 1) == "v" then
		local PlaceFileName = getgenv().PlaceFileName

		local BindableFunction = Instance.new("BindableFunction")

		local Response = false

		local Button1 = "✅ Yes" 
		local Button2 = "❌ No"

		local File = `https://raw.githubusercontent.com/alyssagithub/Scripts/refs/heads/main/FrostByte/Games/{PlaceFileName}.lua`

		BindableFunction.OnInvoke = function(Button: string)
			Response = true

			if Button == Button1 then
				local Temp = loadstring(game:HttpGet(File))

				if not Temp then
					return warn("Failed to load the script for the current game.")
				end

				Temp()
			end
		end

		while task.wait(60) do
			local Result = game:HttpGet(File)

			if not Result then
				continue
			end

			Result = Result:split('getgenv().ScriptVersion = "')[2]
			Result = Result:split('"')[1]

			if Result == ScriptVersion then
				continue
			end

			SendNotification(`A new FrostByte version {Result} has been detected!`, "Would you like to load it?", math.huge, Button1, Button2, BindableFunction)

			break
		end
	end
end)

local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")

HandleConnection(Player.Idled:Connect(function()
	VirtualUser:CaptureController()
	VirtualUser:ClickButton2(Vector2.zero)
	VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.RightMeta, false, game)
	VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.RightMeta, false, game)
end), "AntiAFK")

local OriginalFlags = {}

if getgenv().Flags then
	for FlagName: string, FlagInfo in getgenv().Flags do
		if typeof(FlagInfo.CurrentValue) ~= "boolean" then
			continue
		end

		OriginalFlags[FlagName] = FlagInfo.CurrentValue
		FlagInfo:Set(false)
	end
end

if getgenv().Rayfield then
	getgenv().Rayfield:Destroy()
end

local Rayfield

if getgenv().RayfieldTesting then
	local Temp = loadstring(getgenv().RayfieldTesting)
	
	if not Temp then
		return warn("Failed to load rayfield testing.")
	end
	
	Rayfield = Temp()
	print("Running Rayfield Testing")
else
	repeat
		pcall(function()
			local Temp = loadstring(game:HttpGet("https://raw.githubusercontent.com/alyssagithub/Scripts/refs/heads/main/FrostByte/Rayfield.luau"))
			
			if not Temp then
				return warn("Failed to load rayfield.")
			end

			Rayfield = Temp()
		end)
		task.wait()
	until Rayfield
end

getgenv().Initiated = nil

type Element = {
	CurrentValue: any,
	CurrentOption: {string},
	Set: (self: Element, any) -> ()
}

type Flags = {
	[string]: Element
}

type Tab = {
	CreateSection: (self: Tab, Name: string) -> Element,
	CreateDivider: (self: Tab) -> Element,
	CreateToggle: (self: Tab, any) -> Element,
	CreateSlider: (self: Tab, any) -> Element,
	CreateDropdown: (self: Tab, any) -> Element,
	CreateButton: (self: Tab, any) -> Element,
	CreateLabel: (self: Tab, any, any?) -> Element,
	CreateParagraph: (self: Tab, any) -> Element,
}

local function Notify(Title: string, Content: string, Image: string)
	if not Rayfield then
		return
	end

	Rayfield:Notify({
		Title = Title,
		Content = Content,
		Duration = 10,
		Image = Image or "info",
	})
end

getgenv().Notify = Notify

local Flags: Flags = Rayfield.Flags

getgenv().Flags = Flags

local Window = Rayfield:CreateWindow({
	Name = `FrostByte | {PlaceName} | {ScriptVersion or "Dev Mode"}`,
	Icon = "snowflake",
	LoadingTitle = "❄ Brought to you by FrostByte ❄",
	LoadingSubtitle = PlaceName,
	Theme = "DarkBlue",

	DisableRayfieldPrompts = true,
	DisableBuildWarnings = true,

	ConfigurationSaving = {
		Enabled = true,
		FolderName = "FrostByte",
		FileName = `{getgenv().PlaceFileName or `DevMode-{game.PlaceId}`}-{Player.Name}`
	},

	Discord = {
		Enabled = true,
		Invite = "sS3tDP6FSB",
		RememberJoins = true
	},
})

getgenv().Window = Window

local Tab: Tab = Window:CreateTab("Home", "snowflake")

Tab:CreateSection("Join our Discord!")

Tab:CreateLabel("discord.gg/sS3tDP6FSB", "messages-square")

Tab:CreateSection("Performance")

local PingLabel = Tab:CreateLabel("Ping: 0 ms", "wifi")
local FPSLabel = Tab:CreateLabel("FPS: 0/s", "monitor")

local Stats = game:GetService("Stats")

task.spawn(function()
	while getgenv().Flags == Flags and task.wait(0.25) do
		PingLabel:Set(`Ping: {math.floor(Stats.PerformanceStats.Ping:GetValue() * 100) / 100} ms`)
		FPSLabel:Set(`FPS: {math.floor(1 / Stats.FrameTime * 10) / 10}/s`)
	end
end)

Tab:CreateSection("Changelog")

Tab:CreateParagraph({Title = `{PlaceName} {ScriptVersion}`, Content = getgenv().Changelog or "Changelog Not Found"})

--------------------------------------------------------------------------------------------------------------

local SpeedConnection: RBXScriptConnection?
local ConnectedHumanoid

local function SetSpeed()
	local Character = Player.Character

	if not Character then
		return
	end

	local Humanoid: Humanoid = Character:FindFirstChild("Humanoid")

	if not Humanoid then
		return
	end

	if Flags.ChangeSpeed.CurrentValue then
		Humanoid.WalkSpeed = Flags.Speed.CurrentValue
	end

	if not SpeedConnection then
		SpeedConnection = Humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(SetSpeed)
		ConnectedHumanoid = Humanoid
		HandleConnection(SpeedConnection, "WalkSpeedConnection")
	end
end

HandleConnection(Player.CharacterAdded:Connect(function()
	if SpeedConnection then
		SpeedConnection:Disconnect()
		SpeedConnection = nil
	end

	SetSpeed()
end), "WalkSpeedCharacterAdded")

local Connections = {}

local OriginalText = {}

local function HandleUsernameChange(Object)
	if not Flags.HideIdentity.CurrentValue then
		return
	end

	if not Object:IsA("TextLabel") and not Object:IsA("TextBox") and not Object:IsA("TextButton") then
		return
	end

	local NameReplacement = Flags.NameReplacement.CurrentValue

	if not Connections[Object] then
		Connections[Object] = Object:GetPropertyChangedSignal("Text"):Connect(function()
			HandleUsernameChange(Object)
		end)
	end

	if Object.Text:find(Player.Name) then
		OriginalText[Object] = Object.Text
		Object.Text = Object.Text:gsub(Player.Name, NameReplacement)
	elseif Object.Text:find(Player.DisplayName) then
		OriginalText[Object] = Object.Text
		Object.Text = Object.Text:gsub(Player.DisplayName, NameReplacement)
	end
end

local DescendantAddedConnection

type FeaturesList = {
	[string]: {
		{
			Element: string,
			Info: {}
		}
	}
}

local Features: FeaturesList = {
	Speed = {
		{
			Element = "Toggle",
			Info = {
				Name = "⚡ • Change Speed",
				CurrentValue = false,
				Flag = "ChangeSpeed",
				Callback = function(Value)
					
					if not Player.Character or not Value then
						return
					end
					
					SetSpeed()
				end,
			},
		},
		{
			Element = "Slider",
			Info = {
				Name = "⚡ • Speed",
				Range = {0, 250},
				Increment = 1,
				Suffix = "Studs/s",
				CurrentValue = game:GetService("StarterPlayer").CharacterWalkSpeed,
				Flag = "Speed",
				Callback = SetSpeed,
			}
		},
		{
			Element = "Keybind",
			Info = {
				Name = "⚡ • Change Speed Keybind",
				CurrentKeybind = "Z",
				HoldToInteract = false,
				Flag = "ChangeSpeedKeybind",
				Callback = function()
					Flags.ChangeSpeed:Set(not Flags.ChangeSpeed.CurrentValue)
				end,
			}
		}
	},
	HideIdentity = {
		{
			Element = "Toggle",
			Info = {
				Name = "🎭 • Hide Identity (Client-Sided)",
				CurrentValue = false,
				Flag = "HideIdentity",
				Callback = function(Value)
					if Value and not DescendantAddedConnection then
						for i,v in game:GetDescendants() do
							HandleUsernameChange(v)
						end

						DescendantAddedConnection = game.DescendantAdded:Connect(HandleUsernameChange)

						HandleConnection(DescendantAddedConnection, "HideIdentity")
					elseif DescendantAddedConnection then
						DescendantAddedConnection:Disconnect()
						DescendantAddedConnection = nil

						for Object, Text in OriginalText do
							Object.Text = Text
						end

						OriginalText = {}
					end
				end,
			}
		},
		{
			Element = "Input",
			Info = {
				Name = "💬 • Name To Replace With",
				CurrentValue = "FrostByte",
				PlaceholderText = "New Name Here",
				RemoveTextAfterFocusLost = false,
				Flag = "NameReplacement",
			}
		}
	}
}

getgenv().CreateFeature = function(Tab: Tab, FeatureName: string)
	if not Features[FeatureName] then
		return warn(`The feature '{FeatureName}' does not exist in the Features.`)
	end
	
	for _, Data in Features[FeatureName] do
		Tab[`Create{Data.Element}`](Tab, Data.Info)
	end
end

getgenv().CreateUniversalTabs = function()
	Rayfield:LoadConfiguration()

	task.wait(1)

	for FlagName: string, CurrentValue: boolean? in OriginalFlags do
		local FlagInfo = Flags[FlagName]

		if not FlagInfo then
			continue
		end

		FlagInfo:Set(CurrentValue)
	end

	Notify("Welcome to FrostByte", `Loaded in {math.floor((tick() - StartLoadTime) * 10) / 10}s`, "loader-circle")
end

local FrostByteStarted = getgenv().FrostByteStarted

if FrostByteStarted then
	FrostByteStarted()
end

--[[function CreateUniversalTabs()
	local VirtualUser = game:GetService("VirtualUser")
	local VirtualInputManager = game:GetService("VirtualInputManager")
	local TeleportService = game:GetService("TeleportService")
	local RunService = game:GetService("RunService")

	local Tab: Tab = Window:CreateTab("Client", "user")

	Tab:CreateSection("Discord")

	Tab:CreateButton({
		Name = "❄ • Join the FrostByte Discord!",
		Callback = function()
			if request then
				request({
					Url = 'http://127.0.0.1:6463/rpc?v=1',
					Method = 'POST',
					Headers = {
						['Content-Type'] = 'application/json',
						Origin = 'https://discord.com'
					},
					Body = HttpService:JSONEncode({
						cmd = 'INVITE_BROWSER',
						nonce = HttpService:GenerateGUID(false),
						args = {code = 'sS3tDP6FSB'}
					})
				})
			elseif setclipboard then
				setclipboard("https://discord.gg/sS3tDP6FSB")
				Notify("Success!", "Copied Discord Link to Clipboard.")
			end

			Notify("Discord", "https://discord.gg/sS3tDP6FSB")
		end,
	})

	Tab:CreateLabel("https://discord.gg/sS3tDP6FSB", "link")

	Tab:CreateSection("Statistics")

	local PingLabel = Tab:CreateLabel("Ping: 0 ms", "wifi")
	local FPSLabel = Tab:CreateLabel("FPS: 0/s", "monitor")

	local Stats = game:GetService("Stats")

	task.spawn(function()
		while getgenv().Flags == Flags and task.wait(0.25) do
			pcall(PingLabel.Set, PingLabel, `Ping: {math.floor(Stats.PerformanceStats.Ping:GetValue() * 100)/ 100} ms`)
			pcall(FPSLabel.Set, FPSLabel, `FPS: {math.floor(1 / Stats.FrameTime * 10) / 10}/s`)
		end
	end)

	Tab:CreateSection("AFK")

	Tab:CreateToggle({
		Name = "🔒 • Anti AFK Disconnection",
		CurrentValue = true,
		Flag = "AntiAFK",
		Callback = function()end,
	})

	getgenv().HandleConnection(Player.Idled:Connect(function()
		if not Flags.AntiAFK.CurrentValue then
			return
		end

		VirtualUser:CaptureController()
		VirtualUser:ClickButton2(Vector2.zero)
		VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.RightMeta, false, game)
		VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.RightMeta, false, game)
	end), "AntiAFK")

	Tab:CreateSection("Performance")

	Tab:CreateSlider({
		Name = ApplyUnsupportedName("🎮 • Max FPS (0 for Unlimited)", setfpscap),
		Range = {0, 240},
		Increment = 1,
		Suffix = "FPS",
		CurrentValue = 0,
		Flag = "MaxFPS",
		Callback = function(Value)
			if not setfpscap then
				return
			end

			setfpscap(Value)
		end,
	})

	local PreviousValue

	Tab:CreateToggle({
		Name = ApplyUnsupportedName("⬜ • Disable 3D Rendering When Tabbed Out", isrbxactive),
		CurrentValue = false,
		Flag = "Rendering",
		Callback = function(Value)
			while Flags.Rendering.CurrentValue and task.wait() do
				local CurrentValue = isrbxactive()

				if PreviousValue == CurrentValue then
					continue
				end

				PreviousValue = CurrentValue

				RunService:Set3dRenderingEnabled(CurrentValue)
			end

			if Value then
				RunService:Set3dRenderingEnabled(true)
			end
		end,
	})

	Tab:CreateSection("Properties")

	local WalkSpeedConnection: RBXScriptConnection
	local ConnectedHumanoid

	local function SetWalkSpeed()
		local Character = Player.Character

		if not Character then
			return
		end

		local Humanoid: Humanoid = Character:FindFirstChild("Humanoid")

		if not Humanoid then
			return
		end

		if Flags.WalkSpeedChanger.CurrentValue then
			Humanoid.WalkSpeed = Flags.WalkSpeed.CurrentValue
		end

		if not WalkSpeedConnection then
			WalkSpeedConnection = Humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(SetWalkSpeed)
			ConnectedHumanoid = Humanoid
			HandleConnection(WalkSpeedConnection, "WalkSpeedConnection")
		end
	end

	HandleConnection(Player.CharacterAdded:Connect(function()
		if WalkSpeedConnection then
			WalkSpeedConnection:Disconnect()
			WalkSpeedConnection = nil
		end

		SetWalkSpeed()
	end), "WalkSpeedCharacterAdded")

	Tab:CreateToggle({
		Name = "⚡ • Enable WalkSpeed Changer",
		CurrentValue = false,
		Flag = "WalkSpeedChanger",
		Callback = function(Value)
			if Player.Character and Value then
				SetWalkSpeed()
			end
		end,
	})

	Tab:CreateSlider({
		Name = "💨 • Set WalkSpeed",
		Range = {0, 300},
		Increment = 1,
		Suffix = "Studs/s",
		CurrentValue = game:GetService("StarterPlayer").CharacterWalkSpeed,
		Flag = "WalkSpeed",
		Callback = function(Value)
			SetWalkSpeed()
		end,
	})

	Tab:CreateSection("Safety")

	local StaffRoleNames = {
		"mod",
		"dev",
		"admin",
		"owner",
		"founder",
		"manag",
	}

	local function IsInGroup(CheckPlayer: Player, GroupId: number)
		local Success, Result = pcall(CheckPlayer.IsInGroup, CheckPlayer, GroupId)

		return Success and Result
	end

	local function GetRoleInGroup(CheckPlayer: Player, GroupId: number)
		local Success, Result = pcall(CheckPlayer.GetRoleInGroup, CheckPlayer, GroupId)

		return if Success then Result else "Guest"
	end

	local function GetRankInGroup(CheckPlayer: Player, GroupId: number)
		local Success, Result = pcall(CheckPlayer.GetRankInGroup, CheckPlayer, GroupId)

		return if Success then Result else 0
	end

	local function GetStaffRole(CheckPlayer: Player)
		local StaffRole

		if IsInGroup(CheckPlayer, 1200769) then
			StaffRole = "Roblox Admin"
		end

		if game.CreatorType ~= Enum.CreatorType.Group then
			return
		end

		local CreatorId = game.CreatorId

		local Role = GetRoleInGroup(CheckPlayer, CreatorId)

		for _, Name in StaffRoleNames do
			if typeof(Role) == "string" and Role:lower():find(Name) then
				StaffRole = Role
			end
		end

		if GetRankInGroup(CheckPlayer, CreatorId) == 255 then
			StaffRole = "Group Owner"
		end

		return StaffRole
	end

	local function CheckIfStaff(CheckPlayer: Player)
		if not Flags.StaffJoin.CurrentValue then
			return
		end

		local StaffRole = GetStaffRole(CheckPlayer)

		if not StaffRole then
			return
		end

		Player:Kick(`The player '{CheckPlayer.Name}' was detected to be a staff member, their role is '{StaffRole}'.\n\nIf you believe this is false, contact the dev of FrostByte.`)
	end

	Tab:CreateToggle({
		Name = "🔔 • Auto Leave When Staff Joins",
		CurrentValue = false,
		Flag = "StaffJoin",
		Callback = function(Value)
			if not Value then
				return
			end

			for _, CheckPlayer in Players:GetPlayers() do
				CheckIfStaff(CheckPlayer)
			end
		end,
	})

	HandleConnection(Players.PlayerAdded:Connect(CheckIfStaff), "StaffJoin")

	getgenv().Role = GetStaffRole(Player)

	Tab:CreateDivider()

	local Connections = {}

	local OriginalText = {}

	local function HandleUsernameChange(Object: Instance)
		if not Flags.HideName.CurrentValue then
			return
		end

		if not Object:IsA("TextLabel") and not Object:IsA("TextBox") and not Object:IsA("TextButton") then
			return
		end

		local NameReplacement = Flags.NameReplacement.CurrentValue

		if not Connections[Object] then
			Connections[Object] = Object:GetPropertyChangedSignal("Text"):Connect(function()
				HandleUsernameChange(Object)
			end)
		end

		if Object.Text:find(Player.Name) then
			OriginalText[Object] = Object.Text
			Object.Text = Object.Text:gsub(Player.Name, NameReplacement)
		elseif Object.Text:find(Player.DisplayName) then
			OriginalText[Object] = Object.Text
			Object.Text = Object.Text:gsub(Player.DisplayName, NameReplacement)
		end
	end

	local DescendantAddedConnection

	Tab:CreateToggle({
		Name = "🛡 • Hide Username and Display Name (Client-Sided)",
		CurrentValue = false,
		Flag = "HideName",
		Callback = function(Value)
			if Value and not DescendantAddedConnection then
				for i,v in game:GetDescendants() do
					HandleUsernameChange(v)
				end

				DescendantAddedConnection = game.DescendantAdded:Connect(HandleUsernameChange)

				HandleConnection(DescendantAddedConnection, "HideName")
			elseif DescendantAddedConnection then
				DescendantAddedConnection:Disconnect()
				DescendantAddedConnection = nil

				for Object: TextLabel?, Text in OriginalText do
					Object.Text = Text
				end

				OriginalText = {}
			end
		end,
	})

	Tab:CreateInput({
		Name = "💬 • Name To Replace With",
		CurrentValue = "FrostByte",
		PlaceholderText = "New Name Here",
		RemoveTextAfterFocusLost = false,
		Flag = "NameReplacement",
		Callback = function()end,
	})

	Tab:CreateDivider()

	Tab:CreateToggle({
		Name = "🌀 • Noclip",
		CurrentValue = false,
		Flag = "Noclip",
		Callback = function(Value)
			local Character = Player.Character

			if not Character then
				return Notify("Error", "You do not have a character.")
			end

			for _, Part: Part in Character:GetChildren() do
				if not Part:IsA("BasePart") then
					continue
				end

				if Value then
					Part:SetAttribute("OriginalCollide", Part.CanCollide)
					Part.CanCollide = false
				else
					Part.CanCollide = Part:GetAttribute("OriginalCollide") or Part.CanCollide
				end
			end
		end,
	})

	Tab:CreateSection("Visualizing")

	local CoreGui: Folder = game:GetService("CoreGui")

	local function ESP(TargetPlayer: Player)
		local TargetCharacter = TargetPlayer.Character or TargetPlayer.CharacterAdded:Wait()

		local LocalCharacter = Player.Character

		local FolderName = `{TargetPlayer.Name}_ESP`

		local Holder = Instance.new("Folder")
		Holder.Name = FolderName
		Holder.Parent = CoreGui

		for _, Object: BasePart | Model in TargetCharacter:GetChildren() do
			if not Object:IsA("PVInstance") then
				continue
			end

			local BoxHandleAdornment = Instance.new("BoxHandleAdornment")
			BoxHandleAdornment.Name = TargetPlayer.Name
			BoxHandleAdornment.Adornee = Object
			BoxHandleAdornment.AlwaysOnTop = true
			BoxHandleAdornment.ZIndex = 10
			BoxHandleAdornment.Size = if Object:IsA("BasePart") then Object.Size else Object:GetExtentsSize()
			BoxHandleAdornment.Transparency = 0.5
			BoxHandleAdornment.Color = BrickColor.White()
			BoxHandleAdornment.Parent = Holder
		end

		local BillboardGui = Instance.new("BillboardGui")
		BillboardGui.Name = TargetPlayer.Name
		BillboardGui.Adornee = TargetCharacter:FindFirstChild("Head") or TargetCharacter:FindFirstChildWhichIsA("PVInstance")
		BillboardGui.Size = UDim2.new(0, 100, 0, 150)
		BillboardGui.StudsOffset = Vector3.new(0, 1, 0)
		BillboardGui.AlwaysOnTop = true
		BillboardGui.Parent = Holder

		local TextLabel = Instance.new("TextLabel")
		TextLabel.BackgroundTransparency = 1
		TextLabel.Position = UDim2.new(0, 0, 0, -50)
		TextLabel.Size = UDim2.new(0, 100, 0, 100)
		TextLabel.Font = Enum.Font.SourceSansSemibold
		TextLabel.TextSize = 20
		TextLabel.TextColor3 = Color3.new(1, 1, 1)
		TextLabel.TextStrokeTransparency = 0
		TextLabel.TextYAlignment = Enum.TextYAlignment.Bottom
		TextLabel.Text = "Unloaded"
		TextLabel.ZIndex = 10
		TextLabel.Parent = BillboardGui

		TargetPlayer.CharacterAdded:Once(function()
			if not Flags.ESP.CurrentValue or not Holder.Parent then
				return
			end

			if Holder.Parent then
				Holder:Destroy()
			end

			ESP(Player)
		end)

		TargetPlayer.CharacterRemoving:Once(function()
			Holder:Destroy()
		end)

		local RenderSteppedConnection: RBXScriptConnection
		RenderSteppedConnection = RunService.RenderStepped:Connect(function()
			if not Flags.ESP.CurrentValue then
				RenderSteppedConnection:Disconnect()
				return
			end

			if not Holder.Parent then
				RenderSteppedConnection:Disconnect()
				return
			end

			if not TargetCharacter or not TargetCharacter:FindFirstChildOfClass("Humanoid") or not LocalCharacter or not LocalCharacter:FindFirstChild("Humanoid") then
				return
			end

			local Distance = math.floor((LocalCharacter:GetPivot().Position - TargetCharacter:GetPivot().Position).Magnitude)
			TextLabel.Text = `Name: {TargetPlayer.Name} | Health: {math.floor(TargetCharacter.Humanoid.Health)} | Studs: {Distance}`
		end)
	end

	Tab:CreateToggle({
		Name = "🔍 • Infinite Yield ESP",
		CurrentValue = false,
		Flag = "ESP",
		Callback = function(Value)
			for _, Object: Folder? in CoreGui:GetChildren() do
				if not Object.Name:find("_ESP") then
					continue
				end

				Object:Destroy()
			end

			if not Value then
				return
			end

			for _, TargetPlayer in Players:GetPlayers() do
				if TargetPlayer == Player then
					continue
				end

				ESP(TargetPlayer)
			end
		end,
	})
	
	HandleConnection(Players.PlayerAdded:Connect(ESP), "ESPPlayerAdded")

	Tab:CreateSection("UI")

	local CustomThemes = {
		BlackHistoryMonth = {
			TextColor = Color3.fromRGB(),

			Background = Color3.fromRGB(),
			Topbar = Color3.fromRGB(),
			Shadow = Color3.fromRGB(),

			NotificationBackground = Color3.fromRGB(),
			NotificationActionsBackground = Color3.fromRGB(),

			TabBackground = Color3.fromRGB(),
			TabStroke = Color3.fromRGB(),
			TabBackgroundSelected = Color3.fromRGB(),
			TabTextColor = Color3.fromRGB(),
			SelectedTabTextColor = Color3.fromRGB(),

			ElementBackground = Color3.fromRGB(),
			ElementBackgroundHover = Color3.fromRGB(),
			SecondaryElementBackground = Color3.fromRGB(),
			ElementStroke = Color3.fromRGB(),
			SecondaryElementStroke = Color3.fromRGB(),

			SliderBackground = Color3.fromRGB(),
			SliderProgress = Color3.fromRGB(),
			SliderStroke = Color3.fromRGB(),

			ToggleBackground = Color3.fromRGB(),
			ToggleEnabled = Color3.fromRGB(),
			ToggleDisabled = Color3.fromRGB(),
			ToggleEnabledStroke = Color3.fromRGB(),
			ToggleDisabledStroke = Color3.fromRGB(),
			ToggleEnabledOuterStroke = Color3.fromRGB(),
			ToggleDisabledOuterStroke = Color3.fromRGB(),

			DropdownSelected = Color3.fromRGB(),
			DropdownUnselected = Color3.fromRGB(),

			InputBackground = Color3.fromRGB(),
			InputStroke = Color3.fromRGB(),
			PlaceholderColor = Color3.fromRGB()
		},
		Default = "DarkBlue",
		Dark = "Default"
	}

	Tab:CreateDropdown({
		Name = "🖼 • Change Theme",
		Options = {"BlackHistoryMonth", "Default", "Dark", "AmberGlow", "Amethyst", "Ocean", "Light", "Bloom", "Green", "Serenity"},
		MultipleOptions = false,
		Flag = "Theme",
		Callback = function(CurrentOption)
			CurrentOption = CurrentOption[1]

			if CurrentOption == "" then
				return
			end

			Window.ModifyTheme(CustomThemes[CurrentOption] or CurrentOption)
		end,
	})

	Tab:CreateSection("Development")

	Tab:CreateButton({
		Name = "⚙️ • Rejoin",
		Callback = function()
			TeleportService:Teleport(game.PlaceId, Player, {FrostByteRejoin = true})
		end,
	})
end]]
