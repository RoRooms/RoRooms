local Players = game:GetService("Players")
local RoRooms = require(game:GetService("ReplicatedStorage").RoRooms)

local Shared = RoRooms.Shared
local Packages = RoRooms.Packages

local Component = require(Packages.Component)
local RemoteComponent = require(Packages.RemoteComponent)

local PlayerCharacter = Component.new {
  Tag = "RR_PlayerCharacter",
  Extensions = { RemoteComponent }
}
PlayerCharacter.RemoteNamespace = PlayerCharacter.Tag

function PlayerCharacter:_PlayEmote(EmoteId: string, Emote: table)
  if self.Player ~= Players.LocalPlayer then return end
  if not self.Humanoid then return end
  local HumanoidDescription = self.Humanoid.HumanoidDescription
  if not HumanoidDescription:GetEmotes()[EmoteId] then
    HumanoidDescription:AddEmote(EmoteId, string.gsub(Emote.Animation.AnimationId, "%D+", ""))
  end
  self.Humanoid:PlayEmote(EmoteId)
end

function PlayerCharacter:Start()
  self.Server.PlayEmote:Connect(function(EmoteId: string, Emote: table)
    self:_PlayEmote(EmoteId, Emote)
  end)
end

function PlayerCharacter:Construct()
  self.Player = Players:GetPlayerFromCharacter(self.Instance)
  self.Humanoid = self.Instance:WaitForChild("Humanoid")
end

return PlayerCharacter