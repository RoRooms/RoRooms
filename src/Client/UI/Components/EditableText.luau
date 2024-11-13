local Rorooms = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(Rorooms.Parent.OnyxUI)
local Fusion = require(Rorooms.Parent.Fusion)

local Util = OnyxUI.Util
local Themer = OnyxUI.Themer

local OnyxUIFolder = Rorooms.Parent._Index["imavafe_onyx-ui@0.5.0"]["onyx-ui"]
local TextInput = require(OnyxUIFolder.Components.TextInput)

export type Props = TextInput.Props & {}

return function(Scope, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Components, Util)
	local Theme = Themer.Theme:now()

	local Disabled = Util.Fallback(Props.Disabled, false)

	return Scope:Hydrate(Scope:TextInput(Util.CombineProps(Props, {
		Name = "EditableText",
		Disabled = Disabled,
		TextTransparency = 0,
		StrokeEnabled = Scope:Computed(function(Use)
			return not Use(Disabled)
		end),
		Padding = Scope:Computed(function(Use)
			if Use(Disabled) then
				return UDim.new(0, Use(Theme.Spacing["0"]))
			else
				return UDim.new(0, Use(Theme.Spacing["0.5"]))
			end
		end),
	}))) {
		Selectable = Scope:Computed(function(Use)
			return not Use(Disabled)
		end),
	}
end
