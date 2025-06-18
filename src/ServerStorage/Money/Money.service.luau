--Load dependancies
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage._Packages.Knit)

--Read config
local Config = require(ReplicatedStorage._Source.Modules["Money.service.config"])

--Create a new money service using knit
--This allows us to manage the service securely on the server while exposing limited functions to the player
local MoneyService = Knit.CreateService({
	Name = "MoneyService",
	Client = {
		MoneyChanged = Knit.CreateSignal(),
	},
	PlayerMoneyStore = {},
})

--Server functions

function MoneyService:AddMoney(player: Player, amount: number)
	local CurrentMoney = self.Client:GetMoney(player)
	--Sanity check to prevent negative values, as (num) + (-num ) adds to num (could be abused)
	if amount > 0 then
		local NewMoney = CurrentMoney + amount
		--Add money on the server and fire the money changed signal to the client
		--This will allow the client to update the player's visual money counter
		self.PlayerMoneyStore[player] = NewMoney
		self.Client.MoneyChanged:Fire(player, NewMoney)
	end
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
	while true do
		task.wait(1)
		for _, v in pairs(Players:GetPlayers()) do
			MoneyService:AddMoney(v, 10)
		end
	end
end

return MoneyService
