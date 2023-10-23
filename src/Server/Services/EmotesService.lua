local RoRooms = require(game:GetService("ReplicatedStorage").RoRooms)

local Shared = RoRooms.Shared
local Config = RoRooms.Config
local Server = RoRooms.Server

local Knit = require(Shared.Packages.Knit)

local PlayerCharacterComponent = require(Server.Components.PlayerCharacter)
local PlayerDataService = require(Server.Services.PlayerDataService)

local EmotesService = {
  Name = "EmotesService",
  Client = {}
}

function EmotesService.Client:PlayEmote(Player: Player, EmoteId: string)
  local Emote = Config.EmotesSystem.Emotes[EmoteId]
  if not Emote then return end

  local AbleToUse = true
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
    local Profile = PlayerDataService:GetProfile(Player)
    if Profile then
      AbleToUse = Profile.Data.Level >= Emote.LevelRequirement
    else
      AbleToUse = false
    end
    FailureReason = not AbleToUse and Emote.Name.." emote requires level "..Emote.LevelRequirement.."."
  end

  if AbleToUse then
    local Character = Player.Character
    if Character then
      local CharacterClass = PlayerCharacterComponent:FromInstance(Character)
      if CharacterClass then
        CharacterClass:PlayEmote(EmoteId, Emote)
      end
    end
  elseif FailureReason then
    return FailureReason
  end
end

function EmotesService:KnitStart()
  
end

function EmotesService:KnitInit()
  
end

return EmotesService