local RoRooms = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(RoRooms.Packages.OnyxUI)
local Fusion = require(RoRooms.Packages.Fusion)

local Children = Fusion.Children
local Util = OnyxUI.Util
local Themer = OnyxUI.Themer

return function(Scope: Fusion.Scope<any>, Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components)
	local Theme = Themer.Theme:now()

	local Name = Util.Fallback(Props.Name, "CategoriesSidebar")

	return Scope:Scroller {
		Name = Name,
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
