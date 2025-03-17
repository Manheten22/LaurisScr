--!strict
local getgenv: () -> ({[string]: any}) = getfenv().getgenv

getgenv().ScriptVersion = "v0.0.1"

getgenv().Changelog = [[
lol
]]

do
	local Core = loadstring(game:HttpGet("https://raw.githubusercontent.com/Manheten22/LaurisScr/refs/heads/main/Core.lua"))
	
	if not Core then
		return warn("Failed to load the FrostByte Core")
	end
	
	Core()
end

-- Types

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

-- Variables

local ApplyUnsupportedName: (Name: string, Condition: boolean) -> (string) = getgenv().ApplyUnsupportedName
local HandleConnection: (Connection: RBXScriptConnection, Name: string) -> () = getgenv().HandleConnection
local Notify: (Title: string, Content: string, Image: string?) -> () = getgenv().Notify
local GetClosestChild: (Children: {PVInstance}, Callback: ((Child: PVInstance) -> () | boolean)?, MaxDistance: number?) -> PVInstance? = getgenv().GetClosestChild
local CreateFeature: (Tab: Tab, FeatureName: string) -> () = getgenv().CreateFeature

local Success, Network = pcall(require, game:GetService("ReplicatedStorage").Modules.Network)

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Flags: Flags = getgenv().Flags

local Player = game:GetService("Players").LocalPlayer

local function GetChildInCharacter(ChildName: string): (RemoteEvent & BasePart & Humanoid)?
	local Character = Player.Character

	if not Character then
		return
	end

	local Child = Character:FindFirstChild(ChildName, true)

	return Child
end

local LastFired = 0

local function TeleportLocalCharacter(NewLocation: CFrame)
	local Character = Player.Character

	if not Character then
		return
	end
	
	local InvisibleParts: Folder = workspace:FindFirstChild("InvisibleParts")
	
	if not InvisibleParts then
		return
	end
	
	local MandrakeRope = InvisibleParts:FindFirstChild("MandrakeRope")
	
	if not MandrakeRope then
		return
	end
	
	local MandrakePit = InvisibleParts:FindFirstChild("MandrakePit") :: Part

	if not MandrakePit then
		return
	end
	
	if (Character:GetPivot().Position - NewLocation.Position).Magnitude > 50 then
		if tick() - LastFired >= 2 then
			local Interact = GetChildInCharacter("Interact")

			if not Interact then
				return
			end

			Interact:FireServer({
				player = Player,
				Object = MandrakeRope,
				Action = "Enter"
			})
			LastFired = tick()
		end

		local Start = tick()

		repeat
			task.wait()
		until (Character:GetPivot().Position - MandrakePit.Position).Magnitude <= 10 or tick() - Start >= 1

		task.wait(0.1)
	end
	
	Character:PivotTo(NewLocation)
end

local function EmulateClick()
	if not Success then
		return
	end
	
	Network.connect("MouseInput", "Fire", Player.Character, {
		Config = "Button1Down"
	})
	
	Network.connect("MouseInput", "Fire", Player.Character, {
		Config = "Button1Up"
	})
end

local function IsInvalidMob(Child: PVInstance): ()
	if Child == Player.Character then
		return true
	end

	local Master = Child:FindFirstChild("Master") :: ObjectValue

	if Master and Master.Value == Player.Character then
		return true
	end
end

-- Features

local Window = getgenv().Window

local Tab: Tab = Window:CreateTab("Combat", "swords")

Tab:CreateSection("Attacking")

Tab:CreateToggle({
	Name = ApplyUnsupportedName("⚔ • Auto Attack", Success),
	CurrentValue = false,
	Flag = "Attack",
	Looped = true,
	Callback = function()
		local ClosestMob = GetClosestChild(workspace.Alive:GetChildren(), IsInvalidMob, Flags.Distance.CurrentValue)

		if not ClosestMob then
			return
		end

		EmulateClick()
	end,
})

Tab:CreateSection("Aiming")

Tab:CreateToggle({
	Name = "🎯 • Look At Closest Enemy",
	CurrentValue = false,
	Flag = "LookAt",
	Looped = true,
	Callback = function(Value)
		local ClosestMob = GetClosestChild(workspace.Alive:GetChildren(), IsInvalidMob, Flags.Distance.CurrentValue)

		local Character = Player.Character

		if not Character then
			return
		end

		local Humanoid = GetChildInCharacter("Humanoid")

		if not Humanoid then
			return
		end

		if not ClosestMob then
			Humanoid.AutoRotate = true
			return
		end

		local HumanoidRootPart = GetChildInCharacter("HumanoidRootPart")

		if not HumanoidRootPart then
			return
		end

		Humanoid.AutoRotate = false

		local Position = HumanoidRootPart.Position
		local ClosestPosition = ClosestMob:GetPivot().Position

		HumanoidRootPart.CFrame = CFrame.lookAt(Position, Vector3.new(ClosestPosition.X, Position.Y, ClosestPosition.Z))
	end,
	AfterLoop = function()
		local Humanoid = GetChildInCharacter("Humanoid")

		if not Humanoid then
			return
		end

		Humanoid.AutoRotate = true
	end,
})

Tab:CreateSection("Configuration")

Tab:CreateSlider({
	Name = "📏 • Max Distance",
	Range = {1, 100},
	Increment = 1,
	Suffix = "Studs",
	CurrentValue = 20,
	Flag = "Distance",
})

Tab:CreateSection("Moving")

local MobTween: any
local ActiveNotification = false

Tab:CreateToggle({
	Name = "🦌 • Move to Mobs",
	CurrentValue = false,
	Flag = "MoveMobs",
	Looped = true,
	BeforeLoop = function(Value)
		if not Value and MobTween then
			MobTween:Cancel()
			MobTween = nil
		end
	end,
	Callback = function()
		local Closest = GetClosestChild(workspace.Alive:GetChildren(), function(Child)
			if not table.find(Flags.Mobs.CurrentOption, Child.Name:split(".")[1]) then
				return true
			end
			
			if Child:FindFirstChild("Master") then
				return true
			end
		end)

		if not Closest then
			if not ActiveNotification then
				Notify("Failed", "Couldn't find anything, try getting closer to it so it can load.")
				ActiveNotification = true
				task.delay(5, function()
					ActiveNotification = false
				end)
			end
			return
		end

		local HumanoidRootPart: Part = Player.Character.HumanoidRootPart

		local GoTo = CFrame.new(
			Closest:GetPivot().Position
				+ Closest:GetPivot().LookVector * Flags.Offset.CurrentValue
				+ Vector3.yAxis * Flags.HeightOffset.CurrentValue
			, Closest:GetPivot().Position
		)

		local Distance = (HumanoidRootPart.Position - GoTo.Position).Magnitude
		
		if Flags.MobsMethod.CurrentOption[1] == "Teleport" then
			TeleportLocalCharacter(GoTo)
		else
			MobTween = TweenService:Create(HumanoidRootPart, TweenInfo.new(Distance / 250, Enum.EasingStyle.Linear), {CFrame = GoTo})
			MobTween:Play()
			MobTween.Completed:Wait()
			MobTween = nil
		end
	end,
})

local Mobs = {}

for _, Object: Model in game:GetService("ReplicatedStorage").Storage.Mobs:GetChildren() do
	table.insert(Mobs, Object.Name)
end

table.sort(Mobs)

Tab:CreateDropdown({
	Name = "🐔 • Mobs",
	Options = Mobs,
	MultipleOptions = true,
	Flag = "Mobs",
})

Tab:CreateDivider()

local Dropdown
Dropdown = Tab:CreateDropdown({
	Name = "🐻 • Movement Method",
	Options = {"Teleport", "Tween"},
	CurrentOption = "Teleport",
	MultipleOptions = false,
	Flag = "MobsMethod",
})

Tab:CreateSlider({
	Name = "📐 • X Offset",
	Range = {-20, 20},
	Increment = 1,
	Suffix = "Studs",
	CurrentValue = -5,
	Flag = "Offset",
})

Tab:CreateSlider({
	Name = "🔼 • Y Offset",
	Range = {-20, 20},
	Increment = 1,
	Suffix = "Studs",
	CurrentValue = 0,
	Flag = "HeightOffset",
})


getgenv().CreateUniversalTabs()
