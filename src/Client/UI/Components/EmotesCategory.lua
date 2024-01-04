local RoRooms = require(game:GetService("ReplicatedStorage").RoRooms)

local Shared = RoRooms.Shared
local Config = RoRooms.Config
local Client = RoRooms.Client
local Packages = RoRooms.Packages

local Fusion = require(Shared.ExtPackages.NekaUI.Packages.Fusion)
local NekaUI = require(Shared.ExtPackages.NekaUI)
local EnsureProp = require(NekaUI.Utils.EnsureProp)
local States = require(Client.UI.States)

local Children = Fusion.Children
local New = Fusion.New
local Computed = Fusion.Computed

local Frame = require(NekaUI.Components.Frame)
local Text = require(NekaUI.Components.Text)
local EmoteButton = require(Client.UI.Components.EmoteButton)

return function(Props: table)
  Props.CategoryName = EnsureProp(Props.CategoryName, "string", "Category")

  local Category = Computed(function()
    return Config.EmotesSystem.Categories[Props.CategoryName:get()]
  end)
  
  local EmoteButtons = Computed(function()
    local List = {}

    for EmoteId, Emote in pairs(Config.EmotesSystem.Emotes) do
      if Emote.Category == nil then
        Emote.Category = "General"
      end
      if Emote.Category == Props.CategoryName:get() then
        table.insert(List, EmoteButton {
          EmoteId = EmoteId,
          Emote = Emote,
          BaseColor3 = Emote.TintColor,
          Callback = function()
            if States.ScreenSize:get().Y <= 500 then
              States.CurrentMenu:set()
            end
          end
        })
      end
    end

    return List
  end, Fusion.cleanup)

  return Frame {
    Name = "EmotesCategory",
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
        Name = "Emotes",
        Size = UDim2.fromScale(1, 0),
        AutomaticSize = Enum.AutomaticSize.Y,

        [Children] = {
          New "UIGridLayout" {
            SortOrder = Enum.SortOrder.LayoutOrder,
            CellSize = UDim2.fromOffset(75, 75),
            CellPadding = UDim2.fromOffset(11, 11),
          },
          EmoteButtons,
        }
      }
      
    }
  }
end