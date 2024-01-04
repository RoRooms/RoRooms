local RoRooms = require(game:GetService("ReplicatedStorage").RoRooms)

local Shared = RoRooms.Shared
local Packages = RoRooms.Packages

local Component = require(Packages.Component)
local Zone = require(Shared.ExtPackages.Zone)
local Knit = require(Packages.Knit)

local PlayerDataService = Knit.GetService("PlayerDataService")

local LevelZone = Component.new {
  Tag = "RR_LevelZone"
}

function LevelZone:_UpdateLevelRequirement()
  self.LevelRequirement = self.Instance:GetAttribute("RR_LevelRequirement") or 0
end

function LevelZone:Start()
  self.Zone.playerEntered:Connect(function(Player: Player)
    local Profile = PlayerDataService:GetProfile(Player)
    if Profile then
      if Profile.Data.Level < self.LevelRequirement then
        Player:LoadCharacter()
      end
    end
  end)
end

function LevelZone:Construct()
  self:_UpdateLevelRequirement()
  self.Instance:GetAttributeChangedSignal("RR_LevelRequirement"):Connect(function()
    self:_UpdateLevelRequirement() 
  end)

  self.Zone = Zone.new(self.Instance)
  self.Zone:setAccuracy("Low")
end

return LevelZone