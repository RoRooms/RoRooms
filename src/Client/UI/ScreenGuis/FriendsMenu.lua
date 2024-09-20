local RoRooms = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(RoRooms.Parent.OnyxUI)
local Fusion = require(RoRooms.Parent.Fusion)
local States = require(RoRooms.SourceCode.Client.UI.States)
local Components = require(RoRooms.SourceCode.Client.UI.Components)
local OnyxUITheme = require(RoRooms.SourceCode.Client.UI.OnyxUITheme)
local FriendsController = require(RoRooms.SourceCode.Client.Friends.FriendsController)

local Children = Fusion.Children
local Themer = OnyxUI.Themer
local Peek = Fusion.peek

return function(Scope: Fusion.Scope<any>, Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components, Components)
	local Theme = Themer.Theme:now()

	local MenuOpen = Scope:Computed(function(Use)
		return Use(States.Menus.CurrentMenu) == script.Name
	end)

	local FriendsMenu = Scope:Menu {
		Name = script.Name,
		Open = MenuOpen,
		Parent = Props.Parent,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.fromOffset(361, 0),

		[Children] = {
			Scope:Scroller {
				Name = "FriendsList",
				Size = UDim2.new(UDim.new(1, 0), UDim.new(0, 180)),
				ScrollBarThickness = Theme.StrokeThickness["1"],
				Padding = Scope:Computed(function(Use)
					return UDim.new(0, Use(Theme.StrokeThickness["1"]))
				end),
				PaddingRight = Scope:Computed(function(Use)
					return UDim.new(0, Use(Theme.Spacing["1"]))
				end),
				ListEnabled = true,
				ListPadding = Scope:Computed(function(Use)
					return UDim.new(0, Use(Theme.Spacing["0.75"]))
				end),
				ListFillDirection = Enum.FillDirection.Horizontal,
				ListWraps = true,

				[Children] = {
					Scope:ForValues(States.Friends.InRoRooms, function(Use, Scope, Friend)
						return Themer.Theme:is(OnyxUITheme):during(function()
							return Scope:FriendButton {
								UserId = Friend.VisitorId,
								DisplayName = Friend.DisplayName,
								PlaceId = Friend.PlaceId,
								JobId = Friend.GameId,
								InRoRooms = true,
							}
						end)
					end),
					Scope:ForValues(States.Friends.NotInRoRooms, function(Use, Scope, Friend)
						return Themer.Theme:is(OnyxUITheme):during(function()
							return Scope:FriendButton {
								UserId = Friend.VisitorId,
								DisplayName = Friend.DisplayName,
								PlaceId = Friend.PlaceId,
								JobId = Friend.GameId,
								InRoRooms = false,
							}
						end)
					end),
				},
			},
		},
	}

	Scope:Observer(MenuOpen):onChange(function()
		if Peek(MenuOpen) then
			FriendsController:UpdateFriends()
		end
	end)

	return FriendsMenu
end
