local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent)
local OnyxUI = require(RoRooms.Packages.OnyxUI)
local Fusion = require(OnyxUI.Packages.Fusion)
local States = require(RoRooms.Client.UI.States)
local EnsureValue = require(OnyxUI.Utils.EnsureValue)

local ForPairs = Fusion.ForPairs
local Children = Fusion.Children

local CategoriesSidebar = require(script.Parent.CategoriesSidebar)
local CategoryButton = require(script.Parent.CategoryButton)

return function(Props)
	Props.Name = EnsureValue(Props.Name, "string", "EmoteCategoriesSidebar")

	return CategoriesSidebar {
		Name = Props.Name,
		Size = Props.Size,

		[Children] = {
			ForPairs(RoRooms.Config.Systems.Emotes.Categories, function(CategoryName: string, Category)
				return CategoryName,
					CategoryButton {
						Name = "EmoteCategoryButton",
						Category = CategoryName,
						Icon = Category.Icon,
						Color = Category.TintColor,
						LayoutOrder = Category.LayoutOrder,

						OnActivated = function()
							States.EmotesMenu.FocusedCategory:set(CategoryName, true)
						end,
					}
			end, Fusion.cleanup),
		},
	}
end
