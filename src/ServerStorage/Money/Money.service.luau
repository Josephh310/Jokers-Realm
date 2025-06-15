local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage._Packages.Knit)

local Config = require(script.Parent["Money.service.config"])

local MoneyService = Knit.CreateService({
	Name = "MoneyService",
	Client = {},
	PlayerMoneyStore = {},
})

function MoneyService:get_money(player: Player): number
	return self.PlayerStore[player] or Config.DefaultMoney
end

function MoneyService:add_money(player: Player, amount: number)
	local new_money = self:GetMoney(player) + amount
	self.PlayerStore[player] = new_money
end

function MoneyService:KnitInit()
	print("MoneyService initialized")
	Players.PlayerRemoving:Connect(function(player)
		self.PlayerStore[player] = nil
	end)
end

function MoneyService:KnitStart()
	print("MoneyService started")
end

return MoneyService
