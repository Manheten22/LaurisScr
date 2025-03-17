--!strict
local getgenv: () -> ({[string]: any}) = getfenv().getgenv

getgenv().ScriptVersion = "v0.0.1"

getgenv().Changelog = [[
lol1
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


getgenv().CreateUniversalTabs()
