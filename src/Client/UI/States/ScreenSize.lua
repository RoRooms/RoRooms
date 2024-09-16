local Workspace = game:GetService("Workspace")

local RoRooms = script.Parent.Parent.Parent.Parent.Parent
local Fusion = require(RoRooms.Parent.Fusion)
local States = require(script.Parent)

local Out = Fusion.Out

local ScreenSize = {
	Scope = Fusion.scoped(Fusion),
}

function ScreenSize:Start()
	self.Scope:Hydrate(Workspace.CurrentCamera) {
		[Out "ViewportSize"] = States.CoreGui.ScreenSize,
	}
end

return ScreenSize
