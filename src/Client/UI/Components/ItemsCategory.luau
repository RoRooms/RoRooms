local Rorooms = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(Rorooms.Parent.OnyxUI)
local Fusion = require(Rorooms.Parent.Fusion)
local Config = require(Rorooms.Config).Config
local Assets = require(Rorooms.SourceCode.Shared.Assets)

local Children = Fusion.Children
local Util = OnyxUI.Util
local Themer = OnyxUI.Themer
local Peek = Fusion.peek

local ItemButton = require(Rorooms.SourceCode.Client.UI.Components.ItemButton)

return function(Scope: Fusion.Scope<any>, Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components, {
		ItemButton = ItemButton,
	})
	local Theme = Themer.Theme:now()

	local Name = Util.Fallback(Props.Name, script.Name)
	local CategoryName = Util.Fallback(Props.CategoryName, "Category")

	local Category = Scope:Computed(function(Use)
		return Config.Systems.Items.Categories[Use(CategoryName)]
	end)

	return Scope:Frame {
		Name = Name,
		LayoutOrder = Scope:Computed(function(Use)
			if Use(Category) then
				return Use(Category).LayoutOrder
			else
				return 0
			end
		end),
		ListEnabled = true,
		ListPadding = Scope:Computed(function(Use)
			return UDim.new(0, Use(Theme.Spacing["0.75"]))
		end),
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
				Name = "Items",
				ListEnabled = true,
				ListWraps = true,
				ListFillDirection = Enum.FillDirection.Horizontal,
				ListPadding = Scope:Computed(function(Use)
					return UDim.new(0, Use(Theme.Spacing["0.75"]))
				end),
				Padding = Scope:Computed(function(Use)
					return UDim.new(0, Use(Theme.StrokeThickness["1"]))
				end),

				[Children] = {
					Scope:ForPairs(Config.Systems.Items.Items, function(Use, Scope, ItemId, Item)
						local ItemCategory = Item.Category
						if ItemCategory == nil then
							ItemCategory = "General"
						end

						if ItemCategory == Peek(CategoryName) then
							return ItemId,
								Scope:ItemButton {
									ItemId = ItemId,
									Item = Item,
									Color = Item.TintColor,
									LayoutOrder = Scope:Computed(function(Use)
										if Item then
											if Item.LevelRequirement then
												return Item.LevelRequirement
											elseif Item.DisplayName then
												return string.byte(Item.DisplayName)
											end
										end

										return 0
									end),
								}
						else
							return ItemId, nil
						end
					end),
				},
			},
		},
	}
end
