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
local Util = OnyxUI.Util
local Themer = OnyxUI.Themer
local Peek = Fusion.peek

local CustomButton = require(RoRooms.Client.UI.Components.CustomButton)

return function(Scope: Fusion.Scope<any>, Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components)
	local Theme = Themer.Theme:now()

	local UserId = Util.Fallback(Props.UserId, 1)
	local DisplayName = Util.Fallback(Props.DisplayName, "DisplayName")
	local PlaceId = Util.Fallback(Props.PlaceId, nil)
	local JobId = Util.Fallback(Props.JobId, nil)
	local InRoRooms = Util.Fallback(Props.InRoRooms, false)
	local Color = Util.Fallback(Props.Color, Theme.Util.Colors.Neutral.Main)

	local IsHolding = Scope:Value(false)
	local PlaceInfo = Scope:Value({})

	local function UpdatePlaceInfo()
		if Peek(Props.PlaceId) == nil then
			return
		end

		Future.Try(function()
			return MarketplaceService:GetProductInfo(Peek(Props.PlaceId))
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

			if Peek(Props.InRoRooms) then
				if Peek(Props.JobId) == game.JobId then
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
						Text = `Do you want to join friend in {Peek(PlaceInfo).Name}?`,
						Buttons = {
							{
								Contents = { "Cancel" },
								Style = "Outlined",
							},
							{
								Contents = { "Teleport" },
								Callback = function()
									if States.Services.WorldsService then
										States.Services.WorldsService:TeleportToWorld(Peek(Props.PlaceId))
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
						InviteUser = Peek(Props.UserId),
					}
				)
			end
		end,
		IsHolding = IsHolding,

		[Children] = {
			Scope:Avatar {
				Size = UDim2.fromOffset(80, 80),
				BackgroundColor3 = Scope:Computed(function(Use)
					return ColorUtils.Lighten(Use(Props.Color), 0.06)
				end),
				Image = Scope:Computed(function(Use)
					return `rbxthumb://type=AvatarHeadShot&id={Use(Props.UserId)}&w=150&h=150`
				end),
				CornerRadius = Scope:Computed(function(Use)
					return UDim.new(0, Use(Theme.CornerRadius.Full))
				end),
				RingEnabled = Props.InRoRooms,
				RingColor = Util.Colors.Green["500"],
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
