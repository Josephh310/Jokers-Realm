-- Script Title: 'KnitInit.client'
-- Created: Sun Jun 15 2025
-- Author: Joseph Hill (@BreakLoop)
--
-- Last Modified: Wed Jul 02 2025
-- Modified By: Joseph Hill (@BreakLoop)
--
-- Copyright (c) 2025 BrainySpinach Maths

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
