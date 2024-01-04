local RoRooms = require(script.Parent.Parent.Parent.Parent)

local Packages = RoRooms.Packages

local Component = require(Packages.Component)
local Knit = require(Packages.Knit)

local PlayerDataService = Knit.GetService("PlayerDataService")

local LevelDoor = Component.new {
  Tag = "RR_LevelDoor"
}

function LevelDoor:_UpdateOpen()
  self.Open = self.Level >= self.LevelRequirement
  self.Instance.CanCollide = not self.Open
end

function LevelDoor:_UpdateLevelRequirement()
  self.LevelRequirement = self.Instance:GetAttribute("RR_LevelRequirement") or 0
  self:_UpdateOpen()
end

function LevelDoor:Start()
  self:_UpdateOpen(false)

  PlayerDataService.Level:Observe(function(Level)
    self.Level = Level
    self:_UpdateOpen()
  end)
end

function LevelDoor:Construct()
  if not self.Instance:IsA("BasePart") then
    warn("LevelDoor must be a BasePart object --", self.Instance)
    return
  end

  self.Level = 0

  self:_UpdateLevelRequirement()
  self.Instance:GetAttributeChangedSignal("RR_LevelRequirement"):Connect(function()
    self:_UpdateLevelRequirement()
  end)
end

return LevelDoor