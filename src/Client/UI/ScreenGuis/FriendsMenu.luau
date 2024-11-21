local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local SocialService = game:GetService("SocialService")

local Rorooms = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(Rorooms.Parent.OnyxUI)
local Fusion = require(Rorooms.Parent.Fusion)
local States = require(Rorooms.SourceCode.Client.UI.States)
local Components = require(Rorooms.SourceCode.Client.UI.Components)
local OnyxUITheme = require(Rorooms.SourceCode.Client.UI.OnyxUITheme)
local FriendsController = RunService:IsRunning() and require(Rorooms.SourceCode.Client.Friends.FriendsController)
local Assets = require(Rorooms.SourceCode.Shared.Assets)

local Children = Fusion.Children
local Themer = OnyxUI.Themer
local Peek = Fusion.peek

return function(Scope: Fusion.Scope<any>, Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components, Components)
	local Theme = Themer.Theme:now()

	local MenuOpen = Scope:Computed(function(Use)
		return Use(States.Menus.CurrentMenu) == script.Name
	end)

	local FriendsMenu = Scope:Menu({
		Name = script.Name,
		Open = MenuOpen,
		Parent = Props.Parent,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.fromOffset(361, 0),

		[Children] = {
			Scope:Scroller({
				Name = "Friends",
				Size = UDim2.new(UDim.new(1, 0), UDim.new(0, 180)),
				ScrollBarThickness = Theme.StrokeThickness["1"],
				Padding = Scope:Computed(function(Use)
					return UDim.new(0, Use(Theme.StrokeThickness["1"]))
				end),
				PaddingRight = Scope:Computed(function(Use)
					return UDim.new(0, Use(Theme.Spacing["1"]))
				end),
				ListEnabled = true,
				ListHorizontalFlex = Enum.UIFlexAlignment.Fill,

				[Children] = {
					Scope:Frame {
						ListPadding = Scope:Computed(function(Use)
							return UDim.new(0, Use(Theme.Spacing["0.75"]))
						end),
						ListFillDirection = Enum.FillDirection.Horizontal,
						ListWraps = true,

						[Children] = {
							Scope:ForValues(States.Friends.InRorooms, function(Use, Scope, Friend)
								return Themer.Theme:is(OnyxUITheme):during(function()
									return Scope:FriendButton({
										UserId = Friend.VisitorId,
										DisplayName = Friend.DisplayName,
										PlaceId = Friend.PlaceId,
										JobId = Friend.GameId,
										InRorooms = true,
									})
								end)
							end),
							Scope:ForValues(States.Friends.NotInRorooms, function(Use, Scope, Friend)
								return Themer.Theme:is(OnyxUITheme):during(function()
									return Scope:FriendButton({
										UserId = Friend.VisitorId,
										DisplayName = Friend.DisplayName,
										Online = Friend.IsOnline,
										PlaceId = Friend.PlaceId,
										JobId = Friend.GameId,
										InRorooms = false,
									})
								end)
							end),
						},
					},
					Scope:Button({
						Name = "InviteButton",
						Content = { Assets.Icons.General.People, "Invite Others" },
						AutomaticSize = Enum.AutomaticSize.Y,

						OnActivated = function()
							SocialService:PromptGameInvite(Players.LocalPlayer)
						end,
					}),
				},
			}),
		},
	})

	Scope:Observer(MenuOpen):onChange(function()
		if Peek(MenuOpen) and FriendsController then
			FriendsController:UpdateFriends()
		end
	end)

	return FriendsMenu
end
