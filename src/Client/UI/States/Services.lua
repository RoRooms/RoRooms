local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent.Parent.Parent)

local Packages = RoRooms.Packages

local Knit = require(Packages.Knit)
local States = require(script.Parent)

local SERVICES = { "UserProfileService", "WorldsService", "ItemsService", "PlayerDataService", "EmotesService" }

local Services = {}

for _, ServiceName in ipairs(SERVICES) do
	States.Services[ServiceName] = Knit.GetService(ServiceName)
end

return Services
