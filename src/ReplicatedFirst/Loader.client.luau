-- !strict
--
-- Script Title: 'Loader.client'
--
-- Created: Fri Jul 04 2025
-- Author: Joseph Hill (@BreakLoop)
--
-- Last Modified:
-- Modified By:
--
-- Copyright (c) 2025 BrainySpinach Maths
--
--[[
  This loader is designed to ensure all assets are loaded before
  the player is loaded into the game. This ensures a consistent experience
  for the player and the loading bar provides them with a benchmark
  of how long the loading will approximately take.
]]

-- // Services //

local ContentProvider = game:GetService("ContentProvider")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

-- // Packages //

local Trove = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Trove"))

-- // Constants //

local Player = Players.LocalPlayer
local StartupTimestamp = os.clock()
local LoadingScreen = script.LoadingScreen:Clone()
local NewTrove = Trove.new()

-- // Initialisation //

--Render the loading screen by parenting to playergui - @BreakLoop
LoadingScreen.Parent = Player.PlayerGui
--Max blur to obscure player view: don't want them seeing unloaded models - @BreakLoop
Lighting:WaitForChild("Blur").Size = 56
--When the player loads in, anchor their HRP to prevent moving during the loading screen - @BreakLoop
NewTrove:Connect(Player.CharacterAdded, function(char: Model)
	char:WaitForChild("HumanoidRootPart").Anchored = true
end)

-- // Custom functions //

--CustomQueueTime() provides a 5 second default loading time, so even people who load extremely quickly..
--...aren't immediately dropped into the game. - @BreakLoop

local function CustomQueueTime()
	local TimeSinceJoining = os.clock() - StartupTimestamp
	local QueueSize = ContentProvider.RequestQueueSize
	if TimeSinceJoining <= 5 then
		QueueSize += math.round((5 - TimeSinceJoining) * 100)
	end
	return QueueSize
end

--Loaded() provides a method to unload the UI via an effect. - @BreakLoop

local function Loaded()
	-- Nicely tween the UI size and the blur to ease the player into the game.
	--.. may need some more fine-tuning. - @BreakLoop

	local TweenUIOut = TweenService:Create(LoadingScreen.Frame, TweenInfo.new(0.5), {
		GroupTransparency = 1,
		Size = UDim2.new(0.1, 0, 0.1, 0),
	})
	local TweenBlurOut = TweenService:Create(Lighting.Blur, TweenInfo.new(0.5), {
		Size = 0,
	})

	TweenUIOut:Play()
	TweenBlurOut:Play()

	--Add the final connection to the trove then clean up when it's fired. - @BreakLoop

	NewTrove:Connect(TweenUIOut.Completed, function()
		NewTrove:Clean() --Disconnect all connections
		LoadingScreen:Destroy()
		Player.Character.HumanoidRootPart.Anchored = false
		script:Destroy()
	end)
end

-- // Loading screen renderer //

local Text = LoadingScreen.Frame.Container["Loading Text"]
local Gradient = Text.UIGradient

local MaxQueueSize: number = 0 -- automatically adjusted to always be the largest value, as sometimes RequestQueueSize can fluxuate.
local CurrentQueueSize: number = 0

NewTrove:Connect(RunService.Heartbeat, function()
	CurrentQueueSize = CustomQueueTime() --modified ContentProvider.RequestQueueSize - @BreakLoop

	if CurrentQueueSize > MaxQueueSize then
		MaxQueueSize = CurrentQueueSize
	end

	--Progress calculator

	local AssetsLoaded: number = (MaxQueueSize - CurrentQueueSize)
	local ProgressValue: number = (AssetsLoaded / MaxQueueSize)

	--Update loading gradient
	Gradient.Offset = Vector2.new(ProgressValue - 0.5, 0) --Loading % display with gradient

	if CurrentQueueSize <= 0 then
		Loaded() --yippee :3 (now we self destruct)
	end
end)

--End script
