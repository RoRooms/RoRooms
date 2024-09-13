local RoRooms = script.Parent.Parent.Parent
local Config = require(RoRooms.Config)

local CURVE_MULTIPLIER = 0.85

return function(Level: number)
	Level = math.floor(Level)
	local Result = Config.Systems.Leveling.BaseLevelUpXP * (CURVE_MULTIPLIER * ((Level % 5) + (Level / 5)))
	if Result > 0 then
		return Result
	else
		return Config.Systems.Leveling.BaseLevelUpXP
	end
end
