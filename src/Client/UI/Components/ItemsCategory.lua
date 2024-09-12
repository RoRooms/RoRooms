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
	Props.CategoryName = Scope:EnsureValue(Props.CategoryName, "string", "Category")

	local Category = Scope:Computed(function(Use)
		return RoRooms.Config.Systems.Items.Categories[Use(Props.CategoryName)]
	end)

	return Frame {
		Name = `{Use(Props.CategoryName)}ItemsCategory`,
		Size = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = Scope:Computed(function(Use)
			if Use(Category) then
				return Use(Category).LayoutOrder
			else
				return 0
			end
		end),
		ListEnabled = true,
		ListPadding = Scope:Computed(function(Use)
			return UDim.new(0, Theme.Spacing["0.75"]:get())
		end),

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
				Name = "Items",
				Size = UDim2.fromScale(1, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				ListEnabled = true,
				ListWraps = true,
				ListFillDirection = Enum.FillDirection.Horizontal,
				ListPadding = Scope:Computed(function(Use)
					return UDim.new(0, Theme.Spacing["0.75"]:get())
				end),

				[Children] = {
					Scope:ForPairs(RoRooms.Config.Systems.Items.Items, function(ItemId, Item)
						local ItemCategory = Item.Category
						if ItemCategory == nil then
							ItemCategory = "General"
						end

						if ItemCategory == Use(Props.CategoryName) then
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
