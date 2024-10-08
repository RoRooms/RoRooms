local RoRooms = script.Parent.Parent.Parent.Parent.Parent
local States = require(script.Parent)
local Knit = require(RoRooms.Parent.Knit)

local RemoteProperties = {}

function RemoteProperties:Start()
	local ItemsController = require(RoRooms.SourceCode.Client.Items.ItemsController)

	ItemsController.EquippedItemsUpdated:Connect(function(EquippedItems)
		States.Items.Equipped:set(EquippedItems)
	end)

	local LevelingService = Knit.GetService("LevelingService")
	local UpdatesService = Knit.GetService("UpdatesService")

	LevelingService.Level:Observe(function(Level)
		States.Leveling.Level:set(Level)
	end)

	UpdatesService.UpToDate:Observe(function(UpToDate)
		States.RoRooms.UpToDate:set(UpToDate)
	end)
end

return RemoteProperties
