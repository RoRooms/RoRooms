local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent)
local OnyxUI = require(RoRooms.Packages.OnyxUI)
local Fusion = require(OnyxUI.Parent.Fusion)
local EnsureValue = require(OnyxUI.Utils.EnsureValue)
local Themer = require(OnyxUI.Utils.Themer)
local Modifier = require(OnyxUI.Utils.Modifier)

local Children = Fusion.Children
local New = Fusion.New
local Computed = Fusion.Computed
local ForPairs = Fusion.ForPairs

local Frame = require(OnyxUI.Components.Frame)
local Text = require(OnyxUI.Components.Text)
local Icon = require(OnyxUI.Components.Icon)
local ItemButton = require(RoRooms.Client.UI.Components.ItemButton)

return function(Props: { [any]: any })
	Props.CategoryName = EnsureValue(Props.CategoryName, "string", "Category")

	local Category = Computed(function()
		return RoRooms.Config.Systems.Items.Categories[Props.CategoryName:get()]
	end)

	return Frame {
		Name = `{Props.CategoryName:get()}ItemsCategory`,
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
			New "UIListLayout" {
				Padding = UDim.new(0, 8),
				SortOrder = Enum.SortOrder.LayoutOrder,
			},

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
				Name = "Items",
				Size = UDim2.fromScale(1, 0),
				AutomaticSize = Enum.AutomaticSize.Y,

				[Children] = {
					Modifier.ListLayout {
						Wraps = true,
						FillDirection = Enum.FillDirection.Horizontal,
					},

					ForPairs(RoRooms.Config.Systems.Items.Items, function(ItemId, Item)
						local ItemCategory = Item.Category
						if ItemCategory == nil then
							ItemCategory = "General"
						end

						if ItemCategory == Props.CategoryName:get() then
							return ItemId,
								ItemButton {
									ItemId = ItemId,
									Item = Item,
									BaseColor3 = Item.TintColor,
								}
						else
							return ItemId, nil
						end
					end, Fusion.cleanup),
				},
			},
		},
	}
end
