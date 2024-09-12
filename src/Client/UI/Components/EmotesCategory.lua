local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent)
local OnyxUI = require(RoRooms.Packages.OnyxUI)
local Fusion = require(RoRooms.Packages.Fusion)
local EnsureValue = require(OnyxUI.Utils.EnsureValue)
local States = require(RoRooms.Client.UI.States)

local Themer = require(OnyxUI.Utils.Themer)

local Children = Fusion.Children
local Computed = Fusion.Computed
local ForPairs = Fusion.ForPairs

local Frame = require(OnyxUI.Components.Frame)
local Text = require(OnyxUI.Components.Text)
local Icon = require(OnyxUI.Components.Icon)
local EmoteButton = require(RoRooms.Client.UI.Components.EmoteButton)

return function(Props: { [any]: any })
	Props.CategoryName = EnsureValue(Props.CategoryName, "string", "General")
	Props.Name = EnsureValue(Props.Name, "string", `{Props.CategoryName:get()}EmotesCategory`)
	Props.Size = EnsureValue(Props.Size, "UDim2", UDim2.fromScale(1, 0))
	Props.AutomaticSize = EnsureValue(Props.AutomaticSize, "EnumItem", Enum.AutomaticSize.Y)
	Props.LayoutOrder = EnsureValue(Props.LayoutOrder, "number", 0)

	local Category = Computed(function()
		return RoRooms.Config.Systems.Emotes.Categories[Props.CategoryName:get()]
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
				ListPadding = Computed(function()
					return UDim.new(0, Themer.Theme.Spacing["0.25"]:get())
				end),

				[Children] = {
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
				ListEnabled = true,
				ListPadding = Computed(function()
					return UDim.new(0, Themer.Theme.Spacing["0.75"]:get())
				end),
				ListFillDirection = Enum.FillDirection.Horizontal,
				ListWraps = true,

				[Children] = {
					ForPairs(RoRooms.Config.Systems.Emotes.Emotes, function(EmoteId, Emote)
						local EmoteCategory = Emote.Category
						if EmoteCategory == nil then
							EmoteCategory = "General"
						end

						if EmoteCategory == Props.CategoryName:get() then
							return EmoteId,
								EmoteButton {
									EmoteId = EmoteId,
									Emote = Emote,
									Color = Emote.TintColor,

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
