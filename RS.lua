--!strict
local getgenv: () -> ({[string]: any}) = getfenv().getgenv

getgenv().ScriptVersion = "v0.0.1"

getgenv().Changelog = [[

]]

do
	local Core = loadstring(game:HttpGet("https://raw.githubusercontent.com/Manheten22/LaurisScr/refs/heads/main/Core.lua"))
	
	if not Core then
		return warn("Failed to load the FrostByte Core")
	end
	
	Core()
end


getgenv().CreateUniversalTabs()
