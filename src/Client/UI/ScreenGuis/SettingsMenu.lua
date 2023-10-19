local RoRooms = require(game:GetService("ReplicatedStorage").RoRooms)

local Shared = RoRooms.Shared
local Client = RoRooms.Client

local StarterGui = game:GetService("StarterGui")

local Fusion = require(Shared.ExtPackages.NekaUI.Packages.Fusion)
local NekaUI = require(Shared.ExtPackages.NekaUI)
local States = require(Client.UI.States)
local AutomaticSizer = require(NekaUI.Utils.AutomaticSizer)

local Children = Fusion.Children
local New = Fusion.New
local Computed = Fusion.Computed
local Spring = Fusion.Spring
local Observer = Fusion.Observer

local AutoScaleFrame = require(NekaUI.Components.AutoScaleFrame)
local MenuFrame = require(NekaUI.Components.MenuFrame)
local TitleBar = require(NekaUI.Components.TitleBar)
local SettingToggle = require(NekaUI.Extras.SettingToggle)
local ScrollingFrame = require(NekaUI.Components.ScrollingFrame)
local Text = require(NekaUI.Components.Text)

local TOGGLEABLE_CORE_GUIS = { Enum.CoreGuiType.Chat, Enum.CoreGuiType.PlayerList } 

return function(Props)
  local MenuOpen = Computed(function()
    return States.CurrentMenu:get() == script.Name
  end)

  Observer(States.Settings.HideUI):onChange(function()
    for _, CoreGuiType in ipairs(TOGGLEABLE_CORE_GUIS) do
      StarterGui:SetCoreGuiEnabled(CoreGuiType, not States.Settings.HideUI:get())
    end
    for _, TopbarIcon in ipairs({States.TopbarIcons.Coins}) do
      TopbarIcon:setEnabled(not States.Settings.HideUI:get())
    end
  end)

  local SettingsMenu = New "ScreenGui" {
    Name = "SettingsMenu",
    Parent = Props.Parent,
    Enabled = MenuOpen,
    ResetOnSpawn = false,
    ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets,

    [Children] = {
      AutoScaleFrame {
        AnchorPoint = Vector2.new(0.5, 0),
        Position = Spring(Computed(function()
          local YPos = States.TopbarBottomPos:get() + 15
          if not MenuOpen:get() then
            YPos = YPos + 15
          end
          return UDim2.new(UDim.new(0.5, 0), UDim.new(0, YPos))
        end), 37, 1),
        BaseResolution = Vector2.new(883, 893),

        [Children] = {
          New "UIListLayout" {},
          MenuFrame {
            Size = UDim2.fromOffset(305, 0),
            GroupTransparency = Spring(Computed(function()
              if MenuOpen:get() then
                return 0
              else
                return 1
              end
            end), 40, 1),

            [Children] = {
              New "UIPadding" {
                PaddingBottom = UDim.new(0, 13),
                PaddingLeft = UDim.new(0, 13),
                PaddingRight = UDim.new(0, 13),
                PaddingTop = UDim.new(0, 9),
              },
              TitleBar {
                Title = "Settings",
                CloseButtonDisabled = true,
                TextSize = 24,
              },
              ScrollingFrame {
                Size = UDim2.new(UDim.new(1, 0), UDim.new(0, 135)),
                AutomaticSize = Enum.AutomaticSize.None,
    
                [Children] = {
                  New "UIListLayout" {
                    SortOrder = Enum.SortOrder.LayoutOrder,
                    Padding = UDim.new(0, 10),
                  },
                  New "UIPadding" {
                    PaddingTop = UDim.new(0, 2),
                    PaddingBottom = UDim.new(0, 3),
                    PaddingRight = UDim.new(0, 2),
                  },
                  SettingToggle {
                    Label = "Mute music",
                    SwitchedOn = States.Settings.MuteMusic,
                  },
                  SettingToggle {
                    Label = "Hide UI",
                    SwitchedOn = States.Settings.HideUI,
                  },
                  Text {
                    Text = "[RoRooms v0.0.0]",
                    TextColor3 = Color3.fromRGB(124, 124, 124)
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  local DisconnectOpen = Observer(MenuOpen):onChange(function()
    local TextClasses = {"TextLabel", "TextButton", "TextBox"}
    for _, Descendant in ipairs(SettingsMenu:GetDescendants()) do
      if table.find(TextClasses, Descendant.ClassName) then
        task.wait()
        AutomaticSizer.ApplyLayout(Descendant)
      end
    end
  end)

  SettingsMenu:GetPropertyChangedSignal("Parent"):Connect(function()
    if SettingsMenu.Parent == nil then
      DisconnectOpen()
    end
  end)

  return SettingsMenu
end