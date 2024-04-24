local ROROOMS_SOURCE = script.Parent.SourceCode
local DEFAULT_SERVICES = { "PlayerDataService", "CharacterDefaultsService", "ComponentsService" }

local RoRoomsServer = {}

function RoRoomsServer:Start()
	assert(not self.Started, "RoRooms already started.")
	self.Started = true

	local Packages = script.Parent.Parent
	local Config = require(script.Parent.Config)

	local Shared = ROROOMS_SOURCE.Shared
	local Server = ROROOMS_SOURCE.Server

	local Knit = require(Packages.Knit)
	local Loader = require(Packages.Loader)
	local FindFeatureFromModule = require(Shared.SharedData.FindFeatureFromModule)

	self.Knit = Knit

	Loader.LoadDescendants(Server, function(Descendant)
		if Descendant:IsA("ModuleScript") and Descendant.Name:match("Service$") ~= nil then
			local Feature = FindFeatureFromModule(Descendant)
			if table.find(DEFAULT_SERVICES, Descendant.Name) or (Feature and Config[Feature].Enabled == true) then
				return Knit.CreateService(require(Descendant))
			else
				return false
			end
		else
			return false
		end
	end)

	Knit.Start()
end

return RoRoomsServer
