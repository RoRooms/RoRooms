local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent)
local OnyxUI = require(RoRooms.Packages.OnyxUI)
local Fusion = require(RoRooms.Packages.Fusion)
local States = require(RoRooms.Client.UI.States)

local Children = Fusion.Children

local AutoScaleFrame = require(OnyxUI.Components.AutoScaleFrame)
local MenuFrame = require(OnyxUI.Components.MenuFrame)
local TitleBar = require(OnyxUI.Components.TitleBar)
local ScrollingFrame = require(OnyxUI.Components.ScrollingFrame)
local FriendButton = require(RoRooms.Client.UI.Components.FriendButton)

return function(Scope: Fusion.Scope<any>, Props)
	local MenuOpen = Scope:Computed(function(Use)
		return Use(States.CurrentMenu) == script.Name
	end)

	local FriendsMenu = Scope:New "ScreenGui" {
		Name = "FriendsMenu",
		Parent = Props.Parent,
		Enabled = MenuOpen,
		ResetOnSpawn = false,

		[Children] = {
			AutoScaleFrame {
				AnchorPoint = Vector2.new(0.5, 0),
				Position = Scope:Spring(
					Scope:Computed(function(Use)
						local YPos = Use(States.TopbarBottomPos)
						if not Use(MenuOpen) then
							YPos = YPos + 15
						end
						return UDim2.new(UDim.new(0.5, 0), UDim.new(0, YPos))
					end),
					Theme.SpringSpeed["1"],
					Theme.SpringDampening["1"]
				),
				BaseResolution = Vector2.new(739, 789),
				MinScale = 1,
				MaxScale = 1,

				[Children] = {
					MenuFrame {
						Size = UDim2.fromOffset(345, 0),
						GroupTransparency = Scope:Spring(
							Scope:Computed(function(Use)
								if Use(MenuOpen) then
									return 0
								else
									return 1
								end
							end),
							Theme.SpringSpeed["1"],
							Theme.SpringDampening["1"]
						),
						BackgroundTransparency = States.PreferredTransparency,
						ListEnabled = true,

						[Children] = {
							TitleBar {
								Title = "Friends",
								CloseButtonDisabled = true,
							},
							ScrollingFrame {
								Name = "FriendsList",
								Size = UDim2.new(UDim.new(1, 0), UDim.new(0, 180)),
								ScrollBarThickness = Theme.StrokeThickness["1"],
								ScrollBarImageColor3 = Theme.Colors.NeutralContent.Dark,
								Padding = Scope:Computed(function(Use)
									return UDim.new(0, Use(Theme.StrokeThickness["1"]))
								end),
								ListEnabled = true,
								ListPadding = Scope:Computed(function(Use)
									return UDim.new(0, Use(Theme.Spacing["0.75"]))
								end),
								ListFillDirection = Enum.FillDirection.Horizontal,
								ListWraps = true,

								[Children] = {
									Scope:ForValues((States.Friends.InRoRooms, function(Friend)
										return FriendButton {
											UserId = Friend.VisitorId,
											DisplayName = Friend.DisplayName,
											PlaceId = Friend.PlaceId,
											JobId = Friend.GameId,
											InRoRooms = true,
										}
									end),
									Scope:ForValues((States.Friends.NotInRoRooms, function(Friend)
										return FriendButton {
											UserId = Friend.VisitorId,
											DisplayName = Friend.DisplayName,
											PlaceId = Friend.PlaceId,
											JobId = Friend.GameId,
											InRoRooms = false,
										}
									end),
								},
							},
						},
					},
				},
			},
		},
	}

	local DisconnectOpen = Scope:Observer(MenuOpen):onChange(function()
		if Use(MenuOpen) then
			if States.Controllers.FriendsController then
				States.Controllers.FriendsController:UpdateFriends()
			end
		end
	end)

	FriendsMenu:GetPropertyChangedSignal("Parent"):Connect(function()
		if FriendsMenu.Parent == nil then
			DisconnectOpen()
		end
	end)

	return FriendsMenu
end
