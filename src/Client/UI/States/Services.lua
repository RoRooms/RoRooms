local RoRooms = script.Parent.Parent.Parent.Parent.Parent
local Knit = require(RoRooms.Parent.Knit)
local States = require(script.Parent)

type KnitService = typeof(Knit.GetService)

local Services = {}

function Services:Start()
	Knit.OnStart():andThen(function()
		for ServiceName, _ in pairs(States.Services) do
			States.Services[ServiceName] = Knit.GetService(ServiceName)
		end
	end)
end

return Services
