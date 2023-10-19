local RoRooms = require(game:GetService("ReplicatedStorage").RoRooms)

local Shared = RoRooms.Shared
local Client = RoRooms.Client
local Config = RoRooms.Config

local Fusion = require(Shared.ExtPackages.NekaUI.Packages.Fusion)
local NekaUI = require(Shared.ExtPackages.NekaUI)
local States = require(Client.UI.States)

local Children = Fusion.Children
local New = Fusion.New
local ForValues = Fusion.ForValues
local Computed = Fusion.Computed

local Components = Client.UI.Components
local TopbarButton = require(Components.TopbarButton)
local AutoScaleFrame = require(NekaUI.Components.AutoScaleFrame)

local TOPBAR_BUTTONS = {
  {
    MenuName = "ProfileMenu",
    IconImage = "rbxassetid://15091717235",
  },
  {
    MenuName = "EmotesMenu",
    IconImage = "rbxassetid://15091717452",
  },
  {
    MenuName = "WorldsMenu",
    IconImage = "rbxassetid://15091717321",
  },
  {
    MenuName = "SettingsMenu",
    IconImage = "rbxassetid://15091717549",
  },
}
local FEATURE_MENU_MAP = {
  WorldsSystem = "WorldsMenu",
  ProfilesSystem = "ProfileMenu",
  EmotesSystem = "EmotesMenu",
  SettingsSystem = "SettingsMenu"
}

return function(Props)
  local EnabledTopbarButtons = Computed(function()
    local EnabledButtons = {}
    for FeatureName, MenuName in pairs(FEATURE_MENU_MAP) do
      if Config[FeatureName].Enabled then
        table.insert(EnabledButtons, MenuName)
      end
    end
    return EnabledButtons
  end)

  local TopbarInstance = New "ScreenGui" {
    Name = "Topbar",
    Parent = Props.Parent,
    ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets,
    ResetOnSpawn = false,

    [Children] = {
      AutoScaleFrame {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = UDim2.new(UDim.new(0.5, 0), UDim.new(0, 10)),
        BaseResolution = Vector2.new(883, 893),
        ScaleClamps = {Min = 0.75, Max = math.huge},

        [Children] = {
          New "UIListLayout" {
            SortOrder = Enum.SortOrder.LayoutOrder,
            Padding = UDim.new(0, 13),
            FillDirection = Enum.FillDirection.Horizontal,
            VerticalAlignment = Enum.VerticalAlignment.Center
          },
          ForValues(TOPBAR_BUTTONS, function(Button)
            return Computed(function()
              if table.find(EnabledTopbarButtons:get(), Button.MenuName) then
                return TopbarButton {
                  MenuName = Button.MenuName,
                  IconImage = Button.IconImage,
                  SizeMultiplier = Button.SizeMultiplier
                }
              end
            end, Fusion.cleanup)
          end, Fusion.cleanup)
        }
      }
    }
  }

  local TopbarFrame = TopbarInstance.AutoScaleFrame

  local function UpdateTopbarBottomPos()
    local Height = TopbarFrame.AbsoluteSize.Y
    local PosY = TopbarFrame.Position.Y.Offset
    States.TopbarBottomPos:set(Height + PosY)
  end

  TopbarFrame:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateTopbarBottomPos)

  return TopbarInstance
end