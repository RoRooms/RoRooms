local Players = game:GetService("Players")
local RoRooms = require(game:GetService("ReplicatedStorage").RoRooms)

local Shared = RoRooms.Shared

local Component = require(Shared.Packages.Component)
local RemoteComponent = require(Shared.Packages.RemoteComponent)
local Knit = require(Shared.Packages.Knit)

local PlayerCharacter = Component.new {
  Tag = "RR_PlayerCharacter",
  Extensions = { RemoteComponent }
}
PlayerCharacter.RemoteNamespace = PlayerCharacter.Tag
PlayerCharacter.Client = {
  PlayEmote = Knit.CreateSignal()
}

function PlayerCharacter:PlayEmote(EmoteId: string, Emote: table)
  if not self.Player then return end
  self.Client.PlayEmote:Fire(self.Player, EmoteId, Emote)
  if Emote.PlayedCallback then
    Emote.PlayedCallback(self.Player, EmoteId, Emote)
  end
end

function PlayerCharacter:Start()
  
end

function PlayerCharacter:Construct()
  self.Player = Players:GetPlayerFromCharacter(self.Instance)
  self.Humanoid = self.Instance:WaitForChild("Humanoid")
end

return PlayerCharacter