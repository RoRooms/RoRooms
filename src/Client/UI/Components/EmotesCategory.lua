local RoRooms = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(RoRooms.Parent.OnyxUI)
local Fusion = require(RoRooms.Parent.Fusion)
local States = require(RoRooms.SourceCode.Client.UI.States)
local Config = require(RoRooms.Config).Config
local Assets = require(RoRooms.SourceCode.Shared.Assets)

local Children = Fusion.Children
local Util = OnyxUI.Util
local Themer = OnyxUI.Themer

local EmoteButton = require(RoRooms.SourceCode.Client.UI.Components.EmoteButton)

return function(Scope: Fusion.Scope<any>, Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components, {
		EmoteButton = EmoteButton,
	})
	local Theme = Themer.Theme:now()

	local CategoryName = Util.Fallback(Props.CategoryName, "General")
	local Name = Util.Fallback(Props.Name, script.Name)
	local LayoutOrder = Util.Fallback(Props.LayoutOrder, 0)

	local Category = Scope:Computed(function(Use)
		return Config.Systems.Emotes.Categories[Use(CategoryName)]
	end)

	return Scope:Frame {
		Name = Name,
		LayoutOrder = LayoutOrder,
		ListEnabled = true,
		ListHorizontalFlex = Enum.UIFlexAlignment.Fill,

		[Children] = {
			Scope:Frame {
				Name = "Title",
				ListEnabled = true,
				ListFillDirection = Enum.FillDirection.Horizontal,
				ListPadding = Scope:Computed(function(Use)
					return UDim.new(0, Use(Theme.Spacing["0.25"]))
				end),

				[Children] = {
					Scope:Icon {
						Image = Scope:Computed(function(Use)
							local CategoryValue = Use(Category)
							local CategoryNameValue = Use(CategoryName)
							local DefaultIcon = Assets.Icons.Categories[CategoryNameValue]

							if CategoryValue and Use(Category).Icon then
								return Use(Category).Icon
							elseif DefaultIcon then
								return DefaultIcon
							else
								return Assets.Icons.Categories.General
							end
						end),
						Size = Scope:Computed(function(Use)
							return UDim2.fromOffset(Use(Theme.TextSize["1"]), Use(Theme.TextSize["1"]))
						end),
					},
					Scope:Text {
						Text = CategoryName,
						TextWrapped = false,
					},
				},
			},
			Scope:Frame {
				Name = "Emotes",
				AutomaticSize = Enum.AutomaticSize.Y,
				ListEnabled = true,
				ListPadding = Scope:Computed(function(Use)
					return UDim.new(0, Use(Theme.Spacing["0.75"]))
				end),
				ListFillDirection = Enum.FillDirection.Horizontal,
				ListWraps = true,

				[Children] = {
					Scope:ForPairs(Config.Systems.Emotes.Emotes, function(Use, Scope, EmoteId, Emote)
						local EmoteCategory = Emote.Category
						if EmoteCategory == nil then
							EmoteCategory = "General"
						end

						if EmoteCategory == Use(CategoryName) then
							return EmoteId,
								Scope:EmoteButton {
									EmoteId = EmoteId,
									Emote = Emote,
									Color = Emote.TintColor,
									LayoutOrder = Scope:Computed(function(Use)
										if Emote then
											if Emote.LevelRequirement then
												return Emote.LevelRequirement
											elseif Emote.DisplayName then
												return string.byte(Emote.DisplayName)
											end
										end

										return 0
									end),

									Callback = function()
										if Use(States.CoreGui.ScreenSize).Y <= 500 then
											States.Menus.CurrentMenu:set()
										end
									end,
								}
						else
							return EmoteId, nil
						end
					end),
				},
			},
		},
	}
end
