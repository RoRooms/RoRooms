local RoRooms = require(game:GetService("ReplicatedStorage").RoRooms)

local Shared = RoRooms.Shared
local Client = RoRooms.Client

local Fusion = require(Shared.ExtPackages.NekaUI.Packages.Fusion)
local NekaUI = require(Shared.ExtPackages.NekaUI)
local EnsureProp = require(NekaUI.Utils.EnsureProp)
local States = require(Client.UI.States)

local Children = Fusion.Children
local New = Fusion.New
local Spring = Fusion.Spring
local Computed = Fusion.Computed
local Value = Fusion.Value

local BaseButton = require(NekaUI.Components.BaseButton)
local Icon = require(NekaUI.Components.Icon)

return function(Props)
  Props.SizeMultiplier = EnsureProp(Props.SizeMultiplier, "number", 1)
  Props.IconImage = EnsureProp(Props.IconImage, "string", "")
  Props.MenuName = EnsureProp(Props.MenuName, "string", "")

  local IsHolding = Value(false)

  return BaseButton {
    Name = "TopbarButton",
    BackgroundColor3 = Color3.fromRGB(26, 26, 26),
    BackgroundTransparency = 0,
    Size = Computed(function()
      local BaseSize = UDim2.fromOffset(75, 75)
      local SizeMultiplier = Props.SizeMultiplier:get()
      return UDim2.fromOffset(BaseSize.X.Offset * SizeMultiplier, BaseSize.Y.Offset * SizeMultiplier)
    end),
    AutomaticSize = Enum.AutomaticSize.None,

    IsHolding = IsHolding,
    OnActivated = function()
      if States.CurrentMenu:get() == Props.MenuName:get() then
        States.CurrentMenu:set()
      else
        States.CurrentMenu:set(Props.MenuName:get())
        if States.ScreenSize:get().Y < 900 then
          States.ItemsMenuOpen:set()
        end
      end
    end,

    [Children] = {
      New "UIListLayout" {
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Center,  
      },
      New "UICorner" {
        CornerRadius = UDim.new(0.5, 0)
      },
      New "UIStroke" {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Thickness = 3,
        Color = Spring(Computed(function()
          if States.CurrentMenu:get() == Props.MenuName:get() then
            return Color3.fromRGB(207, 207, 207)
          else
            return Color3.fromRGB(56, 56, 56)
          end
        end), 32, 1),
      },
      New "UIPadding" {
        PaddingLeft = UDim.new(0, 13),
        PaddingBottom = UDim.new(0, 13),
        PaddingTop = UDim.new(0, 13),
        PaddingRight = UDim.new(0, 13),
      },
      Icon {
        Image = Props.IconImage,
        Size = Spring(Computed(function()
          local BaseSize = 51
          BaseSize = BaseSize * Props.SizeMultiplier:get()
          if not IsHolding:get() then
            return UDim2.fromOffset(BaseSize, BaseSize)
          else
            return UDim2.fromOffset(BaseSize * 0.9, BaseSize * 0.9)
          end
        end), 40, 1),
      }
    }
  }
end