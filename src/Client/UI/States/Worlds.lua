local States = require(script.Parent)

local PAGE_SIZE = 3

local Worlds = {}

function Worlds:AddTopWorlds(PageCount: number | nil)
	if PageCount == nil then
		PageCount = 10
	end

	if States.Services.WorldsService then
		States.Services.WorldsService
			:GetTopWorlds(math.floor(#States.Worlds.TopWorlds / PAGE_SIZE), PageCount, PAGE_SIZE)
			:andThen(function(WorldPages: { [number]: { [number]: number } })
				local NewTopWorlds = States.Worlds.TopWorlds:get()

				for _, Page in ipairs(WorldPages) do
					for _, PlaceId in ipairs(Page) do
						table.insert(NewTopWorlds, PlaceId)
					end
				end

				States.Worlds.TopWorlds:set(NewTopWorlds)
			end)
	end
end

function Worlds:AddRandomWorlds(PageCount: number | nil)
	if PageCount == nil then
		PageCount = 10
	end

	if States.Services.WorldsService then
		States.Services.WorldsService
			:GetRandomWorlds(math.floor(#States.Worlds.RandomWorlds / PAGE_SIZE), PageCount, PAGE_SIZE)
			:andThen(function(WorldPages: { [number]: { [number]: number } })
				local NewRandomWorlds = States.Worlds.RandomWorlds:get()

				for _, Page in ipairs(WorldPages) do
					for _, PlaceId in ipairs(Page) do
						table.insert(NewRandomWorlds, PlaceId)
					end
				end

				States.Worlds.RandomWorlds:set(NewRandomWorlds)
			end)
	end
end

function Worlds:ClearRandomWorlds()
	States.Worlds.RandomWorlds:set({})
end

function Worlds:Start() end

return Worlds