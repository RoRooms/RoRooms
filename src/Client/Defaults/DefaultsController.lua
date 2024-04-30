local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent.Parent)
local CoreThemer = require(RoRooms.Shared.ExtPackages.CoreThemer)
local Footstepper = require(RoRooms.Shared.ExtPackages.Footstepper)
local NeoHotbar = require(RoRooms.Packages.NeoHotbar)

local DefaultsController = {
	Name = script.Name,
}

function DefaultsController:KnitStart()
	CoreThemer:SetDefaults()
	CoreThemer:SetAvatarContextMenuEnabled(true)
	Footstepper:Start()
end

function DefaultsController:KnitInit()
	NeoHotbar:Start()
end

return DefaultsController
