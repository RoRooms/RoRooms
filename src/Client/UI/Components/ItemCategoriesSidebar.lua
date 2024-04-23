local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent)

local Shared = RoRooms.Shared
local Client = RoRooms.Client
local Config = RoRooms.Config

local OnyxUI = require(Shared.ExtPackages.OnyxUI)
local Fusion = require(OnyxUI._Packages.Fusion)
local Modifier = require(OnyxUI.Utils.Modifier)
local Themer = require(OnyxUI.Utils.Themer)

local Children = Fusion.Children
local Computed = Fusion.Computed

local ScrollingFrame = require(OnyxUI.Components.ScrollingFrame)
local ItemCategoryButton = require(Client.UI.Components.ItemCategoryButton)

return function(Props: { [any]: any })
	return ScrollingFrame {
		Name = "ItemCategoriesSidebar",
		Size = Props.Size,

		[Children] = {
			Modifier.ListLayout {},
			Modifier.Padding {
				Padding = Computed(function()
					return UDim.new(0, Themer.Theme.StrokeThickness["1"]:get())
				end),
			},

			Computed(function()
				local Categories = {}
				for CategoryName, _ in Config.ItemsSystem.Categories do
					table.insert(
						Categories,
						ItemCategoryButton {
							CategoryName = CategoryName,
						}
					)
				end
				return Categories
			end),
		},
	}
end
