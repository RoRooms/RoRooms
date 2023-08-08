local ValueClassNames = {
  int = "IntValue",
  number = "NumberValue",
  string = "StringValue",
  boolean = "BoolValue",
  Instance = "ObjectValue",
  BrickColor = "BrickColorValue",
  Color3 = "Color3Value",
  Vector3 = "Vector3Value",
}

local InternalLeaderStats = {}

local LeaderStats = {}
LeaderStats.__index = LeaderStats

function LeaderStats.New(Player: Player)
  local self = {}
  setmetatable(self, LeaderStats)

  self.Player = Player
  self.StatValues = {}

  self.LeaderStatsFolder = Instance.new("Folder")
  self.LeaderStatsFolder.Name = "leaderstats"
  self.LeaderStatsFolder.Parent = self.Player

  InternalLeaderStats[Player] = self
  return self
end

function LeaderStats:Get(Player: Player)
  return InternalLeaderStats[Player]
end

function LeaderStats:Destroy()
  InternalLeaderStats[self.Player] = nil
  self.LeaderStatsFolder:Destroy()
  self = nil
end

function LeaderStats:SetStat(StatName: string, Value: any)
  local Stat = self.StatValues[StatName]
  if Stat == nil then
      Stat = Instance.new(ValueClassNames[typeof(Value)])
      Stat.Name = StatName
      Stat.Parent = self.LeaderStatsFolder
      self.StatValues[StatName] = Stat
  end
  if Value then
      Stat.Value = Value
  else
      Stat:Destroy()
  end
end

function LeaderStats:GetStat(StatName: string)
  local Stat = self.StatValues[StatName]
  return Stat
end

return LeaderStats