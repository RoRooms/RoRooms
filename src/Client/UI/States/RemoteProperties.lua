local States = require(script.Parent)

local RemoteProperties = {}

function RemoteProperties:Start()
	States.Controllers.ItemsController.EquippedItemsUpdated:Connect(function(EquippedItems)
		States.EquippedItems:set(EquippedItems)
	end)

	States.Services.PlayerDataService.Level:Observe(function(Level)
		local LocalPlayerData = States.LocalPlayerData:get()
		LocalPlayerData.Level = Level
		States.LocalPlayerData:set(LocalPlayerData)
	end)
end

return RemoteProperties
