local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent.Parent)

local Packages = RoRooms.Packages
local Shared = RoRooms.Shared

local CoreThemer = require(Shared.ExtPackages.CoreThemer)
local Footstepper = require(Shared.ExtPackages.Footstepper)
local NeoHotbar = require(Packages.NeoHotbar)

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
