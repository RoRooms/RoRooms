 local RoRooms = require(game:GetService("ReplicatedStorage").RoRooms)

local Shared = RoRooms.Shared
local Client = RoRooms.Client
local Config = RoRooms.Config

local Knit = require(Shared.Packages.Knit)
local States = require(Client.UI.States)

local EmotesMenu = require(Client.UI.ScreenGuis.EmotesMenu)

local UIController

local EmotesController = Knit.CreateController {
  Name = "EmotesController"
}

function EmotesController:PlayEmote(EmoteId: string)
  local Emote = Config.EmotesSystem.Emotes[EmoteId]
  if not Emote then return end
  local AbleToUse = false
  local FailureReason
  if Emote.RequirementCallback then
    AbleToUse, FailureReason = Emote.RequirementCallback(Knit.Player, EmoteId, Emote)
    if not AbleToUse and not FailureReason then
      FailureReason = "Insuffient requirements to use "..Emote.Name.." emote."
    end
  else
    AbleToUse = true
  end
  if AbleToUse and Emote.LevelRequirement then
    AbleToUse = States.LocalPlayerData:get().Level >= Emote.LevelRequirement
    FailureReason = not AbleToUse and Emote.Name.." emote requires level "..Emote.LevelRequirement.."."
  end
  if AbleToUse then
    local Char = Knit.Player.Character
    if Char then
      local Humanoid = Char.Humanoid
      if Humanoid then
        local HumanoidDesc = Humanoid.HumanoidDescription
        if not HumanoidDesc:GetEmotes()[EmoteId] then
          HumanoidDesc:AddEmote(EmoteId, string.gsub(Emote.Animation.AnimationId, "%D+", ""))
        end
        Humanoid:PlayEmote(EmoteId)
      end
    end
  elseif FailureReason then
    States:PushPrompt({
      PromptText = FailureReason,
      Buttons = {
        {
          Primary = false,
          Contents = {"Close"},
        },
      }
    })
  end
end

function EmotesController:KnitStart()
  UIController = Knit.GetController("UIController")

  UIController:MountUI(EmotesMenu {})
end

function EmotesController:KnitInit()
  
end

return EmotesController