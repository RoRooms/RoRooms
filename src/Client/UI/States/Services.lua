local RoRooms = script.Parent.Parent.Parent.Parent.Parent
local Knit = require(RoRooms.Parent.Knit)
local States = require(script.Parent)

local Services = {}

for ServiceName, _ in pairs(States.Services) do
	States.Services[ServiceName] = Knit.GetService(ServiceName)
end

return Services
