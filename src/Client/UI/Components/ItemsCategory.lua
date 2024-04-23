local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent)
local Modifier = require(script.Parent.Parent.Parent.Parent.Shared.ExtPackages.OnyxUI.Packages.OnyxUI.Utils.Modifier)

local Shared = RoRooms.Shared
local Config = RoRooms.Config
local Client = RoRooms.Client

local Fusion = require(Shared.ExtPackages.OnyxUI.Packages.Fusion)
local OnyxUI = require(Shared.ExtPackages.OnyxUI)
local EnsureValue = require(OnyxUI.Utils.EnsureValue)

local Children = Fusion.Children
local New = Fusion.New
local Computed = Fusion.Computed
local ForPairs = Fusion.ForPairs

local Frame = require(OnyxUI.Components.Frame)
local Text = require(OnyxUI.Components.Text)
local ItemButton = require(Client.UI.Components.ItemButton)

return function(Props: { [any]: any })
	Props.CategoryName = EnsureValue(Props.CategoryName, "string", "Category")

	local Category = Computed(function()
		return Config.ItemsSystem.Categories[Props.CategoryName:get()]
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
			Text {
				Text = Props.CategoryName,
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

					ForPairs(Config.ItemsSystem.Items, function(ItemId, Item)
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
