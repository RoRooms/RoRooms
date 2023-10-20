local RoRooms = require(game:GetService("ReplicatedStorage").RoRooms)

local Shared = RoRooms.Shared
local Client = RoRooms.Client

local Knit = require(Shared.Packages.Knit)
local States = require(Client.UI.States)

local EmotesMenu = require(Client.UI.ScreenGuis.EmotesMenu)

local UIController
local EmotesService

local EmotesController = Knit.CreateController {
  Name = "EmotesController"
}

function EmotesController:PlayEmote(EmoteId: string)
  EmotesService:PlayEmote(EmoteId):andThen(function(FailureReason: string)
    if typeof(FailureReason) == "string" then
      States:PushPrompt({
        Title = "Failure",
        Text = FailureReason,
        Buttons = {
          {
            Primary = false,
            Contents = {"Close"},
          },
        }
      })
    end
  end)
end

function EmotesController:KnitStart()
  UIController = Knit.GetController("UIController")
  EmotesService = Knit.GetService("EmotesService")

  UIController:MountUI(EmotesMenu {})
end

function EmotesController:KnitInit()
  
end

return EmotesController