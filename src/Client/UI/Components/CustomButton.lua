local RoRooms = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(RoRooms.Parent.OnyxUI)
local CombineProps = require(OnyxUI.Utils.CombineProps)
local Fusion = require(OnyxUI.Parent.Fusion)
local EnsureValue = require(OnyxUI.Utils.EnsureValue)
local Themer = require(OnyxUI.Utils.Themer)

local Computed = Fusion.Computed
local Spring = Fusion.Spring

local Button = require(script.Parent.Button)

export type Props = Button.Props & {}

return function(Props: Props)
	local Color = EnsureValue(Props.Color, "Color3", Themer.Theme.Colors.Neutral.Dark)
	local IsHovering = EnsureValue(Props.IsHovering, "boolean", false)

	return Button(CombineProps(Props, {
		Color = Color,
		BackgroundTransparency = Spring(
			Computed(function()
				if IsHovering:get() then
					return 0
				else
					return 1
				end
			end),
			Themer.Theme.SpringSpeed["1"],
			Themer.Theme.SpringDampening
		),
		CornerRadius = Computed(function()
			return UDim.new(0, Themer.Theme.CornerRadius["2"]:get())
		end),
		PaddingTop = Computed(function()
			return UDim.new(0, Themer.Theme.Spacing["0.5"]:get())
		end),
		PaddingBottom = Computed(function()
			return UDim.new(0, Themer.Theme.Spacing["0.5"]:get())
		end),
		PaddingLeft = Computed(function()
			return UDim.new(0, Themer.Theme.Spacing["0.5"]:get())
		end),
		PaddingRight = Computed(function()
			return UDim.new(0, Themer.Theme.Spacing["0.5"]:get())
		end),
		StrokeEnabled = true,
		StrokeTransparency = Spring(
			Computed(function()
				if IsHovering:get() then
					return 0
				else
					return 1
				end
			end),
			Themer.Theme.SpringSpeed["1"],
			Themer.Theme.SpringDampening
		),
		-- StrokeColor = Computed(function()
		-- 	return ColorUtils.Emphasize(Color:get(), Themer.Theme.Emphasis.Light:get())
		-- end),

		IsHovering = IsHovering,
	}))
end
