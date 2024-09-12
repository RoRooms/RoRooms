local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent)
local OnyxUI = require(RoRooms.Packages.OnyxUI)
local Fusion = require(RoRooms.Packages.Fusion)

local Children = Fusion.Children

return function(Scope: Fusion.Scope<any>, Props)
	local Name = Scope:EnsureValue(Props.Name, "CategoriesSidebar")

	return Scope:Scroller {
		Name = Props.Name,
		Size = Props.Size,
		AutomaticSize = Enum.AutomaticSize.X,
		ScrollBarThickness = 0,
		ScrollBarImageTransparency = 1,
		ListEnabled = true,
		ListPadding = Scope:Computed(function(Use)
			return UDim.new(0, Use(Theme.Spacing["0.5"]))
		end),
		Padding = Scope:Computed(function(Use)
			return UDim.new(0, Use(Theme.StrokeThickness["1"]))
		end),

		[Children] = {
			Props[Children],
		},
	}
end
