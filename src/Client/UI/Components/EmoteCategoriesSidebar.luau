local Rorooms = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(Rorooms.Parent.OnyxUI)
local Fusion = require(Rorooms.Parent.Fusion)
local States = require(Rorooms.SourceCode.Client.UI.States)
local Config = require(Rorooms.Config).Config

local Children = Fusion.Children
local Util = OnyxUI.Util

local CategoriesSidebar = require(script.Parent.CategoriesSidebar)
local CategoryButton = require(script.Parent.CategoryButton)

return function(Scope: Fusion.Scope<any>, Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components, {
		CategoriesSidebar = CategoriesSidebar,
		CategoryButton = CategoryButton,
	})

	local Name = Util.Fallback(Props.Name, "EmoteCategoriesSidebar")

	return Scope:CategoriesSidebar {
		Name = Name,
		Size = Props.Size,

		[Children] = {
			Scope:ForPairs(Config.Systems.Emotes.Categories, function(Use, Scope, CategoryName: string, Category)
				return CategoryName,
					Scope:CategoryButton {
						Name = "EmoteCategoryButton",
						CategoryName = CategoryName,
						Icon = Category.Icon,
						Color = Category.TintColor,
						LayoutOrder = Category.LayoutOrder,

						OnActivated = function()
							States.Menus.EmotesMenu.FocusedCategory:set(CategoryName, true)
						end,
					}
			end),
		},
	}
end
