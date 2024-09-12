local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent)
local OnyxUI = require(RoRooms.Packages.OnyxUI)
local Fusion = require(RoRooms.Packages.Fusion)
local ColorUtils = require(RoRooms.Packages.ColorUtils)

local Children = Fusion.Children

local BaseButton = require(OnyxUI.Components.BaseButton)
local Text = require(OnyxUI.Components.Text)
local Icon = require(OnyxUI.Components.Icon)

local DISABLED_BACKGROUND_TRANSPARENCY = 0.925
local DISABLED_CONTENT_TRANSPARENCY = 0.75

export type Props = BaseButton.Props & {
	Disabled: Fusion.UsedAs<boolean>?,
	Content: Fusion.UsedAs<{ string }>?,
	Style: Fusion.UsedAs<string>?,
	Color: Fusion.UsedAs<Color3>?,
	ContentColor: Fusion.UsedAs<Color3>?,
	ContentSize: Fusion.UsedAs<number>?,
	IsHolding: Fusion.UsedAs<boolean>?,
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Disabled = Scope:EnsureValue(Props.Disabled, false)
	local Content = Scope:EnsureValue(Props.Content, {})
	local Style = Scope:EnsureValue(Props.Style, "Filled")
	local Color = Scope:EnsureValue(Props.Color, Theme.Colors.Primary.Main)
	local ContentColor = Scope:EnsureValue(
		Props.ContentColor,
		"Color3",
		Scope:Computed(function(Use)
			return ColorUtils.Emphasize(Use(Color), Use(Theme.Emphasis.Contrast))
		end)
	)
	local ContentSize = Scope:EnsureValue(Props.ContentSize, Theme.TextSize["1"])

	local IsHolding = Scope:EnsureValue(Props.IsHolding, false)
	local IsHovering = Scope:EnsureValue(Props.IsHovering, false)
	local EffectiveColor = Scope:Computed(function(Use)
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
	local EffectiveContentColor = Scope:Computed(function(Use)
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
	local EffectiveContentTransparency = Scope:Computed(function(Use)
		if Use(Disabled) then
			return DISABLED_CONTENT_TRANSPARENCY
		else
			return 0
		end
	end)

	return BaseButton(CombineProps(Props, {
		Name = "Button",
		BackgroundTransparency = Scope:Computed(function(Use)
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
		BackgroundColor3 = Scope:Spring(EffectiveColor, Theme.SpringSpeed["1"], Theme.SpringDampening["1"]),
		PaddingLeft = Scope:Computed(function(Use)
			return UDim.new(0, Use(Theme.Spacing["0.75"]))
		end),
		PaddingRight = Scope:Computed(function(Use)
			return UDim.new(0, Use(Theme.Spacing["0.75"]))
		end),
		PaddingTop = Scope:Computed(function(Use)
			return UDim.new(0, Use(Theme.Spacing["0.25"]))
		end),
		PaddingBottom = Scope:Computed(function(Use)
			return UDim.new(0, Use(Theme.Spacing["0.25"]))
		end),
		CornerRadius = Scope:Computed(function(Use)
			return UDim.new(0, Use(Theme.CornerRadius["1"]))
		end),
		ListEnabled = true,
		ListPadding = Scope:Computed(function(Use)
			return UDim.new(0, Use(Theme.Spacing["0.25"]))
		end),
		ListFillDirection = Enum.FillDirection.Horizontal,
		ListHorizontalAlignment = Enum.HorizontalAlignment.Center,
		ListVerticalAlignment = Enum.VerticalAlignment.Center,
		StrokeEnabled = true,
		StrokeColor = Scope:Spring(EffectiveColor, Theme.SpringSpeed["1"], Theme.SpringDampening["1"]),
		StrokeTransparency = Scope:Computed(function(Use)
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
			Scope:ForValues((Content, function(ContentString: string)
				if string.find(ContentString, "rbxassetid://", 1, true) then
					return Icon {
						Image = ContentString,
						ImageColor3 = EffectiveContentColor,
						Size = Scope:Computed(function(Use)
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
			end),
		},
	}))
end
