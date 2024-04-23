local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent)

local Shared = RoRooms.Shared
local Config = RoRooms.Config
local Client = RoRooms.Client

local OnyxUI = require(Shared.ExtPackages.OnyxUI)
local Fusion = require(OnyxUI._Packages.Fusion)
local States = require(Client.UI.States)
local EnsureValue = require(OnyxUI.Utils.EnsureValue)

local ForPairs = Fusion.ForPairs
local Children = Fusion.Children

local CategoriesSidebar = require(script.Parent.CategoriesSidebar)
local CategoryButton = require(script.Parent.CategoryButton)

return function(Props)
	Props.Name = EnsureValue(Props.Name, "string", "ItemCategoriesSidebar")

	return CategoriesSidebar {
		Name = Props.Name,
		Size = Props.Size,

		[Children] = {
			ForPairs(Config.ItemsSystem.Categories, function(Name: string, Category)
				return Name,
					CategoryButton {
						Name = "ItemCategoryButton",
						Category = Name,
						Icon = Category.Icon,
						Color = Category.TintColor,

						OnActivated = function()
							States.ItemsSystem.FocusedCategory:set(Props.CategoryName:get(), true)
						end,
					}
			end, Fusion.cleanup),
		},
	}
end
