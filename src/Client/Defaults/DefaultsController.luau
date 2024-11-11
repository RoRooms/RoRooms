local RoRooms = script.Parent.Parent.Parent.Parent
local CoreThemer = require(RoRooms.SourceCode.Shared.ExtPackages.CoreThemer)
local NeoHotbar = require(RoRooms.Parent.NeoHotbar)

local DefaultsController = {
	Name = script.Name,
}

function DefaultsController:KnitStart()
	CoreThemer:SetDefaults()
end

NeoHotbar:Start()

return DefaultsController
