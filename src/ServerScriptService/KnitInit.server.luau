--!strict
--
-- Script Title: 'KnitInit.server'
--
-- Created: Sun Jun 15 2025
-- Author: Joseph Hill (@BreakLoop)
--
-- Last Modified: Wed Jul 02 2025
-- Modified By: Joseph Hill (@BreakLoop)
--
-- Copyright (c) 2025 BrainySpinach Maths
--
--[[
	This script manages the game's framework on the client.
	It works with Knit to load everything in the correct order to avoid run-order bugs.
]]

-- // Services //

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

-- // Packages //

local Knit = require(ReplicatedStorage.Packages.Knit)
local Promise = require(ReplicatedStorage.Packages.Promise)

-- // Constants //

local SCRIPT_CONFIG = {
	ServiceFolder = script.Parent.Services,
	ComponentsFolder = script.Parent.Components,
	StartupTimestamp = os.clock(),
}

-- // Initialisation //

--Require server services to kickstart intialization.
--We can do this through Knit's built-in "AddServices" function. It's basically just a for loop that requires all our controller modules.

Knit.AddServices(SCRIPT_CONFIG.ServiceFolder)
Knit._ComponentsLoaded = false

-- // Custom functions //

--We can make the usage of ComponentsLoaded easier with a custom function...

function Knit.ServerComponentsLoaded()
	if Knit._ComponentsLoaded then
		return Promise.Resolve()
	end
	return Promise.new(function(Resolve)
		local Heartbeat
		Heartbeat = RunService.Heartbeat:Connect(function()
			if Knit._ComponentsLoaded then
				Heartbeat:Disconnect()
				Resolve()
			end
		end)
	end)
end

--Call Knit.Start. This will loop through all our loaded services and call the :KnitInit() function.
--Once all the services have been initialised (ready to be required), knit will call the :KnitStart() function.

local ServerStart = Knit.Start():andThen(function()
	for _, Component in ipairs(SCRIPT_CONFIG.ComponentsFolder:GetChildren()) do
		if not Component:IsA("ModuleScript") then
			continue
		end
		require(Component)
	end
	Knit._ComponentsLoaded = true
end)

--Catch and log any errors

local Verdict = ServerStart:catch(function(err: string)
	warn(err)
	print("When you can, replace this with a discord webhook")
	local KickMessage = `The server was unable to startl, please rejoin. {err}`
	for _, Player in ipairs(Players:GetPlayers()) do
		Player:Kick(KickMessage)
	end
	--Server has been shut down
end)

--Wait for startup verdict (success/error) then log the startup speed.
--An abnormally long startup will help us know that something is wrong.

do
	Verdict:await()
	local DeltaTime = os.clock() - SCRIPT_CONFIG.StartupTimestamp
	print(`Knit started on the server in {DeltaTime} seconds`)
end

--Script end
