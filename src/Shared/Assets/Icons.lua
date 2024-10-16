type Entry = string | { [string]: Entry }
type Icons = {
	[string]: Entry,
}

local Icons: Icons = {
	UserBadges = {
		Level = "rbxassetid://122517370340800",
		RoRooms = "rbxassetid://74362866882865",
		RoRoomsPlus = "rbxassetid://98919849651582",
		ServerOwner = "rbxassetid://81805631752548",
		WorldBuilder = "rbxassetid://72011443469820",
	},
	Topbar = {
		Settings = {
			Outlined = "rbxassetid://17273236509",
			Filled = "rbxassetid://17273236289",
		},
		Emotes = {
			Outlined = "rbxassetid://17273236115",
			Filled = "rbxassetid://17273235955",
		},
		Friends = {
			Outlined = "rbxassetid://17273235804",
			Filled = "rbxassetid://17273235655",
		},
		Profile = {
			Outlined = "rbxassetid://17273235245",
			Filled = "rbxassetid://17273235099",
		},
		Worlds = {
			Outlined = "rbxassetid://17273758646",
			Filled = "rbxassetid://17273758509",
		},
	},
	Categories = {
		General = "rbxassetid://95481915912759",
		Unlockable = "rbxassetid://77461748250230",
		Robux = "rbxassetid://99123446894867",
	},
	General = {
		Star = "rbxassetid://83817680628522",
		People = "rbxassetid://17292608258",
		Die = "rbxassetid://118190044173329",
		Play = "rbxassetid://123620451031434",
		Download = "rbxassetid://104837841407693",
		Repeat = "rbxassetid://134886588139690",
		Checkmark = "rbxassetid://71597564625336",
		Warning = "rbxassetid://89090528985052",
		Person = "rbxassetid://95694895434247",
		EditPerson = "rbxassetid://108466250207627",
		Toolbox = "rbxassetid://129909469212402",
	},
}

return Icons
