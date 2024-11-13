local Workspace = game:GetService("Workspace")

local Rorooms = script.Parent.Parent.Parent.Parent.Parent
local Fusion = require(Rorooms.Parent.Fusion)
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
