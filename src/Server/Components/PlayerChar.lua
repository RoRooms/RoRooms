local RoRooms = require(game:GetService("ReplicatedStorage").RoRooms)

local Shared = RoRooms.Shared

local Players = game:GetService("Players")

local Component = require(Shared.Packages.Component)

local PlayerChar = Component.new {
  Tag = "RR_PlayerChar"
}

function PlayerChar:Start()
  
end

function PlayerChar:Construct()
  self.Player = Players:GetPlayerFromCharacter(self.Instance)
  self.Humanoid = self.Instance:WaitForChild("Humanoid")
end

return PlayerChar