local RoRooms = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(RoRooms.Parent.OnyxUI)
local Fusion = require(RoRooms.Parent.Fusion)
local Assets = require(RoRooms.SourceCode.Shared.Assets)

local Children = Fusion.Children

local OnyxUIFolder = RoRooms.Parent._Index["imavafe_onyx-ui@0.5.0"]["onyx-ui"]
local Frame = require(OnyxUIFolder.Components.Frame)

export type Props = Frame.Props & {
	Level: Fusion.UsedAs<number>?,
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Components, OnyxUI.Util)
	local Theme = OnyxUI.Themer.Theme:now()

	local Level = OnyxUI.Util.Fallback(Props.Level, 0)

	return Scope:Frame(OnyxUI.Util.CombineProps(Props, {
		Name = "LevelBadge",
		ListEnabled = true,
		ListFillDirection = Enum.FillDirection.Horizontal,
		ListPadding = Scope:Computed(function(Use)
			return UDim.new(0, Use(Theme.Spacing["0"]))
		end),
		ListVerticalAlignment = Enum.VerticalAlignment.Center,

		[Children] = {
			Scope:IconText {
				Content = { Assets.Icons.UserBadges.Level },
				ContentSize = Theme.TextSize["1.5"],
			},
			Scope:IconText {
				Content = Scope:Computed(function(Use)
					return { Use(Level) }
				end),
				ContentSize = Theme.TextSize["1.25"],
			},
		},
	}))
end
