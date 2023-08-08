local RoRooms = require(game:GetService("ReplicatedStorage").RoRooms)

local Shared = RoRooms.Shared

local NekaUI = require(Shared.ExtPackages.NekaUI)
local Fusion = require(NekaUI.Packages.Fusion)

local New = Fusion.New
local Children = Fusion.Children
local Computed = Fusion.Computed

local Text = require(NekaUI.Components.Text)

local function NametagText(Props)
  return Text {
    Name = Props.Name,
    LayoutOrder = Props.LayoutOrder,
    Text = Props.Text,
    FontFace = Props.FontFace or Font.fromName('GothamSsm', Enum.FontWeight.Bold),
    TextScaled = true,
    TextXAlignment = Enum.TextXAlignment.Center,
    TextYAlignment = Enum.TextYAlignment.Center,
    Size = Props.Size,
    AutomaticSize = Enum.AutomaticSize.None,
    Visible = Props.Visible,

    [Children] = {
      New "UIStroke" {
        Thickness = 2,
        Transparency = 0.85,
      }
    }
  }
end

return function(Props)
  return New "BillboardGui" {
    Name = "Nametag",
    Parent = Props.Parent,
    Adornee = Props.Adornee,
    Size = UDim2.fromScale(5, 1.55),
    StudsOffset = Vector3.new(0, 2.4, 0),
    LightInfluence = 0,
    Brightness = 1.3,
    ResetOnSpawn = false,
    AutoLocalize = false,

    [Children] = {
      New "UIListLayout" {
        SortOrder = Enum.SortOrder.LayoutOrder,
        FillDirection = Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Center,
        VerticalAlignment = Enum.VerticalAlignment.Bottom,
      },
      NametagText {
        Name = "Nickname",
        LayoutOrder = 1,
        Text = Props.Nickname,
        Size = UDim2.fromScale(1, 0.45),
        Visible = Computed(function()
          return Props.Nickname:get() ~= ""
        end),
      },
      NametagText {
        Name = "Status",
        LayoutOrder = 2,
        Text = Props.Status,
        Size = UDim2.fromScale(1, 0.26),
        FontFace = Font.fromName('GothamSsm', Enum.FontWeight.Bold, Enum.FontStyle.Italic),
        Visible = Computed(function()
          return Props.Status:get() ~= ""
        end),
      },
      -- Text {
      --   Name = "Status",
      --   LayoutOrder = 2,
      --   Text = Props.Status,
      --   FontFace = Font.fromName('GothamSsm', Enum.FontWeight.Bold, Enum.FontStyle.Italic),
      --   TextScaled = true,
      --   TextXAlignment = Enum.TextXAlignment.Center,
      --   TextYAlignment = Enum.TextYAlignment.Center,
      --   Size = UDim2.fromScale(1, 0.26),
      --   AutomaticSize = Enum.AutomaticSize.None,
      --   Visible = Computed(function()
      --     return utf8.len(Props.Status:get()) > 0
      --   end)
      -- },
    }
  }
end