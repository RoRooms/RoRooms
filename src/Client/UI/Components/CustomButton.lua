local RoRooms = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(RoRooms.Parent.OnyxUI)
local Fusion = require(RoRooms.Packages.Fusion)

local Button = require(script.Parent.Button)

export type Props = Button.Props & {}

return function(Props: Props)
	local Color = Scope:EnsureValue(Props.Color, "Color3", Theme.Colors.Neutral.Main)
	local IsHovering = Scope:EnsureValue(Props.IsHovering, "boolean", false)

	return Button(CombineProps(Props, {
		Color = Color,
		CornerRadius = Scope:Computed(function(Use)
			return UDim.new(0, Theme.CornerRadius["2"]:get())
		end),
		PaddingTop = Scope:Computed(function(Use)
			return UDim.new(0, Theme.Spacing["0.5"]:get())
		end),
		PaddingBottom = Scope:Computed(function(Use)
			return UDim.new(0, Theme.Spacing["0.5"]:get())
		end),
		PaddingLeft = Scope:Computed(function(Use)
			return UDim.new(0, Theme.Spacing["0.5"]:get())
		end),
		PaddingRight = Scope:Computed(function(Use)
			return UDim.new(0, Theme.Spacing["0.5"]:get())
		end),

		IsHovering = IsHovering,
	}))
end
