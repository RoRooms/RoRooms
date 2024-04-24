local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent.Parent)

local Packages = RoRooms.Packages
local Shared = RoRooms.Shared

local CoreThemer = require(Shared.ExtPackages.CoreThemer)
local Footstepper = require(Shared.ExtPackages.Footstepper)
local NeoHotbar = require(Packages.NeoHotbar)
local Signal = require(Packages.Signal)

local DefaultsController = {
	Name = script.Name,

	NeoHotbarStarted = Signal.new(),
}

function DefaultsController:KnitStart()
	CoreThemer:SetDefaults()
	Footstepper:Start()
	NeoHotbar:Start()
	self.NeoHotbarStarted:Fire()
end

function DefaultsController:KnitInit() end

return DefaultsController
