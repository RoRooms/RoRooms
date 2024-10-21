local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserService = game:GetService("UserService")

local RoRooms = script.Parent.Parent.Parent.Parent.Parent
local Future = require(RoRooms.Parent.Future)
local OnyxUI = require(RoRooms.Parent.OnyxUI)
local Fusion = require(RoRooms.Parent.Fusion)
local States = require(RoRooms.SourceCode.Client.UI.States)
local Config = require(RoRooms.Config).Config
local Assets = require(RoRooms.SourceCode.Shared.Assets)
local Components = require(RoRooms.SourceCode.Client.UI.Components)

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

	local ShownName = Scope:Computed(function(Use)
		local DisplayNameValue = Use(DisplayName)
		local NicknameValue = Use(Nickname)

		if NicknameValue then
			return NicknameValue
		elseif DisplayNameValue then
			return DisplayNameValue
		end

		return "Name"
	end)

	local NicknameInput = Scope:Value("")
	local BioInput = Scope:Value("")

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

	Scope:Observer(States.Menus.ProfileMenu.UserId):onChange(function()
		States.Menus.ProfileMenu.EditMode:set(false)

		UpdatePlayer()
		UpdateUserInfo()

		local UserId = Peek(States.Menus.ProfileMenu.UserId)
		if UserId ~= nil then
			local PlayerInstance = Players:GetPlayerByUserId(UserId)

			if PlayerInstance then
				PlayerInstance:GetAttributeChangedSignal("RR_Nickname"):Connect(function()
					UpdatePlayer()
				end)
				PlayerInstance:GetAttributeChangedSignal("RR_Status"):Connect(function()
					UpdatePlayer()
				end)
			end
		end
	end)
	Scope:Observer(States.Menus.CurrentMenu):onChange(function()
		States.Menus.ProfileMenu.EditMode:set(false)
	end)
	Scope:Observer(States.Menus.ProfileMenu.EditMode):onChange(function()
		NicknameInput:set(Peek(ShownName) or "")
		BioInput:set(Peek(Bio) or "")
	end)

	if not RunService:IsRunning() then
		States.Menus.ProfileMenu.UserId:set(Players.LocalPlayer.UserId)
	end

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
					Scope:Image {
						Name = "Banner",
						AutomaticSize = Enum.AutomaticSize.None,
						Size = Scope:Computed(function(Use)
							return UDim2.new(UDim.new(1, 0), UDim.new(0, Use(Theme.Spacing["4"]) * 1.5))
						end),
						BackgroundTransparency = 0,
						BackgroundColor3 = Theme.Colors.Neutral.Main,

						Image = Scope:Computed(function(Use)
							local UserIdValue = Use(States.Menus.ProfileMenu.UserId) or 1
							if UserIdValue <= 0 then
								UserIdValue = 1
							end

							return `rbxthumb://type=Avatar&id={UserIdValue}&w=420&h=420`
						end),
						ScaleType = Enum.ScaleType.Crop,
						ImageRectSize = Vector2.new(420, 200),

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
								Name = "Details",
								ListEnabled = true,
								ListHorizontalFlex = Enum.UIFlexAlignment.Fill,

								[Children] = {
									Scope:Frame {
										Name = "Display",
										ListEnabled = true,
										ListHorizontalFlex = Enum.UIFlexAlignment.Fill,
										ListPadding = Scope:Computed(function(Use)
											return UDim.new(0, Use(Theme.Spacing["0.75"]))
										end),
										Visible = Scope:Computed(function(Use)
											return not Use(States.Menus.ProfileMenu.EditMode)
										end),

										[Children] = {
											Scope:Frame {
												Name = "Name",
												ListEnabled = true,
												ListPadding = Scope:Computed(function(Use)
													return UDim.new(0, Use(Theme.Spacing["0"]))
												end),
												ListHorizontalFlex = Enum.UIFlexAlignment.Fill,
												LayoutOrder = 1,

												[Children] = {
													Scope:Text {
														Name = "Name",
														Text = ShownName,
														TextSize = Theme.TextSize["1.5"],
														FontFace = Scope:Computed(function(Use)
															return Font.new(
																Use(Theme.Font.Heading),
																Use(Theme.FontWeight.Heading)
															)
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
											Scope:Text {
												Name = "Bio",
												Text = Scope:Computed(function(Use)
													return Use(Bio) or ""
												end),
												TextWrapped = true,
												Visible = Scope:Computed(function(Use)
													return utf8.len(Use(Bio) or "") > 0
												end),
												LayoutOrder = 2,
											},
										},
									},
									Scope:Frame {
										Name = "Editor",
										ListEnabled = true,
										ListHorizontalFlex = Enum.UIFlexAlignment.Fill,
										ListPadding = Scope:Computed(function(Use)
											return UDim.new(0, Use(Theme.Spacing["0.75"]))
										end),
										Visible = States.Menus.ProfileMenu.EditMode,

										[Children] = {
											Scope:TextInput {
												Name = "Nickname",
												Text = NicknameInput,
												CharacterLimit = Config.Systems.Profiles.NicknameCharacterLimit,
												PlaceholderText = "Nickname",
											},
											Scope:TextArea {
												Name = "Bio",
												Text = BioInput,
												CharacterLimit = Config.Systems.Profiles.BioCharacterLimit,
												PlaceholderText = "Bio",
												AutomaticSize = Enum.AutomaticSize.Y,
												Size = Scope:Computed(function(Use)
													return UDim2.fromOffset(0, Use(Theme.TextSize["1"]) * 3)
												end),
											},
										},
									},
								},
							},
							Scope:Frame {
								Name = "Buttons",
								ListEnabled = true,
								ListHorizontalFlex = Enum.UIFlexAlignment.Fill,
								LayoutOrder = 3,

								[Children] = {
									Scope:Button {
										Name = "EditButton",
										Content = Scope:Computed(function(Use)
											local EditModeValue = Use(States.Menus.ProfileMenu.EditMode)
											if EditModeValue then
												return { Assets.Icons.General.Checkmark, "Save" }
											else
												return { Assets.Icons.General.EditPerson, "Edit" }
											end
										end),
										Color = Theme.Colors.Primary.Main,
										Visible = Scope:Computed(function(Use)
											return Use(States.Menus.ProfileMenu.UserId) == Players.LocalPlayer.UserId
										end),

										OnActivated = function()
											local EditModeValue = Peek(States.Menus.ProfileMenu.EditMode)

											if EditModeValue == true then
												States.Profile.Nickname:set(Peek(NicknameInput))
												States.Profile.Status:set(Peek(BioInput))
											end

											States.Menus.ProfileMenu.EditMode:set(not EditModeValue)
										end,
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
