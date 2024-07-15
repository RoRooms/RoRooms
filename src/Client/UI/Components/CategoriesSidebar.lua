local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent)

local OnyxUI = require(RoRooms.Packages.OnyxUI)
local Fusion = require(OnyxUI.Parent.Fusion)
local Modifier = require(OnyxUI.Utils.Modifier)
local Themer = require(OnyxUI.Utils.Themer)
local EnsureValue = require(OnyxUI.Utils.EnsureValue)

local Children = Fusion.Children
local Computed = Fusion.Computed

local ScrollingFrame = require(OnyxUI.Components.ScrollingFrame)

return function(Props)
	Props.Name = EnsureValue(Props.Name, "string", "CategoriesSidebar")

	return ScrollingFrame {
		Name = Props.Name,
		Size = Props.Size,
		AutomaticSize = Enum.AutomaticSize.X,
		ScrollBarThickness = 0,
		ScrollBarImageTransparency = 1,

		[Children] = {
			Modifier.ListLayout {
				Padding = Computed(function()
					return UDim.new(0, Themer.Theme.Spacing["0.5"]:get())
				end),
			},
			Modifier.Padding {
				Padding = Computed(function()
					return UDim.new(0, Themer.Theme.StrokeThickness["1"]:get())
				end),
			},

			Props[Children],
		},
	}
end
