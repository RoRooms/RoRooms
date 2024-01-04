local RoRooms = require(script.Parent.Parent.Parent.Parent)

local Client = RoRooms.Client
local Packages = RoRooms.Packages

local Knit = require(Packages.Knit)
local States = require(Client.UI.States)

local EmotesMenu = require(Client.UI.ScreenGuis.EmotesMenu)

local UIController = require(Client.Controllers.UIController)
local EmotesService

local EmotesController = {
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