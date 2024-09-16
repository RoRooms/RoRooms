local InsertService = game:GetService("InsertService")
local MarketplaceService = game:GetService("MarketplaceService")

local RoRooms = script.Parent.Parent.Parent.Parent
local Future = require(RoRooms.Parent.Future)
local Signal = require(RoRooms.Parent.Signal)
local t = require(RoRooms.Parent.t)

local REGISTRY_UPDATE_DELAY = 10 * 60
local REGISTRY_ASSET_ID = 16007140043

local WorldRegistryService = {
	Name = "WorldRegistryService",
	Client = {},

	WorldRegistry = {},
	WorldRegistryLastUpdated = 0,

	RegistryUpdated = Signal.new(),
}

function WorldRegistryService.Client:IsWorldRegistered(Player: Player, PlaceId: number)
	assert(t.tuple(t.instanceOf("Player")(Player), t.number(PlaceId)))

	return self.Server:IsWorldRegistered(PlaceId)
end

function WorldRegistryService:IsWorldRegistered(PlaceId: number)
	return self.WorldRegistry[PlaceId] ~= nil
end

function WorldRegistryService:UpdateRegistry()
	Future.Try(function()
		return MarketplaceService:GetProductInfo(REGISTRY_ASSET_ID).Updated
	end):After(function(Success, UpdateStamp)
		if Success then
			if UpdateStamp ~= self.WorldRegistryLastUpdated then
				self:_FetchLatestRegistry():After(function(Success, Result)
					if Success then
						self.WorldRegistry = Result
						self.WorldRegistryLastUpdated = UpdateStamp

						self.RegistryUpdated:Fire(Result)
					else
						warn(Result)
					end
				end)
			end
		end
	end)
end

function WorldRegistryService:_FetchLatestRegistry()
	return Future.Try(function()
		local ModuleScript = InsertService:LoadAsset(REGISTRY_ASSET_ID):GetChildren()[1]

		if ModuleScript:IsA("ModuleScript") then
			local Data = require(ModuleScript)

			assert(t.tuple())
			if typeof(Data) == "table" then
				return Data
			else
				warn("Latest world registry returns a non-table value. Report this ASAP.")

				return {}
			end
		else
			warn("Latest world registry version is not a ModuleScript. Report this ASAP.")

			return {}
		end
	end)
end

function WorldRegistryService:_SpawnRegistryUpdateLoop()
	return task.spawn(function()
		while true do
			self:UpdateRegistry()

			task.wait(REGISTRY_UPDATE_DELAY)
		end
	end)
end

function WorldRegistryService:KnitStart()
	self:_SpawnRegistryUpdateLoop()
end

return WorldRegistryService
