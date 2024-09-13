local RoRooms = script.Parent.Parent.Parent.Parent.Parent.Parent.Parent
local Workspace = game:GetService("Workspace")

local Fusion = require(RoRooms.Parent.Fusion)
local States = require(script.Parent)

local Out = Fusion.Out

local ScreenSize = {}

function ScreenSize:Start()
	Scope:Hydrate(Workspace.CurrentCamera) {
		[Out "ViewportSize"] = States.ScreenSize,
	}
end

return ScreenSize
