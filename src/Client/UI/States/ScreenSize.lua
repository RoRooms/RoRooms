local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent.Parent.Parent)
local Workspace = game:GetService("Workspace")

local OnyxUI = require(RoRooms.Packages.OnyxUI)
local Fusion = require(RoRooms.Packages.Fusion)
local States = require(script.Parent)

local Out = Fusion.Out

local ScreenSize = {}

function ScreenSize:Start()
	Scope:Hydrate(Workspace.CurrentCamera) {
		[Out "ViewportSize"] = States.ScreenSize,
	}
end

return ScreenSize
