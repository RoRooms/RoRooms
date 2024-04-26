local States = require(script.Parent)

local PAGE_SIZE = 3

local Worlds = {}

function Worlds:AddTopWorlds(PageCount: number | nil)
	if PageCount == nil then
		PageCount = 10
	end

	if States.Services.WorldsService then
		States.Services.WorldsService
			:GetTopWorlds(math.ceil(#States.Worlds.TopWorlds:get() / PAGE_SIZE), PageCount, PAGE_SIZE)
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
			:GetRandomWorlds(math.ceil(#States.Worlds.RandomWorlds:get() / PAGE_SIZE), PageCount, PAGE_SIZE)
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

function Worlds:ClearTopWorlds()
	States.Worlds.TopWorlds:set({})
end

function Worlds:ClearRandomWorlds()
	States.Worlds.RandomWorlds:set({})
end

function Worlds:Start()
	States.Services.WorldsService.TopWorldsInitialized:Connect(function()
		self:ClearRandomWorlds()
		self:AddRandomWorlds()
	end)
	States.Services.WorldsService.RandomWorldsInitialized:Connect(function()
		self:ClearTopWorlds()
		self:AddTopWorlds()
	end)

	if #States.Worlds.TopWorlds:get() == 0 then
		self:AddTopWorlds()
	end
	if #States.Worlds.RandomWorlds:get() == 0 then
		self:AddRandomWorlds()
	end
end

return Worlds
