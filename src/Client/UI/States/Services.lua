local RoRooms = script.Parent.Parent.Parent.Parent.Parent
local Knit = require(RoRooms.Parent.Knit)
local States = require(script.Parent)

local SERVICES = {
	"UserProfileService",
	"WorldsService",
	"ItemsService",
	"PlayerDataService",
	"EmotesService",
	"WorldRegistryService",
	"TopWorldsService",
	"RandomWorldsService",
	"UpdatesService",
}

local Services = {}

for _, ServiceName in ipairs(SERVICES) do
	States.Services[ServiceName] = Knit.GetService(ServiceName)
end

return Services
