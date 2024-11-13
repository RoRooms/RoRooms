local Rorooms = script.Parent.Parent.Parent.Parent
local CoreThemer = require(Rorooms.SourceCode.Shared.ExtPackages.CoreThemer)
local NeoHotbar = require(Rorooms.Parent.NeoHotbar)

local DefaultsController = {
	Name = script.Name,
}

function DefaultsController:KnitStart()
	CoreThemer:SetDefaults()
end

NeoHotbar:Start()

return DefaultsController
