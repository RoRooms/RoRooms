local Players = game:GetService("Players")
local UserService = game:GetService("UserService")

local RoRooms = script.Parent.Parent.Parent.Parent.Parent
local Future = require(RoRooms.Parent.Future)
local OnyxUI = require(RoRooms.Parent.OnyxUI)
local Fusion = require(RoRooms.Parent.Fusion)
local States = require(RoRooms.SourceCode.Client.UI.States)
local Config = require(RoRooms.Config).Config
local Assets = require(RoRooms.SourceCode.Shared.Assets)
local Components = require(RoRooms.SourceCode.Client.UI.Components)
local GetUsernameColor = require(RoRooms.SourceCode.Shared.ExtPackages.GetUsernameColor)

local Children = Fusion.Children
local Themer = OnyxUI.Themer
local Peek = Fusion.peek

return function(Scope: Fusion.Scope<any>, Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components, Components)
	local Theme = Themer.Theme:now()

	local MenuOpen = Scope:Computed(function(Use)
		return Use(States.Menus.CurrentMenu) == script.Name
	end)

	local Player = Scope:Value()
	local Username = Scope:Value()
	local DisplayName = Scope:Value()
	local Nickname = Scope:Value()
	local Bio = Scope:Value()
	local UserInfo = Scope:Value()

	local function UpdateUserInfo()
		local UserId = Peek(States.Menus.ProfileMenu.UserId) or 1
		Future.Try(function()
			return UserService:GetUserInfosByUserIdsAsync({ UserId })[1]
		end):After(function(Success, Response)
			if Success and Response then
				UserInfo:set(Response)
			end
		end)
	end
	local function UpdatePlayer()
		local UserId = Peek(States.Menus.ProfileMenu.UserId)
		if UserId ~= nil then
			local PlayerInstance = Players:GetPlayerByUserId(UserId)

			Player:set(PlayerInstance)

			if PlayerInstance then
				Username:set(PlayerInstance.Name)
				DisplayName:set(PlayerInstance.DisplayName)
				Nickname:set(PlayerInstance:GetAttribute("RR_Nickname"))
				Bio:set(PlayerInstance:GetAttribute("RR_Status"))
			end
		end
	end
	task.spawn(function()
		UpdateUserInfo()
		UpdatePlayer()
	end)
	Scope:Observer(States.Menus.ProfileMenu.UserId):onChange(function(Use)
		UpdatePlayer()
		UpdateUserInfo()
	end)

	local ChatColor = Scope:Computed(function(Use)
		return GetUsernameColor(Use(Username) or "Username")
	end)

	task.delay(0.5, function()
		States.Menus.CurrentMenu:set("ProfileMenu")
		States.Menus.ProfileMenu.UserId:set(144146784)
	end)

	local ProfileMenu = Scope:Menu {
		Name = script.Name,
		Open = MenuOpen,
		Parent = Props.Parent,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.fromOffset(280, 0),
		ListHorizontalFlex = Enum.UIFlexAlignment.Fill,
		Padding = Scope:Computed(function(Use)
			return UDim.new(0, Use(Theme.Spacing["0"]))
		end),

		[Children] = {
			Scope:Frame {
				ListEnabled = true,
				ListPadding = Scope:Computed(function(Use)
					return UDim.new(0, Theme.Spacing["0"])
				end),
				ListHorizontalFlex = Enum.UIFlexAlignment.Fill,

				[Children] = {
					Scope:Frame {
						Name = "Banner",
						AutomaticSize = Enum.AutomaticSize.None,
						Size = Scope:Computed(function(Use)
							return UDim2.new(UDim.new(1, 0), UDim.new(0, Use(Theme.Spacing["4"]) * 1.5))
						end),
						BackgroundTransparency = 0,
						BackgroundColor3 = ChatColor,

						[Children] = {
							Scope:Avatar {
								Name = "Avatar",
								AnchorPoint = Vector2.new(0, 1),
								Position = Scope:Computed(function(Use)
									return UDim2.new(UDim.new(0, Use(Theme.Spacing["1"])), UDim.new(1.5, 0))
								end),
								Image = Scope:Computed(function(Use)
									local UserIdValue = Use(States.Menus.ProfileMenu.UserId) or 1
									if UserIdValue <= 0 then
										UserIdValue = 1
									end

									return `rbxthumb://type=AvatarHeadShot&id={UserIdValue}&w=100&h=100`
								end),
								Size = Scope:Computed(function(Use)
									local Offset = Use(Theme.TextSize["4.5"])
									return UDim2.fromOffset(Offset, Offset)
								end),
								AspectRatio = 1,
								CornerRadius = Scope:Computed(function(Use)
									return UDim.new(0, Use(Theme.CornerRadius.Full))
								end),
								RingEnabled = true,
								RingColor = Theme.Colors.Base.Main,
								RingThickness = Theme.StrokeThickness["4"],
							},
						},
					},
					Scope:Frame {
						Name = "Badges",
						Padding = Scope:Computed(function(Use)
							return UDim.new(0, Use(Theme.Spacing["0.75"]))
						end),

						[Children] = {
							Scope:Frame {
								Name = "Badges",
								AnchorPoint = Vector2.new(1, 0),
								Position = UDim2.fromScale(1, 0),
								ListEnabled = true,
								ListFillDirection = Enum.FillDirection.Horizontal,
								ListPadding = Scope:Computed(function(Use)
									return UDim.new(0, Use(Theme.Spacing["0.5"]))
								end),
								ListVerticalAlignment = Enum.VerticalAlignment.Center,

								[Children] = {
									Scope:IconText {
										Content = { Assets.Icons.UserBadges.Level, "100" },
										ContentSize = Theme.TextSize["1.25"],
										ListVerticalAlignment = Enum.VerticalAlignment.Center,
									},
									Scope:IconText {
										Content = {
											Assets.Icons.UserBadges.RoRoomsPlus,
											Assets.Icons.UserBadges.ServerOwner,
										},
										ContentSize = Theme.TextSize["1.5"],
										ListVerticalAlignment = Enum.VerticalAlignment.Center,
									},
								},
							},
						},
					},
					Scope:Frame {
						Name = "Main",
						ListEnabled = true,
						ListHorizontalFlex = Enum.UIFlexAlignment.Fill,
						Padding = Scope:Computed(function(Use)
							return UDim.new(0, Use(Theme.Spacing["1"]))
						end),

						[Children] = {
							Scope:Frame {
								Name = "Name",
								ListEnabled = true,
								ListPadding = Scope:Computed(function(Use)
									return UDim.new(0, Use(Theme.Spacing["0"]))
								end),
								LayoutOrder = 1,

								[Children] = {
									Scope:Text {
										Name = "Name",
										Text = Scope:Computed(function(Use)
											local DisplayNameValue = Use(DisplayName)
											local NicknameValue = Use(Nickname)

											if NicknameValue then
												return NicknameValue
											elseif DisplayNameValue then
												return DisplayNameValue
											end

											return "Name"
										end),
										TextSize = Theme.TextSize["1.5"],
										FontFace = Scope:Computed(function(Use)
											return Font.new(Use(Theme.Font.Heading), Use(Theme.FontWeight.Heading))
										end),
									},
									Scope:Text {
										Name = "Username",
										Text = Scope:Computed(function(Use)
											return `@{Use(Username)}`
										end),
										TextColor3 = Theme.Colors.NeutralContent.Dark,
									},
								},
							},
							Scope:Computed(function(Use)
								if Use(Bio) ~= nil then
									return Scope:Text {
										Name = "Bio",
										Text = Bio,
										LayoutOrder = 2,
									}
								end

								return nil
							end),
							Scope:Frame {
								ListEnabled = true,
								ListHorizontalFlex = Enum.UIFlexAlignment.Fill,
								LayoutOrder = 3,

								[Children] = {
									Scope:Button {
										Content = { Assets.Icons.General.EditPerson, "Edit" },
										Color = Theme.Colors.Primary.Main,
									},
								},
							},
						},
					},
				},
			},
		},
	}

	return ProfileMenu
end
