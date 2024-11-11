local XPToLevelUp = require(script.Parent.XPToLevelUp)

return function(GoalLevel: number)
  local Level = 0
  local TotalXP = 0
  for _ = 0, GoalLevel do
    TotalXP += XPToLevelUp(Level)
    Level += 1
  end
  return TotalXP
end