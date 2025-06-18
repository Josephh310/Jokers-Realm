local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage._Packages.Knit)

for _, v in ipairs(ReplicatedStorage._Source:GetDescendants()) do
	if v:IsA("ModuleScript") and string.lower(v.Name):match(".controller$") then
		print(`Loading {string.split(v.Name, ".")[1]} Controller..`)
		require(v)
	end
end

Knit.Start()
	:andThen(function()
		print("Knit started on client!")
	end)
	:catch(warn)
