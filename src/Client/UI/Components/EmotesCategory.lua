local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent)

local Config = RoRooms.Config
local Client = RoRooms.Client

local OnyxUI = require(RoRooms.Packages.OnyxUI)
local Fusion = require(OnyxUI.Packages.Fusion)
local EnsureValue = require(OnyxUI.Utils.EnsureValue)
local States = require(Client.UI.States)
local Modifier = require(OnyxUI.Utils.Modifier)
local Themer = require(OnyxUI.Utils.Themer)

local Children = Fusion.Children
local Computed = Fusion.Computed
local ForPairs = Fusion.ForPairs

local Frame = require(OnyxUI.Components.Frame)
local Text = require(OnyxUI.Components.Text)
local Icon = require(OnyxUI.Components.Icon)
local EmoteButton = require(Client.UI.Components.EmoteButton)

return function(Props: { [any]: any })
	Props.CategoryName = EnsureValue(Props.CategoryName, "string", "General")
	Props.Name = EnsureValue(Props.Name, "string", `{Props.CategoryName:get()}EmotesCategory`)
	Props.Size = EnsureValue(Props.Size, "UDim2", UDim2.fromScale(1, 0))
	Props.AutomaticSize = EnsureValue(Props.AutomaticSize, "EnumItem", Enum.AutomaticSize.Y)
	Props.LayoutOrder = EnsureValue(Props.LayoutOrder, "number", 0)

	local Category = Computed(function()
		return Config.EmotesSystem.Categories[Props.CategoryName:get()]
	end)

	return Frame {
		Name = Props.Name,
		Size = Props.Size,
		AutomaticSize = Props.AutomaticSize,
		LayoutOrder = Props.LayoutOrder,

		[Children] = {
			Modifier.ListLayout {},

			Frame {
				Name = "Title",

				[Children] = {
					Modifier.ListLayout {
						FillDirection = Enum.FillDirection.Horizontal,
						Padding = Computed(function()
							return UDim.new(0, Themer.Theme.Spacing["0.25"]:get())
						end),
					},

					Icon {
						Image = Computed(function()
							if Category:get() and Category:get().Icon then
								return Category:get().Icon
							else
								return "rbxassetid://17266112920"
							end
						end),
						Size = Computed(function()
							return UDim2.fromOffset(Themer.Theme.TextSize["1"]:get(), Themer.Theme.TextSize["1"]:get())
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

				[Children] = {
					Modifier.ListLayout {
						Padding = Computed(function()
							return UDim.new(0, Themer.Theme.Spacing["0.5"]:get())
						end),
						FillDirection = Enum.FillDirection.Horizontal,
						Wraps = true,
					},

					ForPairs(Config.EmotesSystem.Emotes, function(EmoteId, Emote)
						local EmoteCategory = Emote.Category
						if EmoteCategory == nil then
							EmoteCategory = "General"
						end

						if EmoteCategory == Props.CategoryName:get() then
							return EmoteId,
								EmoteButton {
									EmoteId = EmoteId,
									Emote = Emote,
									BaseColor3 = Emote.TintColor,

									Callback = function()
										if States.ScreenSize:get().Y <= 500 then
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
