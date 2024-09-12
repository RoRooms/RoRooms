local RoRooms = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(RoRooms.Parent.OnyxUI)
local Fusion = require(RoRooms.Packages.Fusion)

local Computed = Fusion.Computed

local Button = require(script.Parent.Button)

export type Props = Button.Props & {}

return function(Props: Props)
	local Color = EnsureValue(Props.Color, "Color3", Theme.Colors.Neutral.Main)
	local IsHovering = EnsureValue(Props.IsHovering, "boolean", false)

	return Button(CombineProps(Props, {
		Color = Color,
		CornerRadius = Computed(function()
			return UDim.new(0, Theme.CornerRadius["2"]:get())
		end),
		PaddingTop = Computed(function()
			return UDim.new(0, Theme.Spacing["0.5"]:get())
		end),
		PaddingBottom = Computed(function()
			return UDim.new(0, Theme.Spacing["0.5"]:get())
		end),
		PaddingLeft = Computed(function()
			return UDim.new(0, Theme.Spacing["0.5"]:get())
		end),
		PaddingRight = Computed(function()
			return UDim.new(0, Theme.Spacing["0.5"]:get())
		end),

		IsHovering = IsHovering,
	}))
end
