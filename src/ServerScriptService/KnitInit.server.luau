--[[
--Filename: /Users/joseph/Documents/Roblox Projects/Joker's Realm/src/ServerScriptService/KnitInit.server.luau
--Path: /Users/joseph/Documents/Roblox Projects/Joker's Realm/src/ServerScriptService
--Created Date: Sunday, June 15th 2025, 3:36:45 pm
--Author: Joseph Hill
--
--Copyright (c) 2025 BrainySpinach Maths
--]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

for _, v in ipairs(ServerStorage._Source:GetDescendants()) do
	if v:IsA("ModuleScript") and string.lower(v.Name):match(".service$") then
		print(`Loading {string.split(v.Name, ".")[1]} Service..`)
		require(v)
	end
end

Knit.Start()
	:andThen(function()
		print("Knit started on server!")
	end)
	:catch(warn)
