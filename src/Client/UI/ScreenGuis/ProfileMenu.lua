local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local SocialService = game:GetService("SocialService")

local RoRooms = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(RoRooms.Parent.OnyxUI)
local Fusion = require(RoRooms.Parent.Fusion)
local States = require(RoRooms.SourceCode.Client.UI.States)
local Config = require(RoRooms.Config).Config
local Assets = require(RoRooms.SourceCode.Shared.Assets)
local Components = require(RoRooms.SourceCode.Client.UI.Components)
local WorldsController = RunService:IsRunning() and require(RoRooms.SourceCode.Client.Worlds.WorldsController)
local Profiles = require(RoRooms.SourceCode.Client.UI.States.Profiles)
local Types = require(RoRooms.SourceCode.Shared.Types)

local Children = Fusion.Children
local Themer = OnyxUI.Themer
local Peek = Fusion.peek

return function(Scope: Fusion.Scope<any>, Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components, Components, {
		Profile = Profiles.ProfileValue,
		SafeProfile = Profiles.SafeProfileValue,
	})
	local Theme = Themer.Theme:now()

	local MenuOpen = Scope:Computed(function(Use)
		return Use(States.Menus.CurrentMenu) == script.Name
	end)

	local Profile = Scope:Profile(States.Menus.ProfileMenu.UserId)
	local SafeProfile = Scope:SafeProfile(Profile)

	local ShownName = Scope:Computed(function(Use)
		local SafeProfileValue: Types.Profile = Use(SafeProfile)

		if string.len(SafeProfileValue.Nickname or "") > 0 then
			return SafeProfileValue.Nickname
		else
			return SafeProfileValue.DisplayName
		end
	end)

	local NicknameInput = Scope:Value("")
	local BioInput = Scope:Value("")

	Scope:Observer(States.Menus.ProfileMenu.UserId):onChange(function()
		States.Menus.ProfileMenu.EditMode:set(false)
	end)
	Scope:Observer(States.Menus.CurrentMenu):onChange(function()
		States.Menus.ProfileMenu.EditMode:set(false)

		if Fusion.peek(States.Menus.CurrentMenu) ~= script.Name then
			States.Menus.ProfileMenu.UserId:set(nil)
			States.Menus.ProfileMenu.Location.Online:set(false)
			States.Menus.ProfileMenu.Location.InRoRooms:set(false)
			States.Menus.ProfileMenu.Location.PlaceId:set(nil)
			States.Menus.ProfileMenu.Location.JobId:set(nil)
		end
	end)
	Scope:Observer(States.Menus.ProfileMenu.EditMode):onChange(function()
		local ProfileValue = Peek(Profile)

		if Peek(States.Menus.ProfileMenu.EditMode) then
			NicknameInput:set(ProfileValue.Nickname or "")
			BioInput:set(ProfileValue.Bio or "")
		end
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
							Scope:PlayerAvatar {
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
								Editable = Scope:Computed(function(Use)
									local EditModeValue = Use(States.Menus.ProfileMenu.EditMode)
									return EditModeValue and (Config.Systems.Profiles.AvatarEditorCallback ~= nil)
								end),
								RingThickness = Scope:Computed(function(Use)
									return Use(Theme.StrokeThickness["3"])
								end),
								Status = Scope:Computed(function(Use)
									if Use(States.Menus.ProfileMenu.EditMode) then
										return "Offline"
									end
									if Use(States.Menus.ProfileMenu.UserId) == Players.LocalPlayer.UserId then
										return "RoRooms"
									end

									if Use(States.Menus.ProfileMenu.Location.InRoRooms) then
										return "RoRooms"
									elseif Use(States.Menus.ProfileMenu.Location.Online) then
										return "Online"
									else
										return "Offline"
									end
								end),

								OnActivated = function()
									if Config.Systems.Profiles.AvatarEditorCallback then
										Config.Systems.Profiles.AvatarEditorCallback()
									end
								end,
							},
						},
					},
					Scope:Frame {
						Name = "Badges",
						Padding = Scope:Computed(function(Use)
							return UDim.new(0, Use(Theme.Spacing["0.5"]))
						end),

						[Children] = {
							Scope:Frame {
								Name = "Container",
								AnchorPoint = Vector2.new(1, 0),
								Position = UDim2.fromScale(1, 0),
								ListEnabled = true,
								ListFillDirection = Enum.FillDirection.Horizontal,
								ListPadding = Scope:Computed(function(Use)
									return UDim.new(0, Use(Theme.Spacing["0.5"]))
								end),

								[Children] = {
									Scope:IconText {
										Content = { " " },
										ContentSize = Theme.TextSize["1.5"],
									},
									Scope:LevelBadge {
										Visible = Scope:Computed(function(Use)
											local ProfileValue = Use(Profile)
											return (ProfileValue ~= nil) and ProfileValue.Level
										end),
										Level = Scope:Computed(function(Use)
											local SafeProfileValue = Use(SafeProfile)
											return SafeProfileValue.Level
										end),
									},
									Scope:ProfileBadges {
										UserId = States.Menus.ProfileMenu.UserId,
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
															local SafeProfileValue: Types.Profile = Use(SafeProfile)
															return `@{Use(SafeProfileValue.Username)}`
														end),
														TextColor3 = Theme.Colors.NeutralContent.Dark,
													},
												},
											},
											Scope:Text {
												Name = "Bio",
												Text = Scope:Computed(function(Use)
													local SafeProfileValue: Types.Profile = Use(SafeProfile)
													return SafeProfileValue.Bio or ""
												end),
												TextWrapped = true,
												Visible = Scope:Computed(function(Use)
													local SafeProfileValue: Types.Profile = Use(SafeProfile)
													return utf8.len(SafeProfileValue.Bio or "") > 0
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
								ListFillDirection = Enum.FillDirection.Horizontal,
								ListPadding = Scope:Computed(function(Use)
									return UDim.new(0, Use(Theme.Spacing["0.5"]))
								end),
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
												if next(States.Services.ProfilesService) ~= nil then
													States.Services.ProfilesService:SetNickname(Peek(NicknameInput))
													States.Services.ProfilesService:SetBio(Peek(BioInput))
												end
											end

											States.Menus.ProfileMenu.EditMode:set(not EditModeValue)
										end,
									},
									Scope:Button {
										Name = "JoinButton",
										Content = { Assets.Icons.General.Play, "Join" },
										Color = OnyxUI.Util.Colors.Green["500"],
										Visible = Scope:Computed(function(Use)
											local UserIdValue = Use(States.Menus.ProfileMenu.UserId)
											local InRoRoomsValue = Use(States.Menus.ProfileMenu.Location.InRoRooms)
											local JobIdValue = Use(States.Menus.ProfileMenu.Location.JobId)

											return (UserIdValue ~= Players.LocalPlayer.UserId)
												and (InRoRoomsValue and JobIdValue)
										end),

										OnActivated = function()
											local JobIdValue = Peek(States.Menus.ProfileMenu.Location.JobId)
											local PlaceIdValue = Peek(States.Menus.ProfileMenu.Location.PlaceId)

											if JobIdValue and PlaceIdValue then
												if WorldsController then
													WorldsController:TeleportToWorld(PlaceIdValue, Peek(JobIdValue))
												end
											end
										end,
									},
									Scope:Button {
										Name = "InviteButton",
										Content = { Assets.Icons.General.Mail, "Invite" },
										Color = Scope:Computed(function(Use)
											local InRoRoomsValue = Use(States.Menus.ProfileMenu.Location.InRoRooms)

											if InRoRoomsValue then
												return Use(Theme.Colors.Neutral.Main)
											else
												return Use(Theme.Colors.Primary.Main)
											end
										end),
										Visible = Scope:Computed(function(Use)
											return Use(States.Menus.ProfileMenu.UserId) ~= Players.LocalPlayer.UserId
										end),

										OnActivated = function()
											SocialService:PromptGameInvite(
												Players.LocalPlayer,
												Scope:New "ExperienceInviteOptions" {
													InviteUser = Peek(States.Menus.ProfileMenu.UserId),
												}
											)
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
