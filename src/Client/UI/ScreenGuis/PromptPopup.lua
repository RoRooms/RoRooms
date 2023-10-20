local RoRooms = require(game:GetService("ReplicatedStorage").RoRooms)

local Shared = RoRooms.Shared
local Client = RoRooms.Client

local Fusion = require(Shared.ExtPackages.NekaUI.Packages.Fusion)
local NekaUI = require(Shared.ExtPackages.NekaUI)
local States = require(Client.UI.States)
local AutomaticSizer = require(NekaUI.Utils.AutomaticSizer)

local Children = Fusion.Children
local New = Fusion.New
local Computed = Fusion.Computed
local Spring = Fusion.Spring
local Observer = Fusion.Observer
local ForValues = Fusion.ForValues

local AutoScaleFrame = require(NekaUI.Components.AutoScaleFrame)
local MenuFrame = require(NekaUI.Components.MenuFrame)
local Text = require(NekaUI.Components.Text)
local Button = require(NekaUI.Components.Button)
local Frame = require(NekaUI.Components.Frame)

return function(Props)
  local CurrentPrompt = Computed(function()
    return States.Prompts:get()[#States.Prompts:get()]
  end)
  local PromptOpen = Computed(function()
    return CurrentPrompt:get() ~= nil
  end)

  -- States:PushPrompt({
  --   Title = "Do action",
  --   Text = "Would you like to do this action?",
  --   Buttons = {
  --     {
  --       Primary = false,
  --       Contents = {"Cancel"},
  --       Callback = function()
  --         print('cancelled')
  --       end
  --     },
  --     {
  --       Primary = true,
  --       Contents = {"Confirm"},
  --       Callback = function()
  --         print('confirmed')
  --       end
  --     },
  --   }
  -- })
  
  local PromptPopup = New "ScreenGui" {
    Name = "PromptPopup",
    Parent = Props.Parent,
    ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets,
    Enabled = PromptOpen,
    ResetOnSpawn = false,

    [Children] = {
      AutoScaleFrame {
        AnchorPoint = Vector2.new(0.5, 0.5),
        Position = Spring(Computed(function()
          local YPos = 0
          if not PromptOpen:get() then
            YPos = YPos + 15
          end
          return UDim2.new(UDim.new(0.5, 0), UDim.new(0.5, YPos))
        end), 37, 1),
        BaseResolution = Vector2.new(883, 893),

        [Children] = {
          New "UIListLayout" {},
          MenuFrame {
            Size = UDim2.fromOffset(305, 0),
            GroupTransparency = Spring(Computed(function()
              if PromptOpen:get() then
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
              New "UIListLayout" {
                SortOrder = Enum.SortOrder.LayoutOrder,
                Padding = UDim.new(0, 8),
              },
              Text {
                Name = "Title",
                TextWrapped = false,
                Text = Computed(function()
                  if CurrentPrompt:get() then
                    return CurrentPrompt:get().Title
                  else
                    return ""
                  end
                end),
                TextSize = 24,
                FontFace = Font.fromName('GothamSsm', Enum.FontWeight.SemiBold)
              },
              Text {
                Name = "Text",
                Size = UDim2.new(UDim.new(1, 0), UDim.new(0, 80)),
                AutomaticSize = Enum.AutomaticSize.None,
                TextWrapped = true,
                Text = Computed(function()
                  if CurrentPrompt:get() then
                    return CurrentPrompt:get().Text
                  else
                    return ""
                  end
                end),
                TextSize = 20,
              },
              Frame {
                Size = UDim2.fromScale(1, 0),
                AutomaticSize = Enum.AutomaticSize.Y,

                [Children] = {
                  New "UIListLayout" {
                    Padding = UDim.new(0, 10),
                    FillDirection = Enum.FillDirection.Horizontal,
                    HorizontalAlignment = Enum.HorizontalAlignment.Center,
                  },
                  ForValues(Computed(function()
                    if CurrentPrompt:get() then
                      return CurrentPrompt:get().Buttons
                    else
                      return {}
                    end
                  end), function(ButtonEntry)
                    local ButtonCount = #CurrentPrompt:get().Buttons
                    return Button {
                      Style = (ButtonEntry.Primary and "Filled") or "Empty",
                      Contents = ButtonEntry.Contents,
                      OnActivated = function()
                        local NewPrompts = States.Prompts:get()
                        table.remove(NewPrompts, table.find(NewPrompts, CurrentPrompt:get()))
                        States.Prompts:set(NewPrompts)
                        if ButtonEntry.Callback then
                          ButtonEntry.Callback()
                        end
                      end,
                      Size = UDim2.new(UDim.new(1 / ButtonCount, -5), UDim.new(0, 0)),
                      AutomaticSize = Enum.AutomaticSize.Y,
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

  local DisconnectOpen = Observer(PromptOpen):onChange(function()
    local TextClasses = {"TextLabel", "TextButton", "TextBox"}
    for _, Descendant in ipairs(PromptPopup:GetDescendants()) do
      if table.find(TextClasses, Descendant.ClassName) then
        task.wait()
        AutomaticSizer.ApplyLayout(Descendant)
      end
    end
  end)

  PromptPopup:GetPropertyChangedSignal("Parent"):Connect(function()
    if PromptPopup.Parent == nil then
      DisconnectOpen()
    end
  end)

  return PromptPopup
end