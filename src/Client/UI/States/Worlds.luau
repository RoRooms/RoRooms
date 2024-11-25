local Rorooms = script.Parent.Parent.Parent.Parent.Parent
local Fusion = require(Rorooms.Parent.Fusion)
local States = require(script.Parent)
local Knit = require(Rorooms.Parent.Knit)

local Peek = Fusion.peek

local ROW_SIZE = 3
local RANDOM_WORLD_BASIS = ROW_SIZE * 3
local DEFAULT_WORLD_COUNT = 10 * ROW_SIZE

local TopWorldsService
local RandomWorldsService

type World = {
	PlaceId: number,
}
type Worlds = {
	[number]: World,
}

local Worlds = {}

function Worlds:FetchAssortedWorlds(Count: number?)
	if Count == nil then
		Count = DEFAULT_WORLD_COUNT
	end

	self:FetchRandomWorlds(Count, true):await()
	self:FetchTopWorlds(Count, true):await()

	self:LoadAssortedWorlds(Count)
end

function Worlds:LoadAssortedWorlds(Count: number?)
	if Count == nil then
		Count = DEFAULT_WORLD_COUNT
	end

	local AssortedWorldsValue = Peek(States.Worlds.AssortedWorlds)
	local TopWorldsValue = Peek(States.Worlds.TopWorlds)
	local StartIndex = #AssortedWorldsValue
	local EndIndex = StartIndex + Count

	self:_RemovePlaceIdFromArray(TopWorldsValue, game.PlaceId)

	for Index = StartIndex, EndIndex do
		local World = TopWorldsValue[Index]
		if World then
			if math.random(1, RANDOM_WORLD_BASIS) == RANDOM_WORLD_BASIS then
				local RandomWorld = self:GetUnusedRandomWorld(AssortedWorldsValue)
				if RandomWorld ~= nil then
					RandomWorld.Random = true
					table.insert(AssortedWorldsValue, RandomWorld)
				end
			else
				if self:_FindPlaceIdInWorldsArray(AssortedWorldsValue, World.PlaceId) == nil then
					table.insert(AssortedWorldsValue, World)
				end
			end
		end
	end

	local FillerStartIndex = #AssortedWorldsValue
	local FillerEndIndex = FillerStartIndex + (EndIndex - FillerStartIndex)

	if FillerEndIndex > FillerStartIndex then
		for _ = FillerStartIndex, FillerEndIndex do
			local RandomWorld = self:GetUnusedRandomWorld(AssortedWorldsValue)
			if RandomWorld ~= nil then
				RandomWorld.Random = true
				table.insert(AssortedWorldsValue, RandomWorld)
			else
				break
			end
		end
	end

	States.Worlds.AssortedWorlds:set(AssortedWorldsValue)

	return AssortedWorldsValue
end

function Worlds:GetUnusedRandomWorld(UsedWorlds: Worlds)
	local RandomWorldsValue = Peek(States.Worlds.RandomWorlds)

	self:_RemovePlaceIdFromArray(RandomWorldsValue, game.PlaceId)

	if #RandomWorldsValue == 0 then
		return nil
	end

	local ChosenWorld = RandomWorldsValue[math.random(1, #RandomWorldsValue)]
	local ExistingIndex = self:_FindPlaceIdInWorldsArray(UsedWorlds, ChosenWorld.PlaceId)

	if #UsedWorlds >= #RandomWorldsValue then
		return nil
	elseif ExistingIndex == nil then
		return ChosenWorld
	else
		return self:GetUnusedRandomWorld(UsedWorlds)
	end
end

function Worlds:FetchTopWorlds(Count: number?, OnlyIfEmpty: boolean?)
	if Count == nil then
		Count = DEFAULT_WORLD_COUNT
	end

	if TopWorldsService then
		return TopWorldsService:GetTopWorlds(#Peek(States.Worlds.TopWorlds), Count):andThen(function(TopWorlds: Worlds?)
			if OnlyIfEmpty and #Peek(States.Worlds.TopWorlds) > 0 then
				return
			else
				self:_AddTopWorlds(TopWorlds)
			end

			return TopWorlds
		end)
	end

	return nil
end

function Worlds:_AddTopWorlds(TopWorlds: Worlds)
	local NewTopWorlds = Peek(States.Worlds.TopWorlds)

	for _, World in ipairs(TopWorlds) do
		if self:_FindPlaceIdInWorldsArray(NewTopWorlds, World.PlaceId) == nil then
			table.insert(NewTopWorlds, World)
		end
	end

	States.Worlds.TopWorlds:set(NewTopWorlds)
end

function Worlds:FetchRandomWorlds(Count: number?, OnlyIfEmpty: boolean?)
	if Count == nil then
		Count = DEFAULT_WORLD_COUNT
	end

	local StartIndex = #Peek(States.Worlds.RandomWorlds)

	if RandomWorldsService then
		return RandomWorldsService:GetRandomWorlds(StartIndex, Count):andThen(function(RandomWorlds: Worlds)
			if OnlyIfEmpty and #Peek(States.Worlds.RandomWorlds) > 0 then
				return
			else
				self:_AddRandomWorlds(RandomWorlds)
			end

			return RandomWorlds
		end)
	end

	return nil
end

function Worlds:_AddRandomWorlds(RandomWorlds: Worlds)
	local NewRandomWorlds = Peek(States.Worlds.RandomWorlds)

	for _, World in ipairs(RandomWorlds) do
		if self:_FindPlaceIdInWorldsArray(NewRandomWorlds, World.PlaceId) == nil then
			table.insert(NewRandomWorlds, World)
		end
	end

	States.Worlds.RandomWorlds:set(NewRandomWorlds)
end

function Worlds:_RemovePlaceIdFromArray(WorldsArray: { [number]: World }, PlaceId: number)
	local EntryIndex = self:_FindPlaceIdInWorldsArray(WorldsArray, PlaceId)
	if EntryIndex ~= nil then
		table.remove(WorldsArray, EntryIndex)
	end
end

function Worlds:_FindPlaceIdInWorldsArray(WorldsArray: { [number]: World }, PlaceId: number)
	for Index, World in ipairs(WorldsArray) do
		if World.PlaceId == PlaceId then
			return Index, World
		end
	end

	return nil
end

function Worlds:ClearWorlds(WorldsObject: Fusion.Value<Fusion.Scope<any>, Worlds>)
	WorldsObject:set({})
end

function Worlds:ClearRandomWorlds()
	States.Worlds.RandomWorlds:set({})
end

function Worlds:_InitializeAssortedWorlds()
	if #Peek(States.Worlds.RandomWorlds) == 0 then
		self:FetchRandomWorlds(nil, true):await()
	end

	if #Peek(States.Worlds.TopWorlds) == 0 then
		self:FetchTopWorlds(nil, true):await()
	end

	self:ClearWorlds(States.Worlds.AssortedWorlds)
	self:LoadAssortedWorlds()
end

function Worlds:Start()
	TopWorldsService = Knit.GetService("TopWorldsService")
	RandomWorldsService = Knit.GetService("RandomWorldsService")

	if TopWorldsService then
		TopWorldsService.TopWorldsInitialized:Connect(function(TopWorlds: Worlds)
			self:ClearWorlds(States.Worlds.TopWorlds)
			self:_AddTopWorlds(TopWorlds)

			self:ClearWorlds(States.Worlds.AssortedWorlds)
			self:LoadAssortedWorlds()
		end)
	end
	if RandomWorldsService then
		RandomWorldsService.RandomWorldsInitialized:Connect(function(RandomWorlds: Worlds)
			self:ClearWorlds(States.Worlds.RandomWorlds)
			self:_AddRandomWorlds(RandomWorlds)

			self:ClearWorlds(States.Worlds.AssortedWorlds)
			self:LoadAssortedWorlds()
		end)
	end

	self:_InitializeAssortedWorlds()
end

return Worlds
