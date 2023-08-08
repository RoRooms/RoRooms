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
local Icon = require(NekaUI.Components.Icon)
local Frame = require(NekaUI.Components.Frame)

return function(Props)
  Props.EmoteId = EnsureProp(Props.EmoteId, "string", "EmoteId")
  Props.Emote = EnsureProp(Props.Emote, "table", {})
  Props.BaseColor3 = EnsureProp(Props.BaseColor3, "Color3", Color3.fromRGB(51, 51, 51))

  local IsHolding = Value(false)

  return BaseButton {
    Name = "EmoteButton",
    BackgroundColor3 = Spring(Computed(function()
      local BaseColor = ColourUtils.Darken(Props.BaseColor3:get(), 0.18)
      if IsHolding:get() then
        return ColourUtils.Lighten(BaseColor, 0.1)
      else
        return BaseColor
      end
    end), 35, 1),
    BackgroundTransparency = 0,
    Size = UDim2.fromOffset(75, 75),
    AutomaticSize = Enum.AutomaticSize.None,
    ClipsDescendants = true,
    LayoutOrder = Computed(function()
      return Props.Emote:get().LayoutOrder or 0
    end),

    OnActivated = function()
      if Props.Callback then
        Props.Callback()
      end
      if States.EmotesController then
        States.EmotesController:PlayEmote(Props.EmoteId:get())
      end
    end,
    IsHolding = IsHolding,

    [Children] = {
      New "UICorner" {
        CornerRadius = UDim.new(0, 10)
      },
      New "UIPadding" {
        PaddingLeft = UDim.new(0, 5),
        PaddingBottom = UDim.new(0, 5),
        PaddingTop = UDim.new(0, 5),
        PaddingRight = UDim.new(0, 5)
      },
      New "UIStroke" {
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Thickness = 2,
        Color = Props.BaseColor3,
      },
      Text {
        Name = "Emoji",
        LayoutOrder = 1,
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = UDim2.fromScale(0.5, 0.45),
        Text = Computed(function()
          return Props.Emote:get().Emoji or "🪩"
        end),
        TextSize = 36,
        ClipsDescendants = false,
      },
      Frame {
        Name = "Label",
        ZIndex = 2,

        [Children] = {
          New "UIListLayout" {
            Padding = UDim.new(0, 3),
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center,
          },
          Icon {
            Name = "LabelIcon",
            AnchorPoint = Vector2.new(0, 0),
            Position = UDim2.fromScale(0, 0),
            Size = UDim2.fromOffset(13, 13),
            Image = Computed(function()
              local LabelIcon = Props.Emote:get().LabelIcon
              local LevelRequirement = Props.Emote:get().LevelRequirement
              if LabelIcon then
                return LabelIcon
              elseif LevelRequirement then
                return "rbxassetid://5743022869"
              else
                return ""
              end
            end),
            ImageColor3 = Computed(function()
              return ColourUtils.Lighten(Props.BaseColor3:get(), 0.25)
            end),
          },
          Text {
            Name = "LabelText",
            AnchorPoint = Vector2.new(0, 0),
            Position = UDim2.fromScale(0, 0),
            Text = Computed(function()
              local LabelText = Props.Emote:get().LabelText
              local LevelRequirement = Props.Emote:get().LevelRequirement
              if LabelText then
                return LabelText
              elseif LevelRequirement then
                return LevelRequirement
              else
                return ""
              end
            end),
            TextSize = 13,
            TextColor3 = Computed(function()
              return ColourUtils.Lighten(Props.BaseColor3:get(), 0.5)
            end),
            ClipsDescendants = false,
            AutoLocalize = false,
          },
        }
      },
      Text {
        Name = "EmoteName",
        LayoutOrder = 3,
        AnchorPoint = Vector2.new(0.5, 1),
        Position = UDim2.fromScale(0.5, 1),
        Size = UDim2.fromScale(1, 0),
        Text = Computed(function()
          return Props.Emote:get().Name or Props.EmoteId:get()
        end),
        TextSize = 14,
        TextTruncate = Enum.TextTruncate.AtEnd,
        AutomaticSize = Enum.AutomaticSize.Y,
        TextXAlignment = Enum.TextXAlignment.Center,
      }
    }
  }
end