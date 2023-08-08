local RoRooms = require(game:GetService("ReplicatedStorage").RoRooms)

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
local ForPairs = Fusion.ForPairs

local AutoScaleFrame = require(NekaUI.Components.AutoScaleFrame)
local MenuFrame = require(NekaUI.Components.MenuFrame)
local ItemButton = require(Client.UI.Components.ItemButton)
local ScrollingFrame = require(NekaUI.Components.ScrollingFrame)

return function(Props)
  local ItemsMenu = New "ScreenGui" {
    Name = "ItemsMenu",
    Parent = Props.Parent,
    ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets,
    Enabled = States.ItemsMenuOpen,
    ResetOnSpawn = false,

    [Children] = {
      AutoScaleFrame {
        AnchorPoint = Vector2.new(0.5, 1),
        Position = Spring(Computed(function()
          local YPos = 68+15
          if not States.ItemsMenuOpen:get() then
            YPos -= 15
          end
          return UDim2.new(UDim.new(0.5, 0), UDim.new(1, -YPos))
        end), 37, 1),
        BaseResolution = Vector2.new(883, 893),

        [Children] = {
          New "UIListLayout" {},
          MenuFrame {
            Size = UDim2.fromOffset(363, 0),
            GroupTransparency = Spring(Computed(function()
              if States.ItemsMenuOpen:get() then
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
              -- TitleBar {
              --   Title = "Items",
              --   CloseButtonDisabled = true,
              --   TextSize = 24,
              -- },
              ScrollingFrame {
                Name = "EmotesFrame",
                Size = UDim2.new(UDim.new(1, 0), UDim.new(0, 180)),

                [Children] = {
                  New "UIPadding" {
                    PaddingLeft = UDim.new(0, 4),
                    PaddingBottom = UDim.new(0, 4),
                    PaddingTop = UDim.new(0, 4),
                    PaddingRight = UDim.new(0, 4)
                  },
                  New "UIGridLayout" {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    CellSize = UDim2.fromOffset(75, 75),
                    CellPadding = UDim2.fromOffset(11, 11),
                  },
                  ForPairs(Config.ItemsSystem.Items, function(ItemId, Item)
                    return ItemId, ItemButton {
                      ItemId = ItemId,
                      Item = Item,
                      BaseColor3 = Item.TintColor,
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

  local DisconnectOpen = Observer(States.ItemsMenuOpen):onChange(function()
    local TextClasses = {"TextLabel", "TextButton", "TextBox"}
    if States.ItemsMenuOpen:get() then
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

  ItemsMenu:GetPropertyChangedSignal("Parent"):Connect(function()
    if ItemsMenu.Parent == nil then
      DisconnectOpen()
    end
  end)

  return ItemsMenu
end