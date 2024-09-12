local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent)
local OnyxUI = require(RoRooms.Packages.OnyxUI)
local Fusion = require(RoRooms.Packages.Fusion)
local States = require(RoRooms.Client.UI.States)
local ColorUtils = require(RoRooms.Packages.ColorUtils)

local Children = Fusion.Children
local Util = OnyxUI.Util
local Themer = OnyxUI.Themer
local Peek = Fusion.peek

local CustomButton = require(script.Parent.CustomButton)

return function(Scope: Fusion.Scope<any>, Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components)
	local Theme = Themer.Theme:now()

	local EmoteId = Util.Fallback(Props.EmoteId, "EmoteId")
	local Emote = Util.Fallback(Props.Emote, {})
	local Color = Util.Fallback(Props.Color, Theme.Util.Colors.Neutral.Main)

	local IsHolding = Scope:Value(false)

	return Scope:CustomButton {
		Name = "EmoteButton",
		Size = UDim2.fromOffset(70, 70),
		AutomaticSize = Enum.AutomaticSize.None,
		LayoutOrder = Scope:Computed(function(Use)
			return Use(Emote).LayoutOrder or 0
		end),
		ListEnabled = false,

		OnActivated = function()
			if Props.Callback then
				Props.Callback()
			end
			if States.Controllers.EmotesController then
				States.Controllers.EmotesController:PlayEmote(Peek(EmoteId))
			end
		end,
		IsHolding = IsHolding,

		[Children] = {
			Scope:Text {
				Name = "Emoji",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.45),
				Text = Scope:Computed(function(Use)
					if Use(Props.Emote) and Use(Props.Emote).Emoji then
						return Use(Props.Emote).Emoji
					else
						return "🪩"
					end
				end),
				TextSize = Theme.TextSize["1.875"],
				LayoutOrder = 1,
				RichText = false,
				ClipsDescendants = false,
			},
			Scope:Text {
				Name = "EmoteName",
				LayoutOrder = 3,
				AnchorPoint = Vector2.new(0.5, 1),
				Position = UDim2.fromScale(0.5, 1),
				Size = UDim2.fromScale(1, 0),
				Text = Scope:Computed(function(Use)
					return Use(Props.Emote).Name or Use(Props.EmoteId)
				end),
				TextSize = Theme.TextSize["0.875"],
				TextTruncate = Enum.TextTruncate.AtEnd,
				AutomaticSize = Enum.AutomaticSize.Y,
				TextXAlignment = Enum.TextXAlignment.Center,
				TextWrapped = false,
			},
			Scope:Frame {
				Name = "Label",
				ZIndex = 2,
				ListEnabled = true,
				ListFillDirection = Enum.FillDirection.Horizontal,

				[Children] = {
					Scope:Icon {
						Name = "LabelIcon",
						AnchorPoint = Vector2.new(0, 0),
						Position = UDim2.fromScale(0, 0),
						Size = UDim2.fromOffset(13, 13),
						Image = Scope:Computed(function(Use)
							local LabelIcon = Use(Props.Emote).LabelIcon
							local LevelRequirement = Use(Props.Emote).LevelRequirement
							if LabelIcon then
								return LabelIcon
							elseif LevelRequirement then
								return "rbxassetid://5743022869"
							else
								return ""
							end
						end),
						ImageColor3 = Scope:Computed(function(Use)
							return ColorUtils.Lighten(Use(Color), 0.25)
						end),
					},
					Scope:Text {
						Name = "LabelText",
						AnchorPoint = Vector2.new(0, 0),
						Position = UDim2.fromScale(0, 0),
						Text = Scope:Computed(function(Use)
							local LabelText = Use(Emote).LabelText
							local LevelRequirement = Use(Emote).LevelRequirement
							if LabelText then
								return LabelText
							elseif LevelRequirement then
								return LevelRequirement
							else
								return ""
							end
						end),
						TextSize = 13,
						TextColor3 = Scope:Computed(function(Use)
							return ColorUtils.Lighten(Use(Props.Color), 0.5)
						end),
						ClipsDescendants = false,
						AutoLocalize = false,
					},
				},
			},
		},
	}
end
