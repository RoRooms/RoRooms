local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent)
local OnyxUI = require(RoRooms.Packages.OnyxUI)
local Fusion = require(RoRooms.Packages.Fusion)

local Children = Fusion.Children
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
		ListEnabled = true,
		ListPadding = Computed(function()
			return UDim.new(0, Theme.Spacing["0.75"]:get())
		end),

		[Children] = {
			Frame {
				Name = "Title",
				ListEnabled = true,
				ListFillDirection = Enum.FillDirection.Horizontal,
				ListPadding = Computed(function()
					return UDim.new(0, Theme.Spacing["0.25"]:get())
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
							return UDim2.fromOffset(Theme.TextSize["1"]:get(), Theme.TextSize["1"]:get())
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
				ListEnabled = true,
				ListWraps = true,
				ListFillDirection = Enum.FillDirection.Horizontal,
				ListPadding = Computed(function()
					return UDim.new(0, Theme.Spacing["0.75"]:get())
				end),

				[Children] = {
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
									Color = Item.TintColor,
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
