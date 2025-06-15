--Load dependancies
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage._Packages.Knit)

--Read config
local Config = require(script.Parent["Money.service.config"])

--Create a new money service using knit
--This allows us to manage the service securely on the server while exposing limited functions to the player
local MoneyService = Knit.CreateService({
	Name = "MoneyService",
	Client = {},
	PlayerMoneyStore = {},
})

--Server functions

function MoneyService:AddMoney(player: Player, amount: number)
	self.PlayerMoneyStore[player] = self.Client:GetMoney(player) + amount
end

--Client functions

function MoneyService.Client:GetMoney(player: Player): number
	return self.Server.PlayerMoneyStore[player] or Config.DefaultMoney
end

--Knit functions
--KnitInit: called as soon as the game starts, and allows the service to load in parallel to the player loading
function MoneyService:KnitInit()
	print("MoneyService initialized")
	Players.PlayerRemoving:Connect(function(player)
		self.PlayerMoneyStore[player] = nil
	end)
end

--KnitStart: called as soon as all other knit services are loaded. Ensures safe cross-service references
function MoneyService:KnitStart()
	print("MoneyService started")
end

return MoneyService
