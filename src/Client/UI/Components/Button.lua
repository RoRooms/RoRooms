local RoRooms = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(RoRooms.Parent.OnyxUI)
local Fusion = require(RoRooms.Packages.Fusion)
local ColorUtils = require(RoRooms.Packages.ColorUtils)

local Children = Fusion.Children
local ForValues = Fusion.ForValues
local Computed = Fusion.Computed
local Spring = Fusion.Spring

local BaseButton = require(OnyxUI.Components.BaseButton)
local Text = require(OnyxUI.Components.Text)
local Icon = require(OnyxUI.Components.Icon)

local DISABLED_BACKGROUND_TRANSPARENCY = 0.925
local DISABLED_CONTENT_TRANSPARENCY = 0.75

export type Props = BaseButton.Props & {
	Disabled: PubTypes.CanBeState<boolean>?,
	Content: PubTypes.CanBeState<{ string }>?,
	Style: PubTypes.CanBeState<string>?,
	Color: PubTypes.CanBeState<Color3>?,
	ContentColor: PubTypes.CanBeState<Color3>?,
	ContentSize: PubTypes.CanBeState<number>?,
	IsHolding: PubTypes.CanBeState<boolean>?,
}

return function(Props: Props)
	local Disabled = EnsureValue(Props.Disabled, "boolean", false)
	local Content = EnsureValue(Props.Content, "table", {})
	local Style = EnsureValue(Props.Style, "string", "Filled")
	local Color = EnsureValue(Props.Color, "Color3", Theme.Colors.Primary.Main)
	local ContentColor = EnsureValue(
		Props.ContentColor,
		"Color3",
		Computed(function()
			return ColorUtils.Emphasize(Use(Color), Use(Theme.Emphasis.Contrast))
		end)
	)
	local ContentSize = EnsureValue(Props.ContentSize, "number", Theme.TextSize["1"])

	local IsHolding = EnsureValue(Props.IsHolding, "boolean", false)
	local IsHovering = EnsureValue(Props.IsHovering, "boolean", false)
	local EffectiveColor = Computed(function()
		if Use(Disabled) then
			return Use(Theme.Colors.BaseContent.Main)
		else
			if Use(IsHolding) then
				return ColorUtils.Emphasize(Use(Color), Use(Theme.Emphasis.Regular))
			elseif Use(IsHovering) then
				return ColorUtils.Emphasize(Use(Color), Use(Theme.Emphasis.Light))
			else
				return Use(Color)
			end
		end
	end)
	local EffectiveContentColor = Computed(function()
		if Use(Disabled) then
			return Use(Theme.Colors.BaseContent.Main)
		else
			if Use(Style) == "Filled" then
				return Use(ContentColor)
			elseif Use(Style) == "Outlined" then
				return Use(EffectiveColor)
			elseif Use(Style) == "Ghost" then
				return Use(EffectiveColor)
			else
				return Use(ContentColor)
			end
		end
	end)
	local EffectiveContentTransparency = Computed(function()
		if Use(Disabled) then
			return DISABLED_CONTENT_TRANSPARENCY
		else
			return 0
		end
	end)

	return BaseButton(CombineProps(Props, {
		Name = "Button",
		BackgroundTransparency = Computed(function()
			if Use(Style) == "Filled" then
				if Use(Disabled) then
					return DISABLED_BACKGROUND_TRANSPARENCY
				else
					return 0
				end
			else
				return 1
			end
		end),
		BackgroundColor3 = Spring(EffectiveColor, Theme.SpringSpeed["1"], Theme.SpringDampening),
		PaddingLeft = Computed(function()
			return UDim.new(0, Theme.Spacing["0.75"]:get())
		end),
		PaddingRight = Computed(function()
			return UDim.new(0, Theme.Spacing["0.75"]:get())
		end),
		PaddingTop = Computed(function()
			return UDim.new(0, Theme.Spacing["0.25"]:get())
		end),
		PaddingBottom = Computed(function()
			return UDim.new(0, Theme.Spacing["0.25"]:get())
		end),
		CornerRadius = Computed(function()
			return UDim.new(0, Theme.CornerRadius["1"]:get())
		end),
		ListEnabled = true,
		ListPadding = Computed(function()
			return UDim.new(0, Theme.Spacing["0.25"]:get())
		end),
		ListFillDirection = Enum.FillDirection.Horizontal,
		ListHorizontalAlignment = Enum.HorizontalAlignment.Center,
		ListVerticalAlignment = Enum.VerticalAlignment.Center,
		StrokeEnabled = true,
		StrokeColor = Spring(EffectiveColor, Theme.SpringSpeed["1"], Theme.SpringDampening),
		StrokeTransparency = Computed(function()
			if Use(Style) == "Ghost" then
				return 1
			elseif Use(Disabled) then
				return DISABLED_BACKGROUND_TRANSPARENCY
			else
				return 0
			end
		end),
		IsHolding = IsHolding,
		IsHovering = IsHovering,

		[Children] = {
			ForValues(Content, function(ContentString: string)
				if string.find(ContentString, "rbxassetid://", 1, true) then
					return Icon {
						Image = ContentString,
						ImageColor3 = EffectiveContentColor,
						Size = Computed(function()
							return UDim2.fromOffset(Use(ContentSize), Use(ContentSize))
						end),
						ImageTransparency = EffectiveContentTransparency,
					}
				else
					return Text {
						Text = ContentString,
						TextColor3 = EffectiveContentColor,
						TextSize = ContentSize,
						TextTransparency = EffectiveContentTransparency,
						TextWrapped = false,
					}
				end
			end, Fusion.cleanup),
		},
	}))
end
