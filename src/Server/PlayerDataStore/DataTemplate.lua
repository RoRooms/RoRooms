export type PlayerData = {
	Level: number,
	XP: number,
	MinutesSpent: number,
	Profile: {
		Nickname: string,
		Status: string,
		Role: string?,
	},
}

local Template: PlayerData = {
	Level = 1,
	XP = 0,
	MinutesSpent = 0,
	Profile = {
		Nickname = "",
		Status = "",
		Role = nil,
	},
}

return Template
