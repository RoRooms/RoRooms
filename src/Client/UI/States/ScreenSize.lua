local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent.Parent.Parent)
local Workspace = game:GetService("Workspace")

local Shared = RoRooms.Shared

local OnyxUI = require(Shared.ExtPackages.OnyxUI)
local Fusion = require(OnyxUI._Packages.Fusion)
local States = require(script.Parent)

local Hydrate = Fusion.Hydrate
local Out = Fusion.Out

local ScreenSize = {}

function ScreenSize:Start()
	Hydrate(Workspace.CurrentCamera) {
		[Out "ViewportSize"] = States.ScreenSize,
	}
end

return ScreenSize
