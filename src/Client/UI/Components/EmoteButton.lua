local RoRooms = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(RoRooms.Parent.OnyxUI)
local Fusion = require(RoRooms.Parent.Fusion)
local ColorUtils = require(RoRooms.Parent.ColorUtils)
local EmotesController = require(RoRooms.SourceCode.Client.Emotes.EmotesController)
local Assets = require(RoRooms.SourceCode.Shared.Assets)

local Children = Fusion.Children
local Util = OnyxUI.Util
local Themer = OnyxUI.Themer
local Peek = Fusion.peek

local CustomButton = require(script.Parent.CustomButton)

return function(Scope: Fusion.Scope<any>, Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components, {
		CustomButton = CustomButton,
	})
	local Theme = Themer.Theme:now()

	local EmoteId = Util.Fallback(Props.EmoteId, "EmoteId")
	local Emote = Util.Fallback(Props.Emote, {})
	local Color = Util.Fallback(Props.Color, Theme.Colors.Neutral.Main)
	local LevelRequirement = Scope:Computed(function(Use)
		local EmoteValue = Use(Emote)
		if EmoteValue and EmoteValue.LevelRequirement then
			return EmoteValue.LevelRequirement
		else
			return nil
		end
	end)
	local LabelText = Scope:Computed(function(Use)
		local EmoteValue = Use(Emote)
		local LevelRequirementValue = Use(LevelRequirement)
		if EmoteValue and EmoteValue.LabelText then
			return EmoteValue.LabelText
		elseif LevelRequirementValue then
			return LevelRequirementValue
		else
			return ""
		end
	end)
	local LabelIcon = Scope:Computed(function(Use)
		local EmoteValue = Use(Emote)
		local LevelRequirementValue = Use(LevelRequirement)
		if EmoteValue and EmoteValue.LabelIcon then
			return EmoteValue.LabelIcon
		elseif LevelRequirementValue then
			return Assets.Icons.Categories.Unlockable
		else
			return ""
		end
	end)

	return Scope:CustomButton {
		Name = "EmoteButton",
		Color = Color,
		LayoutOrder = Scope:Computed(function(Use)
			return Use(Emote).LayoutOrder or 0
		end),
		ListEnabled = false,

		OnActivated = function()
			if Props.Callback then
				Props.Callback()
			end

			EmotesController:PlayEmote(Peek(EmoteId))
		end,

		[Children] = {
			Scope:Frame {
				Name = "Details",
				ListEnabled = true,
				ListFillDirection = Enum.FillDirection.Vertical,
				ListHorizontalAlignment = Enum.HorizontalAlignment.Center,
				ListPadding = Scope:Computed(function(Use)
					return UDim.new(0, Use(Theme.Spacing["0.5"]))
				end),
				PaddingTop = Scope:Computed(function(Use)
					return UDim.new(0, Use(Theme.Spacing["1"]))
				end),
				Padding = Scope:Computed(function(Use)
					return UDim.new(0, Use(Theme.Spacing["0"]))
				end),

				[Children] = {
					Scope:Text {
						Name = "Emoji",
						Text = Scope:Computed(function(Use)
							if Use(Props.Emote) and Use(Props.Emote).Emoji then
								return Use(Props.Emote).Emoji
							else
								return "🪩"
							end
						end),
						TextSize = Theme.TextSize["2.25"],
						RichText = false,
						ClipsDescendants = false,
						TextWrapped = false,
					},
					Scope:Text {
						Name = "Name",
						Text = Scope:Computed(function(Use)
							return Use(Props.Emote).Name or Use(Props.EmoteId)
						end),
						TextSize = Theme.TextSize["0.875"],
						TextTruncate = Enum.TextTruncate.AtEnd,
						AutomaticSize = Enum.AutomaticSize.None,
						TextXAlignment = Enum.TextXAlignment.Center,
						Size = Scope:Computed(function(Use)
							return UDim2.fromOffset(Use(Theme.Spacing["4"]) * 1.1, Use(Theme.TextSize["0.875"]) * 2)
						end),
					},
				},
			},
			Scope:IconText {
				Name = "Label",
				Content = Scope:Computed(function(Use)
					local LabelTextValue = Use(LabelText)
					local LabelIconValue = Use(LabelIcon)
					return { LabelIconValue, LabelTextValue }
				end),
				ContentSize = Theme.TextSize["0.75"],
				ContentColor = Scope:Computed(function(Use)
					return ColorUtils.Emphasize(Use(Color), Use(Theme.Emphasis.Strong))
				end),
				Visible = Scope:Computed(function(Use)
					local LabelTextValue = Use(LabelText)
					local LabelIconValue = Use(LabelIcon)
					return (LabelTextValue ~= nil) or (LabelIconValue ~= nil)
				end),
				ListPadding = Scope:Computed(function(Use)
					return UDim.new(0, Use(Theme.Spacing["0.25"]))
				end),
			},
		},
	}
end
