local RoRooms = script.Parent.Parent.Parent.Parent
local CoreThemer = require(RoRooms.SourceCode.Shared.ExtPackages.CoreThemer)
local Footstepper = require(RoRooms.SourceCode.Shared.ExtPackages.Footstepper)
local NeoHotbar = require(RoRooms.Parent.NeoHotbar)

local DefaultsController = {
	Name = script.Name,
}

function DefaultsController:KnitStart()
	CoreThemer:SetDefaults()
	CoreThemer:SetAvatarContextMenuEnabled(true)
	Footstepper:Start()
end

NeoHotbar:Start()

return DefaultsController
