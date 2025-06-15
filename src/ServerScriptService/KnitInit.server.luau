local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Knit = require(ReplicatedStorage._Packages.Knit)

for i, v in ipairs(ServerStorage._Source.Services:GetDescendants()) do
	if v:IsA("ModuleScript") and v.Name:match(".service$") then
		print(`Loading {string.split(v.Name, ".")} Service..`)
		require(v)
	end
end

Knit.Start()
	:andThen(function()
		print("Knit started on server!")
	end)
	:catch(warn)
