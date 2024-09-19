local SOURCE = script.Parent.SourceCode
local PACKAGES = script.Parent.Parent
local SERVER = SOURCE.Server
local DEFAULT_SERVICES = { "PlayerDataStoreService", "CharacterDefaultsService", "ComponentsService", "UpdatesService" }

local Config = require(script.Parent.Config)
local Knit = require(PACKAGES.Knit)
local Loader = require(PACKAGES.Loader)
local FindFeatureFromModule = require(SOURCE.Shared.FindFeatureFromModule)

local RoRoomsServer = {
	Started = false,
	Config = Config,
}

function RoRoomsServer:Start()
	assert(not self.Started, "RoRooms already started.")
	self.Started = true

	Loader.LoadDescendants(SERVER, function(Descendant)
		if Descendant:IsA("ModuleScript") and Descendant.Name:match("Service$") ~= nil then
			local Feature = FindFeatureFromModule(Descendant)
			if
				table.find(DEFAULT_SERVICES, Descendant.Name)
				or (Feature and Config.Config.Systems[Feature].Enabled == true)
			then
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

function RoRoomsServer:Configure(Configuration: Config.Config)
	assert(not self.Started, "You cannot configure RoRooms after starting it.")

	Config:Update(Configuration)
end

return RoRoomsServer
