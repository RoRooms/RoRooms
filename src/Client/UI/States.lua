local RoRooms = require(game:GetService("ReplicatedStorage").RoRooms)

local Shared = RoRooms.Shared

local Knit = require(Shared.Packages.Knit)
local Fusion = require(Shared.ExtPackages.NekaUI.Packages.Fusion)
local ReconcileTable = require(Shared.ExtPackages.ReconcileTable)

local Value = Fusion.Value
local Hydrate = Fusion.Hydrate
local Out = Fusion.Out

local CONTROLLERS = {"UIController", "EmotesController", "ItemsController"}
local SERVICES = {"UserProfileService", "WorldsService", "ItemsService", "PlayerDataService", "EmotesService"}

local States = {
  TopbarIcons = {},
  Prompts = Value({}),
  CurrentMenu = Value(),
  TopbarBottomPos = Value(0),
  TopbarVisible = Value(true),
  ScreenSize = Value(Vector2.new()),
  EquippedItems = Value({}),
  ItemsMenuOpen = Value(false),
  LocalPlayerData = Value({}),
  UserSettings = {
    MuteMusic = Value(false),
    HideUI = Value(false),
  },
}

function States:PushPrompt(Prompt: table)
  local PromptTemplate = {
    PromptText = "",
    Buttons = {
      {
        Primary = true,
        Content = {"Confirm"},
        Callback = function()
          
        end
      },
      {
        Primary = false,
        Content = {"Cancel"},
        Callback = function()
          
        end
      }
    },
  }
  local NewPrompts = States.Prompts:get()
  ReconcileTable(Prompt, PromptTemplate)
  for _, ExistingPrompt in ipairs(NewPrompts) do
    if ExistingPrompt.PromptText == Prompt.PromptText then
      return      
    end
  end
  table.insert(NewPrompts, Prompt)
  States.Prompts:set(NewPrompts)
end

function States:Start()
  for _, ControllerName in ipairs(CONTROLLERS) do
    self[ControllerName] = Knit.GetController(ControllerName)
  end
  for _, ServiceName in ipairs(SERVICES) do
    task.spawn(function()
      self[ServiceName] = Knit.GetService(ServiceName)
    end)
  end
  
  Hydrate(workspace.CurrentCamera) {
    [Out "ViewportSize"] = States.ScreenSize
  }
  
  Knit.OnStart():andThen(function()
    States.ItemsController.EquippedItemsUpdated:Connect(function(EquippedItems)
      States.EquippedItems:set(EquippedItems)
    end)

    States.PlayerDataService.Level:Observe(function(Level)
      local LocalPlayerData = States.LocalPlayerData:get()
      LocalPlayerData.Level = Level
      States.LocalPlayerData:set(LocalPlayerData)
    end)
  end)
end

return States