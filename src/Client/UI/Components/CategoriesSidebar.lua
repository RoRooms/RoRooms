local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent)
local OnyxUI = require(RoRooms.Packages.OnyxUI)
local Fusion = require(RoRooms.Packages.Fusion)

local Children = Fusion.Children

local ScrollingFrame = require(OnyxUI.Components.ScrollingFrame)

return function(Scope: Fusion.Scope<any>, Props)
	Props.Name = Scope:EnsureValue(Props.Name, "CategoriesSidebar")

	return ScrollingFrame {
		Name = Props.Name,
		Size = Props.Size,
		AutomaticSize = Enum.AutomaticSize.X,
		ScrollBarThickness = 0,
		ScrollBarImageTransparency = 1,
		ListEnabled = true,
		ListPadding = Scope:Computed(function(Use)
			return UDim.new(0, Theme.Spacing["0.5"]:get())
		end),
		Padding = Scope:Computed(function(Use)
			return UDim.new(0, Theme.StrokeThickness["1"]:get())
		end),

		[Children] = {
			Props[Children],
		},
	}
end
