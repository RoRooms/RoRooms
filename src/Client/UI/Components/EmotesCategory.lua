local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent)

local Shared = RoRooms.Shared
local Config = RoRooms.Config
local Client = RoRooms.Client

local Fusion = require(Shared.ExtPackages.OnyxUI.Packages.Fusion)
local OnyxUI = require(Shared.ExtPackages.OnyxUI)
local EnsureValue = require(OnyxUI.Utils.EnsureValue)
local States = require(Client.UI.States)
local Modifier = require(OnyxUI.Utils.Modifier)
local Themer = require(OnyxUI.Utils.Themer)

local Children = Fusion.Children
local Computed = Fusion.Computed

local Frame = require(OnyxUI.Components.Frame)
local Text = require(OnyxUI.Components.Text)
local EmoteButton = require(Client.UI.Components.EmoteButton)

return function(Props: { [any]: any })
	Props.CategoryName = EnsureValue(Props.CategoryName, "string", "Category")

	local Category = Computed(function()
		return Config.EmotesSystem.Categories[Props.CategoryName:get()]
	end)

	local EmoteButtons = Computed(function()
		local List = {}

		for EmoteId, Emote in pairs(Config.EmotesSystem.Emotes) do
			if Emote.Category == nil then
				Emote.Category = "General"
			end
			if Emote.Category == Props.CategoryName:get() then
				table.insert(
					List,
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
				)
			end
		end

		return List
	end, Fusion.cleanup)

	return Frame {
		Name = `{Props.CategoryName:get()}EmotesCategory`,
		Size = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = Computed(function()
			if Category:get() then
				return Category:get().LayoutOrder
			else
				return 0
			end
		end),

		[Children] = {
			Modifier.ListLayout {},

			Text {
				Text = Props.CategoryName,
				TextSize = 20,
			},
			Frame {
				Name = "Emotes",
				Size = UDim2.fromScale(1, 0),
				AutomaticSize = Enum.AutomaticSize.Y,

				[Children] = {
					Modifier.ListLayout {
						Padding = Computed(function()
							return UDim.new(0, Themer.Theme.Spacing["0.75"]:get())
						end),
						FillDirection = Enum.FillDirection.Horizontal,
						Wraps = true,
					},

					EmoteButtons,
				},
			},
		},
	}
end
