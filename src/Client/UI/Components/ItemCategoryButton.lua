local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent)

local Shared = RoRooms.Shared
local Client = RoRooms.Client
local Config = RoRooms.Config

local Fusion = require(Shared.ExtPackages.OnyxUI.Packages.Fusion)
local OnyxUI = require(Shared.ExtPackages.OnyxUI)
local EnsureProp = require(OnyxUI.Utils.EnsureProp)
local States = require(Client.UI.States)
local ColourUtils = require(OnyxUI.Packages.ColourUtils)

local Children = Fusion.Children
local New = Fusion.New
local Spring = Fusion.Spring
local Computed = Fusion.Computed
local Value = Fusion.Value

local BaseButton = require(OnyxUI.Components.BaseButton)
local Icon = require(OnyxUI.Components.Icon)

local BASE_COLOR = Color3.fromRGB(41, 41, 41)

return function(Props)
  Props.CategoryName = EnsureProp(Props.CategoryName, "string", "Category")

  local Category = Computed(function()
    return Config.ItemsSystem.Categories[Props.CategoryName:get()]
  end)

  local IsHolding = Value(false)

  return BaseButton {
    Name = "ItemCategoryButton",
    BackgroundColor3 = Spring(Computed(function()
      local BaseColor = BASE_COLOR
      if IsHolding:get() then
        return ColourUtils.Lighten(BASE_COLOR, 0.1)
      else
        return BaseColor
      end
    end), 35, 1),
    BackgroundTransparency = 0,
    LayoutOrder = Computed(function()
      if Category:get() then
        return Category:get().LayoutOrder or 0
      end
    end),

    OnActivated = function()
      States.ItemsMenu.FocusedCategory:set(Props.CategoryName:get(), true)
    end,
    IsHolding = IsHolding,

    [Children] = {
      New "UICorner" {
        CornerRadius = UDim.new(0, 8)
      },
      New "UIPadding" {
        PaddingLeft = UDim.new(0, 8),
        PaddingBottom = UDim.new(0, 8),
        PaddingTop = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 8)
      },
      New "UIStroke" {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Thickness = 2,
        Color = Color3.fromRGB(51, 51, 51)
      },
      Icon {
        Image = Computed(function()
          if Category:get() and Category:get().Icon then
            return Category:get().Icon
          else
            return "rbxassetid://7058763764"
          end
        end),
        Size = UDim2.fromOffset(25, 25),
      }
    }
  }
end