local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local SocialService = game:GetService("SocialService")

local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent)
local Future = require(script.Parent.Parent.Parent.Parent.Parent.Parent.Future)
local OnyxUI = require(RoRooms.Packages.OnyxUI)
local Fusion = require(OnyxUI.Parent.Fusion)
local EnsureValue = require(OnyxUI.Utils.EnsureValue)
local ColorUtils = require(OnyxUI.Parent.ColorUtils)
local States = require(RoRooms.Client.UI.States)
local Prompts = require(RoRooms.Client.UI.States.Prompts)

local Themer = require(OnyxUI.Utils.Themer)
local Colors = require(OnyxUI.Utils.Colors)

local Children = Fusion.Children
local New = Fusion.New
local Computed = Fusion.Computed
local Value = Fusion.Value
local Observer = Fusion.Observer
local Cleanup = Fusion.Cleanup

local Button = require(OnyxUI.Components.Button)
local Text = require(OnyxUI.Components.Text)
local Frame = require(OnyxUI.Components.Frame)
local Avatar = require(OnyxUI.Components.Avatar)

return function(Props)
	Props.UserId = EnsureValue(Props.UserId, "number", 1)
	Props.DisplayName = EnsureValue(Props.DisplayName, "string", "DisplayName")
	Props.PlaceId = EnsureValue(Props.PlaceId, "number", nil)
	Props.JobId = EnsureValue(Props.JobId, "string", nil)
	Props.InRoRooms = EnsureValue(Props.InRoRooms, "boolean", false)
	Props.Color = EnsureValue(Props.Color, "Color3", Themer.Theme.Colors.Base.Light)

	local IsHolding = Value(false)
	local PlaceInfo = Value({})

	local function UpdatePlaceInfo()
		if Props.PlaceId:get() == nil then
			return
		end

		Future.Try(function()
			return MarketplaceService:GetProductInfo(Props.PlaceId:get())
		end):After(function(Success, Result)
			if Success then
				PlaceInfo:set(Result)
			else
				warn(Result)
			end
		end)
	end

	local Observers = {
		Observer(Props.PlaceId):onChange(UpdatePlaceInfo),
	}
	UpdatePlaceInfo()

	local StatusColor = Computed(function()
		if Props.InRoRooms:get() then
			return Color3.fromRGB(2, 183, 87)
		else
			return Color3.fromRGB(0, 162, 255)
		end
	end)

	return Button {
		Name = "FriendButton",
		Parent = Props.Parent,
		Color = Props.Color,
		CornerRadius = Computed(function()
			return UDim.new(0, Themer.Theme.CornerRadius["2"]:get())
		end),
		ClipsDescendants = true,
		LayoutOrder = Props.LayoutOrder,
		ListEnabled = true,
		ListFillDirection = Enum.FillDirection.Vertical,
		ListHorizontalAlignment = Enum.HorizontalAlignment.Center,
		PaddingTop = Computed(function()
			return UDim.new(0, Themer.Theme.Spacing["0.75"]:get())
		end),
		PaddingBottom = Computed(function()
			return UDim.new(0, Themer.Theme.Spacing["0.75"]:get())
		end),
		PaddingLeft = Computed(function()
			return UDim.new(0, Themer.Theme.Spacing["0.75"]:get())
		end),
		PaddingRight = Computed(function()
			return UDim.new(0, Themer.Theme.Spacing["0.75"]:get())
		end),

		[Cleanup] = { Observers },

		OnActivated = function()
			States.CurrentMenu:set(nil)

			if Props.InRoRooms:get() then
				if Props.JobId:get() == game.JobId then
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
						Text = `Do you want to join friend in {PlaceInfo:get().Name}?`,
						Buttons = {
							{
								Contents = { "Cancel" },
								Style = "Outlined",
							},
							{
								Contents = { "Teleport" },
								Callback = function()
									if States.Services.WorldsService then
										States.Services.WorldsService:TeleportToWorld(Props.PlaceId:get())
									end
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
			Avatar {
				Size = UDim2.fromOffset(80, 80),
				BackgroundColor3 = ColorUtils.Lighten(Props.Color:get(), 0.06),
				Image = Computed(function()
					return `rbxthumb://type=AvatarHeadShot&id={Props.UserId:get()}&w=150&h=150`
				end),
				CornerRadius = Computed(function()
					return UDim.new(0, Themer.Theme.CornerRadius.Full:get())
				end),
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
				ListEnabled = true,
				ListPadding = UDim.new(0, 0),

				[Children] = {
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
