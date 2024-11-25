local HttpService = game:GetService("HttpService")

local Rorooms = script.Parent.Parent.Parent.Parent
local Future = require(Rorooms.Parent.Future)
local Signal = require(Rorooms.Parent.Signal)
local t = require(Rorooms.Parent.t)
local Fetch = require(Rorooms.Parent.Fetch)
local Config = require(Rorooms.Config).Config
local DeepCopy = require(Rorooms.SourceCode.Shared.ExtPackages.DeepCopy)
local Knit = require(Rorooms.Parent.Knit)

local UPDATE_DELAY = 10 * 60
local FAILED_UPDATE_DELAY = 1 * 60

local WorldRegistryService = {
	Name = "WorldRegistryService",
	Client = {
		Registered = Knit.CreateProperty(false),
	},

	WorldRegistry = {},
	WorldRegistryLastUpdated = 0,

	RegistryUpdated = Signal.new(),
}

function WorldRegistryService.Client:IsWorldRegistered(Player: Player, PlaceId: number)
	assert(t.tuple(t.instanceOf("Player")(Player), t.number(PlaceId)))

	return WorldRegistryService:IsWorldRegistered(PlaceId)
end

function WorldRegistryService.Client:GetWorldDetails(Player: Player, PlaceId: number)
	assert(t.tuple(t.instanceOf("Player")(Player), t.number(PlaceId)))

	return WorldRegistryService:GetWorldDetails(PlaceId)
end

function WorldRegistryService:IsWorldRegistered(PlaceId: number)
	return self:GetWorldDetails(PlaceId) ~= nil
end

function WorldRegistryService:GetWorldDetails(PlaceId: number)
	local WorldEntry = self.WorldRegistry[tostring(PlaceId)]

	if WorldEntry ~= nil then
		return DeepCopy(WorldEntry)
	else
		return nil
	end
end

function WorldRegistryService:UpdateRegistry()
	local Success, Result = self:_FetchRegistryVersion():Await()

	if Success and (Result ~= nil) and (Result ~= self.WorldRegistryLastUpdated) then
		local Success2, Result2 = self:_FetchLatestRegistry():Await()

		if Success2 then
			self.WorldRegistry = Result2
			self.WorldRegistryLastUpdated = Result

			self:_RemoveDelistedWorlds()

			self.RegistryUpdated:Fire(Result2)

			return true, Result2
		else
			warn(Result2)
		end
	end

	return false
end

function WorldRegistryService:_FetchRegistryVersion()
	return Future.Try(function()
		local Success, Result =
			Fetch(`https://api.github.com/repos/{Config.Systems.Worlds.RegistryRepository}/releases/latest`):Await()

		if Success then
			local Body = HttpService:JSONDecode(Result.Body)
			if Body then
				return Body["published_at"]
			end
		end
	end)
end

function WorldRegistryService:_FetchLatestRegistry()
	return Future.Try(function()
		local Success, Response = Fetch(
			`https://github.com/{Config.Systems.Worlds.RegistryRepository}/releases/latest/download/worlds.json`
		):Await()

		if Success then
			local Worlds = HttpService:JSONDecode(Response.Body)

			if typeof(Worlds) == "table" then
				return Worlds
			else
				warn("Latest world registry version does not decode to JSON. Report this ASAP.")
			end
		else
			warn("Latest world registry version is not a string. Report this ASAP.")

			return {}
		end
	end)
end

function WorldRegistryService:_RemoveDelistedWorlds()
	for PlaceId, World in pairs(self.WorldRegistry) do
		if World.delisted or World.forceDelisted then
			self.WorldRegistry[PlaceId] = nil
		end
	end
end

function WorldRegistryService:_SpawnRegistryUpdateLoop()
	return task.spawn(function()
		while true do
			local Success = self:UpdateRegistry()

			if Success then
				task.wait(UPDATE_DELAY)
			else
				task.wait(FAILED_UPDATE_DELAY)
			end
		end
	end)
end

function WorldRegistryService:KnitStart()
	self.RegistryUpdated:Connect(function(Worlds)
		local World = Worlds[tostring(game.PlaceId)]

		self.Client.Registered:Set(World ~= nil)
	end)

	self:_SpawnRegistryUpdateLoop()
end

return WorldRegistryService
