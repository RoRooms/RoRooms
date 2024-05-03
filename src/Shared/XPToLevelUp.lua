local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent)

local CURVE_MULTIPLIER = 0.85

return function(Level: number)
	Level = math.floor(Level)
	local Result = RoRooms.Config.Systems.Leveling.BaseLevelUpXP * (CURVE_MULTIPLIER * ((Level % 5) + (Level / 5)))
	if Result > 0 then
		return Result
	else
		return RoRooms.Config.Systems.Leveling.BaseLevelUpXP
	end
end
