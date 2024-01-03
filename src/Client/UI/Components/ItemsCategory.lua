local RoRooms = require(game:GetService("ReplicatedStorage").RoRooms)

local Shared = RoRooms.Shared
local Config = RoRooms.Config
local Client = RoRooms.Client

local Fusion = require(Shared.ExtPackages.NekaUI.Packages.Fusion)
local NekaUI = require(Shared.ExtPackages.NekaUI)
local EnsureProp = require(NekaUI.Utils.EnsureProp)
local States = require(Client.UI.States)

local Children = Fusion.Children
local New = Fusion.New
local Computed = Fusion.Computed

local Frame = require(NekaUI.Components.Frame)
local Text = require(NekaUI.Components.Text)
local ItemButton = require(Client.UI.Components.ItemButton)

return function(Props: table)
  Props.CategoryName = EnsureProp(Props.CategoryName, "string", "Category")

  local Category = Computed(function()
    return Config.ItemsSystem.Categories[Props.CategoryName:get()]
  end)
  
  local ItemButtons = Computed(function()
    local List = {}

    for ItemId, Item in pairs(Config.ItemsSystem.Items) do
      if Item.Category == nil then
        Item.Category = "General"
      end
      if Item.Category == Props.CategoryName:get() then
        table.insert(List, ItemButton {
          ItemId = ItemId,
          Item = Item,
          BaseColor3 = Item.TintColor,
          -- Callback = function()
          --   if States.ScreenSize:get().Y <= 500 then
          --     States.CurrentMenu:set()
          --   end
          -- end
        })
      end
    end

    return List
  end, Fusion.cleanup)

  return Frame {
    Name = "ItemsCategory",
    Size = UDim2.fromScale(1, 0),
    AutomaticSize = Enum.AutomaticSize.Y,
    LayoutOrder = Computed(function()
      if Category:get() then
        return Category:get().LayoutOrder
      else
        return 0
      end
    end),

    [Children] = {
      New "UIListLayout" {
        Padding = UDim.new(0, 8),
        SortOrder = Enum.SortOrder.LayoutOrder,
      },
      Text {
        Text = Props.CategoryName,
        TextSize = 20,
      },
      Frame {
        Name = "Items",
        Size = UDim2.fromScale(1, 0),
        AutomaticSize = Enum.AutomaticSize.Y,

        [Children] = {
          New "UIGridLayout" {
            SortOrder = Enum.SortOrder.LayoutOrder,
            CellSize = UDim2.fromOffset(75, 75),
            CellPadding = UDim2.fromOffset(11, 11),
          },
          ItemButtons,
        }
      }
      
    }
  }
end