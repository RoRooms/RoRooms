local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent)
local OnyxUI = require(RoRooms.Packages.OnyxUI)
local Fusion = require(OnyxUI.Parent.Fusion)
local States = require(RoRooms.Client.UI.States)
local Modifier = require(OnyxUI.Utils.Modifier)
local Themer = require(OnyxUI.Utils.Themer)

local Children = Fusion.Children
local Computed = Fusion.Computed
local ForValues = Fusion.ForValues
local New = Fusion.New
local Observer = Fusion.Observer
local Spring = Fusion.Spring

local AutoScaleFrame = require(OnyxUI.Components.AutoScaleFrame)
local MenuFrame = require(OnyxUI.Components.MenuFrame)
local TitleBar = require(OnyxUI.Components.TitleBar)
local ScrollingFrame = require(OnyxUI.Components.ScrollingFrame)
local FriendButton = require(RoRooms.Client.UI.Components.FriendButton)

return function(Props)
	local MenuOpen = Computed(function()
		return States.CurrentMenu:get() == script.Name
	end)

	local FriendsMenu = New "ScreenGui" {
		Name = "FriendsMenu",
		Parent = Props.Parent,
		Enabled = MenuOpen,
		ResetOnSpawn = false,

		[Children] = {
			AutoScaleFrame {
				AnchorPoint = Vector2.new(0.5, 0),
				Position = Spring(
					Computed(function()
						local YPos = States.TopbarBottomPos:get()
						if not MenuOpen:get() then
							YPos = YPos + 15
						end
						return UDim2.new(UDim.new(0.5, 0), UDim.new(0, YPos))
					end),
					Themer.Theme.SpringSpeed["1"],
					Themer.Theme.SpringDampening
				),
				BaseResolution = Vector2.new(739, 789),
				ScaleClamps = { Min = 1, Max = 1 },

				[Children] = {
					MenuFrame {
						Size = UDim2.fromOffset(365, 0),
						GroupTransparency = Spring(
							Computed(function()
								if MenuOpen:get() then
									return 0
								else
									return 1
								end
							end),
							Themer.Theme.SpringSpeed["1"],
							Themer.Theme.SpringDampening
						),
						BackgroundTransparency = States.PreferredTransparency,

						[Children] = {
							Modifier.ListLayout {},

							TitleBar {
								Title = "Friends",
								CloseButtonDisabled = true,
							},
							ScrollingFrame {
								Name = "FriendsList",
								Size = UDim2.new(UDim.new(1, 0), UDim.new(0, 180)),
								ScrollBarThickness = Themer.Theme.StrokeThickness["1"],
								ScrollBarImageColor3 = Themer.Theme.Colors.NeutralContent.Dark,

								[Children] = {
									Modifier.Padding {
										Padding = Computed(function()
											return UDim.new(0, Themer.Theme.StrokeThickness["1"]:get())
										end),
									},
									Modifier.ListLayout {
										Padding = Computed(function()
											return UDim.new(0, Themer.Theme.Spacing["0.75"]:get())
										end),
										FillDirection = Enum.FillDirection.Horizontal,
										Wraps = true,
									},

									ForValues(States.Friends.InRoRooms, function(Friend)
										return FriendButton {
											UserId = Friend.VisitorId,
											DisplayName = Friend.DisplayName,
											PlaceId = Friend.PlaceId,
											JobId = Friend.GameId,
											InRoRooms = true,
										}
									end, Fusion.cleanup),
									ForValues(States.Friends.NotInRoRooms, function(Friend)
										return FriendButton {
											UserId = Friend.VisitorId,
											DisplayName = Friend.DisplayName,
											PlaceId = Friend.PlaceId,
											JobId = Friend.GameId,
											InRoRooms = false,
										}
									end, Fusion.cleanup),
								},
							},
						},
					},
				},
			},
		},
	}

	local DisconnectOpen = Observer(MenuOpen):onChange(function()
		if MenuOpen:get() then
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
