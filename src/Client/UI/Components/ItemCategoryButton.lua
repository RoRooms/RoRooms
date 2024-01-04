local RoRooms = require(game:GetService("ReplicatedStorage").RoRooms)

local Shared = RoRooms.Shared
local Client = RoRooms.Client
local Config = RoRooms.Config
local Packages = RoRooms.Packages

local Fusion = require(Shared.ExtPackages.NekaUI.Packages.Fusion)
local NekaUI = require(Shared.ExtPackages.NekaUI)
local EnsureProp = require(NekaUI.Utils.EnsureProp)
local States = require(Client.UI.States)
local ColourUtils = require(NekaUI.Packages.ColourUtils)

local Children = Fusion.Children
local New = Fusion.New
local Spring = Fusion.Spring
local Computed = Fusion.Computed
local Value = Fusion.Value

local BaseButton = require(NekaUI.Components.BaseButton)
local Icon = require(NekaUI.Components.Icon)
 
return function(Props)
  Props.CategoryName = EnsureProp(Props.CategoryName, "string", "Category")

  local Category = Computed(function()
    return Config.ItemsSystem.Categories[Props.CategoryName:get()]
  end)

  local IsHolding = Value(false)

  return BaseButton {
    Name = "ItemCategoryButton",
    BackgroundColor3 = Spring(Computed(function()
      local BaseColor = Color3.fromRGB(61, 61, 61)
      if IsHolding:get() then
        return ColourUtils.Lighten(BaseColor, 0.1)
      else
        return BaseColor
      end
    end), 35, 1),
    BackgroundTransparency = 0,
    LayoutOrder = Computed(function()
      return Props.Category:get().LayoutOrder or 0
    end),

    OnActivated = function()
      States.ItemsMenu.FocusedCategory:set(Props.CategoryName:get())
    end,
    IsHolding = IsHolding,

    [Children] = {
      New "UICorner" {
        CornerRadius = UDim.new(0, 5)
      },
      New "UIPadding" {
        PaddingLeft = UDim.new(0, 3),
        PaddingBottom = UDim.new(0, 3),
        PaddingTop = UDim.new(0, 3),
        PaddingRight = UDim.new(0, 3)
      },
      Icon {
        Image = Computed(function()
          if Category:get() and Category:get().Icon then
            return Category.Icon
          else
            return "rbxassetid://7058763764"
          end
        end),
        Size = UDim2.fromOffset(20, 20),
      }
    }
  }
end