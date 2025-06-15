local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage._Packages.Knit)

Knit.Start()
	:andThen(function()
		print("Knit started on client!")
	end)
	:catch(warn)
