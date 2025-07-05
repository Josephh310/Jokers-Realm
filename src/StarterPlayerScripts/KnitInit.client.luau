--!strict
--
-- Script Title: 'KnitInit.client'
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
	It works with knit to load everything in the correct order to avoid run-order bugs.
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
	ControllerFolder = script.Parent.Controllers,
	ComponentsFolder = script.Parent.Components,
	StartupTimestamp = os.clock(),
}

-- // Initialisation //

--Require client controllers to kickstart intialization.
--We can do this through Knit's built-in "AddControllers" function. It's basically just a for loop that requires all our controller modules.

Knit.AddControllers(SCRIPT_CONFIG.ControllerFolder)
Knit._ComponentsLoaded = false --this will be used to within controllers to make sure the component is loaded before interacting with it

-- // Custom functions //

--We can make the usage of ComponentsLoaded easier with a custom function...

function Knit.ClientComponentsLoaded()
	if Knit._ComponentsLoaded then
		--Our components loaded super fast! No need to yield.
		return Promise.Resolve()
	end
	--Else, they haven't loaded. So.. we wait for them to load
	return Promise.new(function(Resolve)
		local Heartbeat
		Heartbeat = RunService.Heartbeat:Connect(function()
			if Knit._ComponentsLoaded then
				--Our components have loaded! We can now resolve the promise.
				--By resolving the promise, we're essentially marking the task as complete.
				Heartbeat:Disconnect() --Remember to clean up loops!
				Resolve()
			end
		end)
	end)
end

--Call Knit.Start(). This will loop through all our controllers and call the :KnitInit() function.
--Once all the controllers have been initialised (ready to be required), knit will call the :KnitStart() function in all of them.

local ClientStart = Knit.Start():andThen(function()
	--Load all the client components.
	for _, Component in ipairs(SCRIPT_CONFIG.ComponentsFolder:GetChildren()) do
		if not Component:IsA("ModuleScript") then
			continue
		end
		require(Component)
	end
	Knit._ComponentsLoaded = true
end)

--Catch and log any errors

local Verdict = ClientStart:catch(function(err: string)
	--It's unlikely that a startup error will occur outside of studio testing.
	--But if it does, we should treat it as a dangerous error and kick the player.
	warn(err)
	print("Replace this with a discord webhook log")
	Players.LocalPlayer:Kick(`Client unable to start, please rejoin. {err}`)
	--Client disconnected
end)

--Wait for startup verdict (success/error) then log the startup speed.
--An abnormally long startup will help us know that something is wrong.

do
	Verdict:await()
	local DeltaTime = os.clock() - SCRIPT_CONFIG.StartupTimestamp
	print(`Knit started on the client in {DeltaTime} seconds.`)
end

--End script
