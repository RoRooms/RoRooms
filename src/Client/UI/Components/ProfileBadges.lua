local RoRooms = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(RoRooms.Parent.OnyxUI)
local Fusion = require(RoRooms.Parent.Fusion)
local Assets = require(RoRooms.SourceCode.Shared.Assets)

local Children = Fusion.Children

local OnyxUIFolder = RoRooms.Parent._Index["imavafe_onyx-ui@0.4.3"]["onyx-ui"]
local Frame = require(OnyxUIFolder.Components.Frame)

export type Props = Frame.Props & {
	UserId: Fusion.UsedAs<number>?,
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Components, OnyxUI.Util)
	local Theme = OnyxUI.Themer.Theme:now()

	local UserId = OnyxUI.Util.Fallback(Props.UserId, nil)

	return Scope:IconText(OnyxUI.Util.CombineProps(Props, {
		Content = {
			Assets.Icons.UserBadges.RoRoomsPlus,
			Assets.Icons.UserBadges.ServerOwner,
		},
		ContentSize = Theme.TextSize["1.5"],
		ListVerticalAlignment = Enum.VerticalAlignment.Center,
	}))
end
