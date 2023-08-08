local SharedData = require(script.Parent)

local BASE_XP = SharedData.BaseLevelUpXP
local CURVE_MULTIPLIER = 0.85

return function(Level: number)
  Level = math.floor(Level)
  local Result = BASE_XP * (CURVE_MULTIPLIER * ((Level % 5) + (Level / 5)))
  if Result > 0 then
    return Result
  else
    return BASE_XP
  end
end