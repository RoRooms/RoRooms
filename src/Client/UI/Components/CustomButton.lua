local RoRooms = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(RoRooms.Parent.OnyxUI)
local Fusion = require(RoRooms.Parent.Fusion)

local Util = OnyxUI.Util
local Themer = OnyxUI.Themer

local OnyxUIFolder = RoRooms.Parent.OnyxUI.Parent._Index["imavafe_onyx-ui@0.4.3"]["onyx-ui"]
local Button = require(OnyxUIFolder.Components.Button)

export type Props = Button.Props & {}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components)
	local Theme = Themer.Theme:now()

	local Color = Util.Fallback(Props.Color, Theme.Colors.Neutral.Main)

	return Scope:Button(Util.CombineProps(Props, {
		Color = Color,
		CornerRadius = Scope:Computed(function(Use)
			return UDim.new(0, Use(Theme.CornerRadius["2"]))
		end),
		PaddingTop = Scope:Computed(function(Use)
			return UDim.new(0, Use(Theme.Spacing["0.5"]))
		end),
		PaddingBottom = Scope:Computed(function(Use)
			return UDim.new(0, Use(Theme.Spacing["0.5"]))
		end),
		PaddingLeft = Scope:Computed(function(Use)
			return UDim.new(0, Use(Theme.Spacing["0.5"]))
		end),
		PaddingRight = Scope:Computed(function(Use)
			return UDim.new(0, Use(Theme.Spacing["0.5"]))
		end),
	}))
end
