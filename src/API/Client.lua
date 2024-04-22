local ROROOMS_SOURCE = script.Parent.SourceCode
local DEFAULT_CONTROLLERS = { "UIController", "BloxstrapController" }

local RoRoomsClient = {}

function RoRoomsClient:Start()
	assert(not self.Started, "RoRooms already started.")
	self.Started = true

	local Config = require(script.Parent.Config)
	local Packages = script.Parent.Parent

	local Shared = ROROOMS_SOURCE.Shared
	local Client = ROROOMS_SOURCE.Client

	local Knit = require(Packages.Knit)
	local Loader = require(Packages.Loader)
	local FindFeatureFromModule = require(Shared.SharedData.FindFeatureFromModule)

	self.Knit = Knit

	Loader.LoadDescendants(Client, function(Descendant)
		if Descendant:IsA("ModuleScript") and Descendant.Name:match("Controller$") ~= nil then
			local Feature = FindFeatureFromModule(Descendant)
			if table.find(DEFAULT_CONTROLLERS, Descendant.Name) or (Feature and Config[Feature].Enabled == true) then
				return Knit.CreateController(require(Descendant))
			else
				return false
			end
		else
			return false
		end
	end)

	Knit.Start()
end

return RoRoomsClient
