local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent)
local OnyxUI = require(RoRooms.Packages.OnyxUI)
local Fusion = require(OnyxUI.Parent.Fusion)
local EnsureValue = require(OnyxUI.Utils.EnsureValue)
local States = require(RoRooms.Client.UI.States)
local ColorUtils = require(OnyxUI.Parent.ColorUtils)

local Themer = require(OnyxUI.Utils.Themer)

local Children = Fusion.Children
local Spring = Fusion.Spring
local Computed = Fusion.Computed
local Value = Fusion.Value

local BaseButton = require(OnyxUI.Components.BaseButton)
local Text = require(OnyxUI.Components.Text)
local Icon = require(OnyxUI.Components.Icon)
local Frame = require(OnyxUI.Components.Frame)

return function(Props)
	Props.EmoteId = EnsureValue(Props.EmoteId, "string", "EmoteId")
	Props.Emote = EnsureValue(Props.Emote, "table", {})
	Props.BaseColor3 = EnsureValue(Props.BaseColor3, "Color3", Themer.Theme.Colors.Base.Light)

	local IsHolding = Value(false)

	return BaseButton {
		Name = "EmoteButton",
		BackgroundColor3 = Spring(
			Computed(function()
				if IsHolding:get() then
					return ColorUtils.Lighten(Props.BaseColor3:get(), 0.05)
				else
					return Props.BaseColor3:get()
				end
			end),
			Themer.Theme.SpringSpeed["1"],
			Themer.Theme.SpringDampening
		),
		BackgroundTransparency = 0,
		Size = UDim2.fromOffset(70, 70),
		AutomaticSize = Enum.AutomaticSize.None,
		ClipsDescendants = true,
		LayoutOrder = Computed(function()
			return Props.Emote:get().LayoutOrder or 0
		end),
		CornerRadius = Computed(function()
			return UDim.new(0, Themer.Theme.CornerRadius["2"]:get())
		end),
		Padding = Computed(function()
			return UDim.new(0, Themer.Theme.Spacing["0.5"]:get())
		end),
		StrokeEnabled = true,
		StrokeColor = Computed(function()
			return ColorUtils.Lighten(Props.BaseColor3:get(), 0.2)
		end),

		OnActivated = function()
			if Props.Callback then
				Props.Callback()
			end
			if States.Controllers.EmotesController then
				States.Controllers.EmotesController:PlayEmote(Props.EmoteId:get())
			end
		end,
		IsHolding = IsHolding,

		[Children] = {
			Text {
				Name = "Emoji",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.45),
				Text = Computed(function()
					if Props.Emote:get() and Props.Emote:get().Emoji then
						return Props.Emote:get().Emoji
					else
						return "🪩"
					end
				end),
				TextSize = Themer.Theme.TextSize["1.875"],
				LayoutOrder = 1,
				RichText = false,
				ClipsDescendants = false,
			},
			Text {
				Name = "EmoteName",
				LayoutOrder = 3,
				AnchorPoint = Vector2.new(0.5, 1),
				Position = UDim2.fromScale(0.5, 1),
				Size = UDim2.fromScale(1, 0),
				Text = Computed(function()
					return Props.Emote:get().Name or Props.EmoteId:get()
				end),
				TextSize = Themer.Theme.TextSize["0.875"],
				TextTruncate = Enum.TextTruncate.AtEnd,
				AutomaticSize = Enum.AutomaticSize.Y,
				TextXAlignment = Enum.TextXAlignment.Center,
				TextWrapped = false,
			},
			Frame {
				Name = "Label",
				ZIndex = 2,
				ListEnabled = true,
				ListFillDirection = Enum.FillDirection.Horizontal,

				[Children] = {
					Icon {
						Name = "LabelIcon",
						AnchorPoint = Vector2.new(0, 0),
						Position = UDim2.fromScale(0, 0),
						Size = UDim2.fromOffset(13, 13),
						Image = Computed(function()
							local LabelIcon = Props.Emote:get().LabelIcon
							local LevelRequirement = Props.Emote:get().LevelRequirement
							if LabelIcon then
								return LabelIcon
							elseif LevelRequirement then
								return "rbxassetid://5743022869"
							else
								return ""
							end
						end),
						ImageColor3 = Computed(function()
							return ColorUtils.Lighten(Props.BaseColor3:get(), 0.25)
						end),
					},
					Text {
						Name = "LabelText",
						AnchorPoint = Vector2.new(0, 0),
						Position = UDim2.fromScale(0, 0),
						Text = Computed(function()
							local LabelText = Props.Emote:get().LabelText
							local LevelRequirement = Props.Emote:get().LevelRequirement
							if LabelText then
								return LabelText
							elseif LevelRequirement then
								return LevelRequirement
							else
								return ""
							end
						end),
						TextSize = 13,
						TextColor3 = Computed(function()
							return ColorUtils.Lighten(Props.BaseColor3:get(), 0.5)
						end),
						ClipsDescendants = false,
						AutoLocalize = false,
					},
				},
			},
		},
	}
end
