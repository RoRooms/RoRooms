local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent)
local OnyxUI = require(RoRooms.Packages.OnyxUI)
local Fusion = require(RoRooms.Packages.Fusion)
local States = require(RoRooms.Client.UI.States)

local Children = Fusion.Children

local CategoriesSidebar = require(script.Parent.CategoriesSidebar)
local CategoryButton = require(script.Parent.CategoryButton)

return function(Scope: Fusion.Scope<any>, Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components)
	local Theme = Themer.Theme:now()

	local Name = Scope:EnsureValue(Props.Name, "EmoteCategoriesSidebar")

	return Scope:CategoriesSidebar {
		Name = Props.Name,
		Size = Props.Size,

		[Children] = {
			Scope:ForPairs(RoRooms.Config.Systems.Emotes.Categories, function(CategoryName: string, Category)
				return CategoryName,
					Scope:CategoryButton {
						Name = "EmoteCategoryButton",
						Category = CategoryName,
						Icon = Category.Icon,
						Color = Category.TintColor,
						LayoutOrder = Category.LayoutOrder,

						OnActivated = function()
							States.EmotesMenu.FocusedCategory:set(CategoryName, true)
						end,
					}
			end),
		},
	}
end
