local RoRooms = require(game:GetService("ReplicatedStorage").RoRooms)

local Shared = RoRooms.Shared
local Client = RoRooms.Client

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
local Text = require(NekaUI.Components.Text)

return function(Props)
  Props.WorldId = EnsureProp(Props.WorldId, "string", "EmoteId")
  Props.World = EnsureProp(Props.World, "table", {})

  local IsHolding = Value(false)

  return BaseButton {
    Name = "WorldButton",
    BackgroundColor3 = Spring(Computed(function()
      local BaseColor = Color3.fromRGB(41, 41, 41)
      if IsHolding:get() then
        return ColourUtils.Lighten(BaseColor, 0.02)
      else
        return BaseColor
      end
    end), 35, 1),
    BackgroundTransparency = 0,
    ClipsDescendants = true,
    LayoutOrder = Computed(function()
      return Props.World:get().LayoutOrder or 0
    end),

    OnActivated = function()
      if States.WorldsService then
        States.CurrentMenu:set()
        States:PushPrompt({
          Title = "Teleport",
          Text = "Do you want to teleport to world "..Props.World:get().Name.."?",
          Buttons = {
            {
              Primary = false,
              Contents = {"Cancel"},
            },
            {
              Primary = true,
              Contents = {"Teleport"},
              Callback = function()
                States.WorldsService:TeleportToWorld(Props.WorldId:get())
              end
            },
          }
        })
      end
    end,
    IsHolding = IsHolding,

    [Children] = {
      New "UICorner" {
        CornerRadius = UDim.new(0, 10)
      },
      New "UIPadding" {
        PaddingLeft = UDim.new(0, 5),
        PaddingBottom = UDim.new(0, 10),
        PaddingTop = UDim.new(0, 8),
        PaddingRight = UDim.new(0, 5)
      },
      New "UIStroke" {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Thickness = 2,
        Color = Color3.fromRGB(51, 51, 51),
      },
      New "UIListLayout" {
        Padding = UDim.new(0, 8),
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
      },
      New "ImageLabel" {
        Name = "GameIcon",
        Size = UDim2.fromOffset(85, 85),
        Image = Computed(function()
          return "rbxthumb://type=GameIcon&id="..(Props.World:get().UniverseId or 1).."&w=150&h=150"
        end),
        BackgroundTransparency = 1,

        [Children] = {
          New "UICorner" {
            CornerRadius = UDim.new(0, 8)
          },
          New "UIAspectRatioConstraint" {
            AspectRatio = 1
          }
        }
      },
      Text {
        Name = "WorldName",
        AnchorPoint = Vector2.new(0.5, 1),
        Position = UDim2.fromScale(0.5, 1),
        Size = UDim2.fromScale(1, 0),
        Text = Computed(function()
          return Props.World:get().Name or Props.WorldId:get()
        end),
        TextSize = 16,
        TextTruncate = Enum.TextTruncate.AtEnd,
        AutomaticSize = Enum.AutomaticSize.Y,
        TextXAlignment = Enum.TextXAlignment.Center,
        AutoLocalize = false,
      }
    }
  }
end