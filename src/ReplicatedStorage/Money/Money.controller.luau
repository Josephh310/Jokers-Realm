--Load dependancies
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage._Packages.Knit)

--Create a new money controller using knit
--A controller allows us to "control" aspects of the client, such as how it will communicate with the server in certain situations
local MoneyController = Knit.CreateController({
	Name = "MoneyController",
})

--Knit functions
function MoneyController:KnitInit()
	print("MoneyController initialized")
end

function MoneyController:KnitStart()
	print("MoneyController started")
	--Load the exposed functions from the money service on the server
	local MoneyService = Knit.GetService("MoneyService")
	MoneyService:GetMoney()
		:andThen(function(money)
			print("My money:", money)
		end)
		:catch(warn)
end

return MoneyController
