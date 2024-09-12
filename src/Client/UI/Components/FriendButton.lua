local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local SocialService = game:GetService("SocialService")

local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent)
local Future = require(script.Parent.Parent.Parent.Parent.Parent.Parent.Future)
local OnyxUI = require(RoRooms.Packages.OnyxUI)
local Fusion = require(RoRooms.Packages.Fusion)
local ColorUtils = require(RoRooms.Packages.ColorUtils)
local States = require(RoRooms.Client.UI.States)
local Prompts = require(RoRooms.Client.UI.States.Prompts)

local Children = Fusion.Children

local CustomButton = require(RoRooms.Client.UI.Components.CustomButton)

return function(Scope: Fusion.Scope<any>, Props)
	local UserId = Scope:EnsureValue(Props.UserId, 1)
	local DisplayName = Scope:EnsureValue(Props.DisplayName, "DisplayName")
	local PlaceId = Scope:EnsureValue(Props.PlaceId, nil)
	local JobId = Scope:EnsureValue(Props.JobId, nil)
	local InRoRooms = Scope:EnsureValue(Props.InRoRooms, false)
	local Color = Scope:EnsureValue(Props.Color, Theme.Colors.Neutral.Main)

	local IsHolding = Scope:Value(false)
	local PlaceInfo = Scope:Value({})

	local function UpdatePlaceInfo()
		if Use(Props.PlaceId) == nil then
			return
		end

		Future.Try(function()
			return MarketplaceService:GetProductInfo(Use(Props.PlaceId))
		end):After(function(Success, Result)
			if Success then
				PlaceInfo:set(Result)
			else
				warn(Result)
			end
		end)
	end

	local Observers = {
		Scope:Observer(Props.PlaceId):onChange(UpdatePlaceInfo),
	}
	UpdatePlaceInfo()

	local StatusColor = Scope:Computed(function(Use)
		if Use(Props.InRoRooms) then
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
			States.CurrentMenu:set(nil)

			if Use(Props.InRoRooms) then
				if Use(Props.JobId) == game.JobId then
					Prompts:PushPrompt({
						Title = "Failure",
						Text = "You're already in the same server as this person.",
						Buttons = {
							{
								Contents = { "Close" },
							},
						},
					})
				else
					Prompts:PushPrompt({
						Title = "Teleport",
						Text = `Do you want to join friend in {Use(PlaceInfo).Name}?`,
						Buttons = {
							{
								Contents = { "Cancel" },
								Style = "Outlined",
							},
							{
								Contents = { "Teleport" },
								Callback = function()
									if States.Services.WorldsService then
										States.Services.WorldsService:TeleportToWorld(Use(Props.PlaceId))
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
						InviteUser = Use(Props.UserId),
					}
				)
			end
		end,
		IsHolding = IsHolding,

		[Children] = {
			Scope:Avatar {
				Size = UDim2.fromOffset(80, 80),
				BackgroundColor3 = ColorUtils.Lighten(Use(Props.Color), 0.06),
				Image = Scope:Computed(function(Use)
					return `rbxthumb://type=AvatarHeadShot&id={Use(Props.UserId)}&w=150&h=150`
				end),
				CornerRadius = Scope:Computed(function(Use)
					return UDim.new(0, Use(Theme.CornerRadius.Full))
				end),
				RingEnabled = Props.InRoRooms,
				RingColor = Colors.Green["500"],
				IndicatorEnabled = Scope:Computed(function(Use)
					return not Use(Props.InRoRooms)
				end),
				IndicatorColor = StatusColor,
			},
			Scope:Frame {
				Name = "Details",
				Size = UDim2.fromOffset(80, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				ListEnabled = true,
				ListPadding = UDim.new(0, 0),

				[Children] = {
					Scope:Text {
						Name = "DisplayName",
						Text = Props.DisplayName,
						TextTruncate = Enum.TextTruncate.AtEnd,
						Size = UDim2.fromScale(1, 0),
						AutomaticSize = Enum.AutomaticSize.Y,
						TextXAlignment = Enum.TextXAlignment.Center,
						TextWrapped = false,
					},
					Scope:Text {
						Name = "Status",
						Text = Scope:Computed(function(Use)
							return (Use(Props.InRoRooms) and Use(PlaceInfo).Name) or "Online"
						end),
						TextColor3 = StatusColor,
						TextSize = Theme.TextSize["0.875"],
						TextTruncate = Enum.TextTruncate.AtEnd,
						Size = UDim2.fromScale(1, 0),
						AutomaticSize = Enum.AutomaticSize.Y,
						TextXAlignment = Enum.TextXAlignment.Center,
						TextWrapped = false,
					},
				},
			},
		},
	}
end
