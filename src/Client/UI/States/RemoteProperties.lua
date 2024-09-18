local RoRooms = script.Parent.Parent.Parent.Parent.Parent
local Fusion = require(RoRooms.Parent.Fusion)
local States = require(script.Parent)
local ItemsController = require(RoRooms.SourceCode.Client.Items.ItemsController)

local Peek = Fusion.peek

local RemoteProperties = {}

function RemoteProperties:Start()
	ItemsController.EquippedItemsUpdated:Connect(function(EquippedItems)
		States.Items.Equipped:set(EquippedItems)
	end)

	if States.Services.LevelingService then
		States.Services.LevelingService.Level:Observe(function(Level)
			local LocalPlayerData = Peek(States.LocalPlayerData)
			LocalPlayerData.Level = Level
			States.LocalPlayerData:set(LocalPlayerData)
		end)
	end

	if States.Services.UpdatesService then
		States.Services.UpdatesService.UpToDate:Observe(function(UpToDate)
			States.RoRooms.UpToDate:set(UpToDate)
		end)
	end
end

return RemoteProperties
