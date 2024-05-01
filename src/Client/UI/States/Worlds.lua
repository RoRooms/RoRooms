local States = require(script.Parent)

type World = {
	PlaceId: number,
}
type WorldPage = {
	[number]: World,
}
type WorldPages = {
	[number]: WorldPage,
}

local PAGE_SIZE = 3

local Worlds = {}

function Worlds:FetchTopWorlds(PageCount: number?, OnlyIfEmpty: boolean?)
	if PageCount == nil then
		PageCount = 10
	end

	if States.Services.TopWorldsService then
		return States.Services.TopWorldsService
			:GetTopWorlds(math.floor(#States.Worlds.TopWorlds:get() / PAGE_SIZE), PageCount, PAGE_SIZE)
			:andThen(function(TopWorlds: WorldPages?)
				if OnlyIfEmpty and #States.Worlds.TopWorlds:get() > 0 then
					return
				else
					self:_AddTopWorlds(TopWorlds)
				end

				return TopWorlds
			end)
	end
end

function Worlds:_AddTopWorlds(TopWorlds: WorldPages)
	local NewTopWorlds = States.Worlds.TopWorlds:get()

	for _, Page in ipairs(TopWorlds) do
		for _, World in ipairs(Page) do
			if self:_FindPlaceIdInWorldsArray(NewTopWorlds, World.PlaceId) == nil then
				table.insert(NewTopWorlds, World)
			end
		end
	end

	States.Worlds.TopWorlds:set(NewTopWorlds)
end

function Worlds:FetchRandomWorlds(PageCount: number?, OnlyIfEmpty: boolean?)
	if PageCount == nil then
		PageCount = 1
	end

	if States.Services.RandomWorldsService then
		return States.Services.RandomWorldsService
			:GetRandomWorlds(math.floor(#States.Worlds.RandomWorlds:get() / PAGE_SIZE), PageCount, PAGE_SIZE)
			:andThen(function(RandomWorlds: WorldPages)
				if OnlyIfEmpty and #States.Worlds.RandomWorlds:get() > 0 then
					return
				else
					self:_AddRandomWorlds(RandomWorlds)
				end

				return RandomWorlds
			end)
	end
end

function Worlds:_AddRandomWorlds(RandomWorlds: WorldPages)
	local NewRandomWorlds = States.Worlds.RandomWorlds:get()

	for _, Page in ipairs(RandomWorlds) do
		for _, World in ipairs(Page) do
			if self:_FindPlaceIdInWorldsArray(NewRandomWorlds, World.PlaceId) == nil then
				table.insert(NewRandomWorlds, World)
			end
		end
	end

	States.Worlds.RandomWorlds:set(NewRandomWorlds)
end

function Worlds:_FindPlaceIdInWorldsArray(WorldsArray: { [number]: World }, PlaceId: number)
	for _, World in ipairs(WorldsArray) do
		if World.PlaceId == PlaceId then
			return World
		end
	end

	return nil
end

function Worlds:ClearTopWorlds()
	States.Worlds.TopWorlds:set({})
end

function Worlds:ClearRandomWorlds()
	States.Worlds.RandomWorlds:set({})
end

function Worlds:Start()
	States.Services.TopWorldsService.TopWorldsInitialized:Connect(function(TopWorlds: WorldPages)
		self:ClearTopWorlds()
		self:_AddTopWorlds(TopWorlds)
	end)
	States.Services.RandomWorldsService.RandomWorldsInitialized:Connect(function(RandomWorlds: WorldPages)
		self:ClearRandomWorlds()
		self:_AddRandomWorlds(RandomWorlds)
	end)

	if #States.Worlds.TopWorlds:get() == 0 then
		self:FetchTopWorlds(nil, true)
	end
	if #States.Worlds.RandomWorlds:get() == 0 then
		self:FetchRandomWorlds(nil, true)
	end
end

return Worlds
