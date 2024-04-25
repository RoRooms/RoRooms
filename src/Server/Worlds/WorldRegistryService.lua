local InsertService = game:GetService("InsertService")
local MarketplaceService = game:GetService("MarketplaceService")

local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent.Parent)
local Signal = require(RoRooms.Packages.Signal)

local REGISTRY_UPDATE_DELAY = 10 * 60
local REGISTRY_ASSET_ID = 16007140043

local WorldRegistryService = {
	Name = "WorldRegistryService",
	Client = {},

	WorldRegistry = {},
	WorldRegistryLastUpdated = 0,

	RegistryUpdated = Signal.new(),
}

function WorldRegistryService.Client:IsWorldRegistered(_Player: Player, PlaceId: number)
	if typeof(PlaceId) ~= "number" then
		return
	end

	return self.Server:IsWorldRegistered(PlaceId)
end

function WorldRegistryService:IsWorldRegistered(PlaceId: number)
	return self.WorldRegistry[PlaceId] ~= nil
end

function WorldRegistryService:UpdateRegistry()
	local UpdateStamp = self:_FetchRegistryLastUpdated()

	if UpdateStamp ~= self.WorldRegistryLastUpdated then
		self.WorldRegistry = self:_FetchLatestRegistry()
		self.WorldRegistryLastUpdated = UpdateStamp

		self.RegistryUpdated:Fire(self.WorldRegistry)
	end
end

function WorldRegistryService:_FetchRegistryLastUpdated()
	local Success, Result = pcall(function()
		return MarketplaceService:GetProductInfo(REGISTRY_ASSET_ID).Updated
	end)
	if Success then
		return Result
	else
		warn(Result)

		return nil
	end
end

function WorldRegistryService:_FetchLatestRegistry()
	local Success, Result = pcall(function()
		local ModuleScript = InsertService:LoadAsset(REGISTRY_ASSET_ID):GetChildren()[1]

		if ModuleScript:IsA("ModuleScript") then
			local Data = require(ModuleScript)

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

	if Success then
		return Result
	else
		warn(Result)

		return nil
	end
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

function WorldRegistryService:KnitInit() end

return WorldRegistryService
