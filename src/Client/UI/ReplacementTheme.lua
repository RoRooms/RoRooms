local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent.Parent)

local OnyxUI = require(RoRooms.Packages.OnyxUI)
local Colors = require(OnyxUI.Utils.Colors)

return {
	Colors = {
		Primary = {
			Main = Colors.Violet["400"],
		},
		Secondary = {
			Main = Colors.White,
		},
		Accent = {
			Main = Colors.White,
		},

		Neutral = {
			Main = Colors.Slate["700"],
		},
		NeutralContent = {
			Main = Colors.Slate["300"],
		},

		Base = {
			Main = Colors.Slate["950"],
		},
		BaseContent = {
			Main = Colors.White,
		},

		Success = {
			Main = Colors.Green["500"],
		},
		Error = {
			Main = Colors.Red["500"],
		},
		Warning = {
			Main = Colors.Amber["500"],
		},
		Info = {
			Main = Colors.Cyan["400"],
		},
	},
	Font = {
		Body = "rbxasset://fonts/families/FredokaOne.json",
		Heading = "rbxasset://fonts/families/FredokaOne.json",
		Monospace = "rbxasset://fonts/families/FredokaOne.json",
	},
	FontWeight = {
		Body = Enum.FontWeight.Regular,
		Bold = Enum.FontWeight.Regular,
		Heading = Enum.FontWeight.Regular,
	},
	TextSize = {
		Base = 16,
	},
	CornerRadius = {
		Base = 10,
	},
	StrokeThickness = {
		Base = 2,
	},
	Spacing = {
		Base = 18,
	},
	SpringSpeed = {
		Base = 25,
	},
	SpringDampening = 1,
	Sound = {},
}
