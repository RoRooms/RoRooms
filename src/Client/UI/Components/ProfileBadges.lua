local RoRooms = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(RoRooms.Parent.OnyxUI)
local Fusion = require(RoRooms.Parent.Fusion)
local Assets = require(RoRooms.SourceCode.Shared.Assets)
local Profiles = require(RoRooms.SourceCode.Client.UI.States.Profiles)

local OnyxUIFolder = RoRooms.Parent._Index["imavafe_onyx-ui@0.4.3"]["onyx-ui"]
local Frame = require(OnyxUIFolder.Components.Frame)

export type Props = Frame.Props & {
	UserId: Fusion.UsedAs<number>?,
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Components, OnyxUI.Util)
	local Theme = OnyxUI.Themer.Theme:now()

	local UserId = OnyxUI.Util.Fallback(Props.UserId, nil)

	local Profile = Profiles.ProfileValue(Scope, UserId)
	local SafeProfile = Profiles.SafeProfileValue(Scope, Profile)
	local Badges = Scope:Computed(function(Use)
		local ReturnBadges = {}
		local SafeProfileValue = Use(SafeProfile)

		if SafeProfileValue.Membership == "RoRoomsPlus" then
			table.insert(ReturnBadges, "RoRoomsPlus")
		end
		if SafeProfileValue.ServerOwner then
			table.insert(ReturnBadges, "ServerOwner")
		end

		return ReturnBadges
	end)

	return Scope:IconText(OnyxUI.Util.CombineProps(Props, {
		Content = Scope:Computed(function(Use)
			local BadgesValue = Use(Badges)
			local Content = {}

			for _, Badge in ipairs(BadgesValue) do
				if Assets.Icons.UserBadges[Badge] then
					table.insert(Content, Assets.Icons.UserBadges[Badge])
				end
			end

			return Content
		end),

		ContentSize = Theme.TextSize["1.5"],
		ListVerticalAlignment = Enum.VerticalAlignment.Center,
	}))
end
