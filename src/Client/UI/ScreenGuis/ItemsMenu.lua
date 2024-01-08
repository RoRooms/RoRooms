local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent)

local Shared = RoRooms.Shared
local Client = RoRooms.Client
local Config = RoRooms.Config

local NekaUI = require(Shared.ExtPackages.NekaUI)
local Fusion = require(NekaUI.Packages.Fusion)
local States = require(Client.UI.States)
local AutomaticSizer = require(NekaUI.Utils.AutomaticSizer)

local Children = Fusion.Children
local New = Fusion.New
local Computed = Fusion.Computed
local Spring = Fusion.Spring
local Observer = Fusion.Observer
local ForValues = Fusion.ForValues

local AutoScaleFrame = require(NekaUI.Components.AutoScaleFrame)
local MenuFrame = require(NekaUI.Components.MenuFrame)
local ScrollingFrame = require(NekaUI.Components.ScrollingFrame)
local ItemsCategory = require(Client.UI.Components.ItemsCategory)
local ItemCategoriesSidebar = require(Client.UI.Components.ItemCategoriesSidebar)

return function(Props)
  local Categories = Computed(function()
    local CategoriesList = {}

    for _, Item in pairs(Config.ItemsSystem.Items) do
      local CategoryName
      if typeof(Item.Category) == "string" then
        CategoryName = Item.Category
      elseif Item.Category == nil then
        CategoryName = "General"
      end
      if not table.find(CategoriesList, CategoryName) then
        table.insert(CategoriesList, CategoryName)
      end
    end

    return CategoriesList
  end)

  local ItemsMenu = New "ScreenGui" {
    Name = "ItemsMenu",
    Parent = Props.Parent,
    ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets,
    Enabled = States.ItemsMenu.Open,
    ResetOnSpawn = false,

    [Children] = {
      AutoScaleFrame {
        AnchorPoint = Vector2.new(0.5, 1),
        Position = Spring(Computed(function()
          local YPos = 68+15
          if not States.ItemsMenu.Open:get() then
            YPos -= 15
          end
          return UDim2.new(UDim.new(0.5, 0), UDim.new(1, -YPos))
        end), 37, 1),
        BaseResolution = Vector2.new(883, 893),

        [Children] = {
          New "UIListLayout" {},
          MenuFrame {
            Size = UDim2.fromOffset(410, 0),
            GroupTransparency = Spring(Computed(function()
              if States.ItemsMenu.Open:get() then
                return 0
              else
                return 1
              end
            end), 40, 1),

            [Children] = {
              New "UIPadding" {
                PaddingBottom = UDim.new(0, 10),
                PaddingLeft = UDim.new(0, 10),
                PaddingRight = UDim.new(0, 10),
                PaddingTop = UDim.new(0, 10),
              },
              New "UIListLayout" {
                Padding = UDim.new(0, 10),
                FillDirection = Enum.FillDirection.Horizontal,
              },
              ItemCategoriesSidebar {
                Size = UDim2.new(UDim.new(0, 46), UDim.new(1, 0)),
              },
              ScrollingFrame {
                Name = "Items",
                Size = UDim2.new(UDim.new(1, 0), UDim.new(0, 220)),

                [Children] = {
                  New "UIPadding" {
                    PaddingLeft = UDim.new(0, 4),
                    PaddingBottom = UDim.new(0, 4),
                    PaddingTop = UDim.new(0, 4),
                    PaddingRight = UDim.new(0, 4)
                  },
                  New "UIListLayout" {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 15),
                  },
                  ForValues(Categories, function(CategoryName: string)
                    return ItemsCategory {
                      CategoryName = CategoryName
                    }
                  end, Fusion.cleanup)
                }
              }
            }
          }
        }
      }
    }
  }

  local DisconnectOpen = Observer(States.ItemsMenu.Open):onChange(function()
    local TextClasses = {"TextLabel", "TextButton", "TextBox"}
    if States.ItemsMenu.Open:get() then
      if States.ScreenSize:get().Y < 1000 then
        States.CurrentMenu:set()
      end
    end
    for _, Descendant in ipairs(ItemsMenu:GetDescendants()) do
      if table.find(TextClasses, Descendant.ClassName) then
        task.wait()
        AutomaticSizer.ApplyLayout(Descendant)
      end
    end
  end)

  local DisconnectFocusedCategory = Observer(States.ItemsMenu.FocusedCategory):onChange(function()
    local Items = ItemsMenu.AutoScaleFrame.MenuFrame.Contents.Items
    local Category = Items.Contents:FindFirstChild(`{States.ItemsMenu.FocusedCategory:get()}ItemsCategory`)
    if Category then
      Items.CanvasPosition = Vector2.new(0, 0)
      Items.CanvasPosition = Vector2.new(0, Category.AbsolutePosition.Y - Items.AbsolutePosition.Y)
    end
  end)

  ItemsMenu:GetPropertyChangedSignal("Parent"):Connect(function()
    if ItemsMenu.Parent == nil then
      DisconnectOpen()
      DisconnectFocusedCategory()
    end
  end)

  return ItemsMenu
end