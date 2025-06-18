local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Knit = require(ReplicatedStorage._Packages.Knit)

for _, v in ipairs(ServerStorage._Source:GetDescendants()) do
	if v:IsA("ModuleScript") and string.lower(v.Name):match(".service$") then
		print(`Loading {string.split(v.Name, ".")[1]} Service..`)
		require(v)
	end
end

Knit.Start()
	:andThen(function()
		print("Knit started on server!")
	end)
	:catch(warn)
