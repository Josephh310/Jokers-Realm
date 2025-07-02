--File: /Users/joseph/Documents/Roblox Projects/Joker's Realm/src/StarterPlayerScripts/KnitInit.client.luau
--Project: /Users/joseph/Documents/Roblox Projects/Joker's Realm/src/StarterPlayerScripts
--Created Date: Sunday, June 15th 2025, 3:48:46 pm
--Author: Joseph Hill
-------
--Last Modified: Wed Jul 02 2025
--Modified By: Joseph Hill
-------
--Copyright (c) 2025 BrainySpinach Maths
--
--All shall be well and all shall be well and all manner of things shall be well.
--Nope...we're doomed!
-------
--HISTORY:
--Date      	By	Comments
------------	---	----------------------------------------------------------

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

for _, v in ipairs(ReplicatedStorage._Source:GetDescendants()) do
	if v:IsA("ModuleScript") and string.lower(v.Name):match(".controller$") then
		print(`Loading {string.split(v.Name, ".")[1]} Controller..`)
		require(v)
	end
end

Knit.Start()
	:andThen(function()
		print("Knit started on client!!")
	end)
	:catch(warn)
