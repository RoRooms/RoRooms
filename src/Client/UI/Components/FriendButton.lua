local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local SocialService = game:GetService("SocialService")

local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent)
local OnyxUI = require(RoRooms.Packages.OnyxUI)
local Fusion = require(OnyxUI.Packages.Fusion)
local EnsureValue = require(OnyxUI.Utils.EnsureValue)
local ColourUtils = require(OnyxUI.Packages.ColourUtils)
local States = require(RoRooms.Client.UI.States)
local Prompts = require(RoRooms.Client.UI.States.Prompts)
local Modifier = require(OnyxUI.Utils.Modifier)
local Themer = require(OnyxUI.Utils.Themer)
local Colors = require(OnyxUI.Utils.Colors)

local Children = Fusion.Children
local New = Fusion.New
local Spring = Fusion.Spring
local Computed = Fusion.Computed
local Value = Fusion.Value

local BaseButton = require(OnyxUI.Components.BaseButton)
local Text = require(OnyxUI.Components.Text)
local Frame = require(OnyxUI.Components.Frame)
local Avatar = require(OnyxUI.Components.Avatar)

return function(Props)
	Props.UserId = EnsureValue(Props.UserId, "number", 1)
	Props.DisplayName = EnsureValue(Props.DisplayName, "string", "DisplayName")
	Props.PlaceId = EnsureValue(Props.PlaceId, "number", nil)
	Props.JobId = EnsureValue(Props.JobId, "string", nil)
	Props.InRoRooms = EnsureValue(Props.InRoRooms, "boolean", false)
	Props.BaseColor3 = EnsureValue(Props.BaseColor3, "Color3", Themer.Theme.Colors.Base.Light)

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
	local StatusColor = Computed(function()
		if Props.InRoRooms:get() then
			return Color3.fromRGB(2, 183, 87)
		else
			return Color3.fromRGB(0, 162, 255)
		end
	end)

	return BaseButton {
		Name = "FriendButton",
		Parent = Props.Parent,
		BackgroundColor3 = Spring(
			Computed(function()
				local BaseColor = Props.BaseColor3:get()
				if IsHolding:get() then
					return ColourUtils.Lighten(BaseColor, 0.05)
				else
					return BaseColor
				end
			end),
			Themer.Theme.SpringSpeed["1"],
			Themer.Theme.SpringDampening
		),
		BackgroundTransparency = 0,
		ClipsDescendants = true,
		LayoutOrder = Props.LayoutOrder,

		OnActivated = function()
			States.CurrentMenu:set(nil)

			if Props.InRoRooms:get() then
				if Props.JobId:get() == game.JobId then
					Prompts:PushPrompt({
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
					Prompts:PushPrompt({
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
			Modifier.Corner {
				CornerRadius = Computed(function()
					return UDim.new(0, Themer.Theme.CornerRadius["2"]:get())
				end),
			},
			Modifier.Padding {
				Padding = Computed(function()
					return UDim.new(0, Themer.Theme.Spacing["0.75"]:get())
				end),
			},
			Modifier.ListLayout {
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
			},
			Modifier.Stroke {
				Color = Themer.Theme.Colors.Neutral.Main,
			},

			Avatar {
				Size = UDim2.fromOffset(80, 80),
				BackgroundColor3 = ColourUtils.Lighten(Props.BaseColor3:get(), 0.06),
				Image = Computed(function()
					return `rbxthumb://type=AvatarHeadShot&id={Props.UserId:get()}&w=150&h=150`
				end),
				CornerRadius = Themer.Theme.CornerRadius.Full,
				RingEnabled = Props.InRoRooms,
				RingColor = Colors.Green["500"],
				IndicatorEnabled = Computed(function()
					return not Props.InRoRooms:get()
				end),
				IndicatorColor = StatusColor,
			},
			Frame {
				Name = "Details",
				Size = UDim2.fromOffset(80, 0),
				AutomaticSize = Enum.AutomaticSize.Y,

				[Children] = {
					Modifier.ListLayout {
						Padding = UDim.new(0, 0),
					},

					Text {
						Name = "DisplayName",
						Text = Props.DisplayName,
						TextTruncate = Enum.TextTruncate.AtEnd,
						Size = UDim2.fromScale(1, 0),
						AutomaticSize = Enum.AutomaticSize.Y,
						TextXAlignment = Enum.TextXAlignment.Center,
						TextWrapped = false,
					},
					Text {
						Name = "Status",
						Text = Computed(function()
							return (Props.InRoRooms:get() and PlaceInfo:get().Name) or "Online"
						end),
						TextColor3 = StatusColor,
						TextSize = Themer.Theme.TextSize["0.875"],
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
