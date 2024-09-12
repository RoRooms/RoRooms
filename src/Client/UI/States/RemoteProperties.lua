local LonekaUniversal = require(script.Parent.Parent.Parent.Parent.Parent)
local Fusion = require(LonekaUniversal.Packages.Fusion)
local States = require(script.Parent)

local Peek = Fusion.peek

local RemoteProperties = {}

function RemoteProperties:Start()
	States.Controllers.ItemsController.EquippedItemsUpdated:Connect(function(EquippedItems)
		States.EquippedItems:set(EquippedItems)
	end)

	States.Services.PlayerDataService.Level:Observe(function(Level)
		local LocalPlayerData = Peek(States.LocalPlayerData)
		LocalPlayerData.Level = Level
		States.LocalPlayerData:set(LocalPlayerData)
	end)

	States.Services.UpdatesService.UpToDate:Observe(function(UpToDate)
		States.RoRooms.UpToDate:set(UpToDate)
	end)
end

return RemoteProperties
