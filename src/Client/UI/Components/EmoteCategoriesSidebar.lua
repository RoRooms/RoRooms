local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent)

local Shared = RoRooms.Shared
local Client = RoRooms.Client
local Config = RoRooms.Config

local NekaUI = require(Shared.ExtPackages.NekaUI)
local Fusion = require(NekaUI.Packages.Fusion)

local New = Fusion.New
local Children = Fusion.Children
local Computed = Fusion.Computed

local ScrollingFrame = require(NekaUI.Components.ScrollingFrame)
local EmoteCategoryButton = require(Client.UI.Components.EmoteCategoryButton)

return function(Props: table)
	return ScrollingFrame {
		Name = "EmoteCategoriesSidebar",
		Size = Props.Size,

		[Children] = {
			New "UIListLayout" {
				Padding = UDim.new(0, 10),
				FillDirection = Enum.FillDirection.Vertical,
				SortOrder = Enum.SortOrder.LayoutOrder,
			},
			New "UIPadding" {
				PaddingLeft = UDim.new(0, 2),
				PaddingBottom = UDim.new(0, 2),
				PaddingTop = UDim.new(0, 2),
				PaddingRight = UDim.new(0, 2),
			},
			Computed(function()
				local Categories = {}
				for CategoryName, _ in Config.EmotesSystem.Categories do
					table.insert(
						Categories,
						EmoteCategoryButton {
							CategoryName = CategoryName,
						}
					)
				end
				return Categories
			end),
		},
	}
end
