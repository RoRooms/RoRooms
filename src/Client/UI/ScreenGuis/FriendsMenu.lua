local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent)

local Shared = RoRooms.Shared
local Client = RoRooms.Client

local NekaUI = require(Shared.ExtPackages.NekaUI)
local Fusion = require(NekaUI.Packages.Fusion)
local States = require(Client.UI.States)

local Children = Fusion.Children
local Computed = Fusion.Computed
local ForValues = Fusion.ForValues
local New = Fusion.New
local Observer = Fusion.Observer
local Spring = Fusion.Spring

local AutoScaleFrame = require(NekaUI.Components.AutoScaleFrame)
local MenuFrame = require(NekaUI.Components.MenuFrame)
local TitleBar = require(NekaUI.Components.TitleBar)
local ScrollingFrame = require(NekaUI.Components.ScrollingFrame)
local FriendButton = require(Client.UI.Components.FriendButton)

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
					37,
					1
				),
				BaseResolution = Vector2.new(883, 893),

				[Children] = {
					New "UIListLayout" {},
					MenuFrame {
						Size = UDim2.fromOffset(350, 0),
						GroupTransparency = Spring(
							Computed(function()
								if MenuOpen:get() then
									return 0
								else
									return 1
								end
							end),
							40,
							1
						),

						[Children] = {
							New "UIPadding" {
								PaddingBottom = UDim.new(0, 11),
								PaddingLeft = UDim.new(0, 11),
								PaddingRight = UDim.new(0, 11),
								PaddingTop = UDim.new(0, 9),
							},
							TitleBar {
								Title = "Friends",
								CloseButtonDisabled = true,
								TextSize = 24,
							},
							ScrollingFrame {
								Name = "FriendsList",
								Size = UDim2.new(UDim.new(1, 0), UDim.new(0, 180)),

								[Children] = {
									New "UIPadding" {
										PaddingLeft = UDim.new(0, 2),
										PaddingBottom = UDim.new(0, 2),
										PaddingTop = UDim.new(0, 2),
										PaddingRight = UDim.new(0, 2),
									},
									New "UIListLayout" {
										SortOrder = Enum.SortOrder.LayoutOrder,
										FillDirection = Enum.FillDirection.Horizontal,
										Wraps = true,
										Padding = UDim.new(0, 12),
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
		-- local TextClasses = { "TextLabel", "TextButton", "TextBox" }
		-- for _, Descendant in ipairs(FriendsMenu:GetDescendants()) do
		-- 	if table.find(TextClasses, Descendant.ClassName) then
		-- 		task.wait()
		-- 		AutomaticSizer.ApplyLayout(Descendant)
		-- 	end
		-- end

		if MenuOpen:get() then
			if States.FriendsController then
				States.FriendsController:UpdateFriends()
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
