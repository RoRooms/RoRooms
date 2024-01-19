local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent)
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local SocialService = game:GetService("SocialService")

local Shared = RoRooms.Shared
local Client = RoRooms.Client

local Fusion = require(Shared.ExtPackages.NekaUI.Packages.Fusion)
local NekaUI = require(Shared.ExtPackages.NekaUI)
local EnsureProp = require(NekaUI.Utils.EnsureProp)
local ColourUtils = require(NekaUI.Packages.ColourUtils)
local States = require(Client.UI.States)

local Children = Fusion.Children
local New = Fusion.New
local Spring = Fusion.Spring
local Computed = Fusion.Computed
local Value = Fusion.Value

local BaseButton = require(NekaUI.Components.BaseButton)
local Text = require(NekaUI.Components.Text)
local Frame = require(NekaUI.Components.Frame)

return function(Props)
	Props.UserId = EnsureProp(Props.UserId, "number", 1)
	Props.DisplayName = EnsureProp(Props.DisplayName, "string", "DisplayName")
	Props.PlaceId = EnsureProp(Props.PlaceId, "number", nil)
	Props.JobId = EnsureProp(Props.JobId, "string", nil)
	Props.InRoRooms = EnsureProp(Props.InRoRooms, "boolean", false)
	Props.BaseColor3 = EnsureProp(Props.BaseColor3, "Color3", Color3.fromRGB(41, 41, 41))

	local IsHolding = Value(false)
	local PlaceInfo = Computed(function()
		if Props.PlaceId:get() then
			local Success, Result = pcall(function()
				return MarketplaceService:GetProductInfo(Props.PlaceId:get())
			end)
			if Success then
				return Result
			else
				warn(Result)
				return {}
			end
		else
			return {}
		end
	end)

	return BaseButton {
		Name = "FriendButton",
		Parent = Props.Parent,
		BackgroundColor3 = Spring(
			Computed(function()
				local BaseColor = Props.BaseColor3:get()
				if IsHolding:get() then
					return ColourUtils.Lighten(BaseColor, 0.03)
				else
					return BaseColor
				end
			end),
			35,
			1
		),
		BackgroundTransparency = 0,
		ClipsDescendants = true,
		LayoutOrder = Props.LayoutOrder,

		OnActivated = function()
			States.CurrentMenu:set(nil)

			if Props.InRoRooms:get() then
				if Props.JobId:get() == game.JobId then
					States:PushPrompt({
						Title = "Failure",
						Text = "You're already in the same server as this person.",
						Buttons = {
							{
								Primary = false,
								Contents = { "Close" },
							},
						},
					})
				else
					States:PushPrompt({
						Title = "Teleport",
						Text = `Do you want to join friend in {PlaceInfo:get().Name}?`,
						Buttons = {
							{
								Primary = false,
								Contents = { "Cancel" },
							},
							{
								Primary = true,
								Contents = { "Teleport" },
								Callback = function()
									States.WorldsService:TeleportToWorld(Props.PlaceId:get())
								end,
							},
						},
					})
				end
			else
				SocialService:PromptGameInvite(
					Players.LocalPlayer,
					New "ExperienceInviteOptions" {
						InviteUser = Props.UserId:get(),
					}
				)
			end
		end,
		IsHolding = IsHolding,

		[Children] = {
			New "UICorner" {
				CornerRadius = UDim.new(0, 10),
			},
			New "UIPadding" {
				PaddingLeft = UDim.new(0, 10),
				PaddingBottom = UDim.new(0, 10),
				PaddingTop = UDim.new(0, 10),
				PaddingRight = UDim.new(0, 10),
			},
			New "UIStroke" {
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Thickness = 2,
				Color = ColourUtils.Lighten(Props.BaseColor3:get(), 0.05),
			},
			New "UIListLayout" {
				Padding = UDim.new(0, 10),
				FillDirection = "Vertical",
				HorizontalAlignment = "Center",
				SortOrder = "LayoutOrder",
			},

			New "ImageLabel" {
				Name = "AvatarHeadshot",
				Size = UDim2.fromOffset(80, 80),
				BackgroundColor3 = ColourUtils.Lighten(Props.BaseColor3:get(), 0.06),
				Image = Computed(function()
					return `rbxthumb://type=AvatarHeadShot&id={Props.UserId:get()}&w=150&h=150`
				end),

				[Children] = {
					New "UICorner" {
						CornerRadius = UDim.new(0.5, 0),
					},
					New "UIStroke" {
						Color = Color3.fromRGB(2, 183, 87),
						Thickness = 2,
						Enabled = Props.InRoRooms,
					},
				},
			},
			Frame {
				Name = "FriendInfo",
				Size = UDim2.fromScale(1, 0),
				AutomaticSize = Enum.AutomaticSize.Y,

				[Children] = {
					New "UIListLayout" {
						Padding = UDim.new(0, 4),
					},
					Text {
						Name = "DisplayName",
						Text = Props.DisplayName,
						TextTruncate = Enum.TextTruncate.AtEnd,
						TextSize = 17,
						Size = UDim2.fromScale(1, 0),
						AutomaticSize = Enum.AutomaticSize.Y,
						TextXAlignment = Enum.TextXAlignment.Center,
					},
					Text {
						Name = "Status",
						Text = Computed(function()
							return (Props.InRoRooms:get() and PlaceInfo:get().Name) or "Online"
						end),
						TextColor3 = Computed(function()
							if Props.InRoRooms:get() then
								return Color3.fromRGB(2, 183, 87)
							else
								return Color3.fromRGB(0, 162, 255)
							end
						end),
						TextSize = 15,
						TextTruncate = Enum.TextTruncate.AtEnd,
						Size = UDim2.fromScale(1, 0),
						AutomaticSize = Enum.AutomaticSize.Y,
						TextXAlignment = Enum.TextXAlignment.Center,
					},
				},
			},
		},
	}
end
