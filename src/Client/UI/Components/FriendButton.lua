local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local SocialService = game:GetService("SocialService")

local RoRooms = script.Parent.Parent.Parent.Parent.Parent
local Future = require(script.Parent.Parent.Parent.Parent.Parent.Parent.Future)
local OnyxUI = require(RoRooms.Parent.OnyxUI)
local Fusion = require(RoRooms.Parent.Fusion)
local ColorUtils = require(RoRooms.Parent.ColorUtils)
local States = require(RoRooms.SourceCode.Client.UI.States)
local Prompts = require(RoRooms.SourceCode.Client.UI.States.Prompts)

local Children = Fusion.Children
local Util = OnyxUI.Util
local Themer = OnyxUI.Themer
local Peek = Fusion.peek

local CustomButton = require(RoRooms.SourceCode.Client.UI.Components.CustomButton)

return function(Scope: Fusion.Scope<any>, Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components, {
		CustomButton = CustomButton,
	})
	local Theme = Themer.Theme:now()

	local PlaceId = Scope:EnsureValue(Util.Fallback(Props.PlaceId, nil))
	local UserId = Util.Fallback(Props.UserId, 1)
	local DisplayName = Util.Fallback(Props.DisplayName, "DisplayName")
	local JobId = Util.Fallback(Props.JobId, nil)
	local InRoRooms = Util.Fallback(Props.InRoRooms, false)
	local Color = Util.Fallback(Props.Color, Theme.Colors.Neutral.Main)

	local PlaceInfo = Scope:Value({})

	local function UpdatePlaceInfo()
		if Peek(PlaceId) == nil then
			return
		end

		Future.Try(function()
			return MarketplaceService:GetProductInfo(Peek(PlaceId))
		end):After(function(Success, Result)
			if Success then
				PlaceInfo:set(Result)
			else
				warn(Result)
			end
		end)
	end

	Scope:Observer(PlaceId):onChange(UpdatePlaceInfo)
	UpdatePlaceInfo()

	local StatusColor = Scope:Computed(function(Use)
		if Use(InRoRooms) then
			return Color3.fromRGB(2, 183, 87)
		else
			return Color3.fromRGB(0, 162, 255)
		end
	end)

	return Scope:CustomButton {
		Name = "FriendButton",
		Parent = Props.Parent,
		ClipsDescendants = true,
		LayoutOrder = Props.LayoutOrder,
		ListEnabled = true,
		ListFillDirection = Enum.FillDirection.Vertical,
		ListHorizontalAlignment = Enum.HorizontalAlignment.Center,

		OnActivated = function()
			States.Menus.CurrentMenu:set(nil)

			if Peek(InRoRooms) then
				if Peek(JobId) == game.JobId then
					Prompts:PushPrompt({
						Title = "Failure",
						Text = "You're already in the same server as this person.",
						Buttons = {
							{
								Content = { "Close" },
							},
						},
					})
				else
					Prompts:PushPrompt({
						Title = "Teleport",
						Text = `Do you want to join friend in {Peek(PlaceInfo).Name}?`,
						Buttons = {
							{
								Content = { "Cancel" },
								Style = "Outlined",
							},
							{
								Content = { "Teleport" },
								Callback = function()
									if States.Services.WorldsService then
										States.Services.WorldsService:TeleportToWorld(Peek(PlaceId))
									end
								end,
							},
						},
					})
				end
			else
				SocialService:PromptGameInvite(
					Players.LocalPlayer,
					Scope:New "ExperienceInviteOptions" {
						InviteUser = Peek(UserId),
					}
				)
			end
		end,

		[Children] = {
			Scope:Avatar {
				Size = UDim2.fromOffset(80, 80),
				BackgroundColor3 = Scope:Computed(function(Use)
					return ColorUtils.Lighten(Use(Color), 0.06)
				end),
				Image = Scope:Computed(function(Use)
					return `rbxthumb://type=AvatarHeadShot&id={Use(UserId)}&w=150&h=150`
				end),
				CornerRadius = Scope:Computed(function(Use)
					return UDim.new(0, Use(Theme.CornerRadius.Full))
				end),
				RingEnabled = InRoRooms,
				RingColor = Util.Colors.Green["500"],
				IndicatorEnabled = Scope:Computed(function(Use)
					return not Use(InRoRooms)
				end),
				IndicatorColor = StatusColor,
			},
			Scope:Frame {
				Name = "Details",
				Size = UDim2.fromOffset(80, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				ListEnabled = true,
				ListPadding = UDim.new(0, 0),
				ListHorizontalFlex = Enum.UIFlexAlignment.Fill,

				[Children] = {
					Scope:Text {
						Name = "DisplayName",
						Text = DisplayName,
						TextTruncate = Enum.TextTruncate.AtEnd,
						AutomaticSize = Enum.AutomaticSize.Y,
						TextXAlignment = Enum.TextXAlignment.Center,
						TextWrapped = false,
					},
					Scope:Text {
						Name = "Status",
						Text = Scope:Computed(function(Use)
							return (Use(InRoRooms) and Use(PlaceInfo).Name) or "Online"
						end),
						TextColor3 = StatusColor,
						TextSize = Theme.TextSize["0.875"],
						TextTruncate = Enum.TextTruncate.AtEnd,
						AutomaticSize = Enum.AutomaticSize.Y,
						TextXAlignment = Enum.TextXAlignment.Center,
						TextWrapped = false,
					},
				},
			},
		},
	}
end
