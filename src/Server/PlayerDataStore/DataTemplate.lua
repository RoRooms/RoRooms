export type PlayerData = {
	Level: number,
	XP: number,
	MinutesSpent: number,
	Profile: {
		Nickname: string,
		Bio: string,
		Role: string?,
	},
}

local Template: PlayerData = {
	Level = 1,
	XP = 0,
	MinutesSpent = 0,
	Profile = {
		Nickname = "",
		Bio = "",
		Role = nil,
	},
}

return Template
