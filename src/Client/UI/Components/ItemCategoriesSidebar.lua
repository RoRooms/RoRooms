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
local ItemCategoryButton = require(Client.UI.Components.ItemCategoryButton)

return function(Props: table)
  return ScrollingFrame {
    Name = "ItemCategoriesSidebar",
    Size = Props.Size,
    -- AutomaticSize = Props.AutomaticSize,

    [Children] = {
      New "UIListLayout" {
        Padding = UDim.new(0, 10),
        FillDirection = Enum.FillDirection.Vertical,
        SortOrder = Enum.SortOrder.LayoutOrder,
      },
      New "UIPadding" {
        PaddingLeft = UDim.new(0, 3),
        PaddingBottom = UDim.new(0, 3),
        PaddingTop = UDim.new(0, 3),
        PaddingRight = UDim.new(0, 3)
      },
      Computed(function()
        local Categories = {}
        for CategoryName, _ in Config.ItemsSystem.Categories do
          table.insert(Categories, ItemCategoryButton {
            CategoryName = CategoryName
          })
        end
        return Categories
      end)
    }
  }
end