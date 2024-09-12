local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent)
local OnyxUI = require(RoRooms.Packages.OnyxUI)
local Fusion = require(RoRooms.Packages.Fusion)
local States = require(RoRooms.Client.UI.States)

local Children = Fusion.Children
local Computed = Fusion.Computed
local ForPairs = Fusion.ForPairs

local Frame = require(OnyxUI.Components.Frame)
local Text = require(OnyxUI.Components.Text)
local Icon = require(OnyxUI.Components.Icon)
local EmoteButton = require(RoRooms.Client.UI.Components.EmoteButton)

return function(Props: { [any]: any })
	Props.CategoryName = Scope:EnsureValue(Props.CategoryName, "string", "General")
	Props.Name = Scope:EnsureValue(Props.Name, "string", `{Use(Props.CategoryName)}EmotesCategory`)
	Props.Size = Scope:EnsureValue(Props.Size, "UDim2", UDim2.fromScale(1, 0))
	Props.AutomaticSize = Scope:EnsureValue(Props.AutomaticSize, "EnumItem", Enum.AutomaticSize.Y)
	Props.LayoutOrder = Scope:EnsureValue(Props.LayoutOrder, "number", 0)

	local Category = Scope:Computed(function(Use)
		return RoRooms.Config.Systems.Emotes.Categories[Use(Props.CategoryName)]
	end)

	return Frame {
		Name = Props.Name,
		Size = Props.Size,
		AutomaticSize = Props.AutomaticSize,
		LayoutOrder = Props.LayoutOrder,
		ListEnabled = true,

		[Children] = {
			Frame {
				Name = "Title",
				ListEnabled = true,
				ListFillDirection = Enum.FillDirection.Horizontal,
				ListPadding = Scope:Computed(function(Use)
					return UDim.new(0, Theme.Spacing["0.25"]:get())
				end),

				[Children] = {
					Icon {
						Image = Scope:Computed(function(Use)
							if Use(Category) and Use(Category).Icon then
								return Use(Category).Icon
							else
								return "rbxassetid://17266112920"
							end
						end),
						Size = Scope:Computed(function(Use)
							return UDim2.fromOffset(Theme.TextSize["1"]:get(), Theme.TextSize["1"]:get())
						end),
					},
					Text {
						Text = Props.CategoryName,
					},
				},
			},
			Frame {
				Name = "Emotes",
				Size = UDim2.fromScale(1, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				ListEnabled = true,
				ListPadding = Scope:Computed(function(Use)
					return UDim.new(0, Theme.Spacing["0.75"]:get())
				end),
				ListFillDirection = Enum.FillDirection.Horizontal,
				ListWraps = true,

				[Children] = {
					Scope:ForPairs(RoRooms.Config.Systems.Emotes.Emotes, function(EmoteId, Emote)
						local EmoteCategory = Emote.Category
						if EmoteCategory == nil then
							EmoteCategory = "General"
						end

						if EmoteCategory == Use(Props.CategoryName) then
							return EmoteId,
								EmoteButton {
									EmoteId = EmoteId,
									Emote = Emote,
									Color = Emote.TintColor,

									Callback = function()
										if Use(States.ScreenSize).Y <= 500 then
											States.CurrentMenu:set()
										end
									end,
								}
						else
							return EmoteId, nil
						end
					end, Fusion.cleanup),
				},
			},
		},
	}
end
