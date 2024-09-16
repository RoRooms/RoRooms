local RoRooms = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(RoRooms.Parent.OnyxUI)
local Fusion = require(RoRooms.Parent.Fusion)

local Themer = OnyxUI.Themer
local Children = Fusion.Children
local Util = OnyxUI.Util

local DISABLED_TRANSPARENCY = 0.5

local OnyxUIFolder = RoRooms.Parent.OnyxUI.Parent._Index["imavafe_onyx-ui@0.4.1"]["onyx-ui"]
local SwitchGroup = require(OnyxUIFolder.Components.SwitchGroup)

export type Props = SwitchGroup.Props & {
	Label: Fusion.UsedAs<string>,
}

local function SettingToggle(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, Util, OnyxUI.Components)
	local Theme = Themer.Theme:now()

	local Switched = Scope:EnsureValue(Util.Fallback(Props.Switched, false))
	local Disabled = Util.Fallback(Props.Disabled, false)

	Props.Switched = Switched

	return Scope:SwitchGroup(Util.CombineProps(Props, {
		AutomaticSize = Enum.AutomaticSize.Y,
		Switched = Switched,
		Disabled = Disabled,

		[Children] = {
			Scope:Text {
				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.fromScale(0, 0.5),
				Text = Props.Label,
				TextColor3 = Theme.Colors.BaseContent.Main,
				TextTransparency = Scope:Computed(function(use)
					if use(Disabled) then
						return DISABLED_TRANSPARENCY
					else
						return 0
					end
				end),
				TextWrapped = false,
			},
			Scope:SwitchInput {
				AnchorPoint = Vector2.new(1, 0),
				Position = UDim2.fromScale(1, 0),
				Switched = Switched,
				Disabled = Props.Disabled,
				Selectable = false,
			},
		},
	}))
end

return SettingToggle
