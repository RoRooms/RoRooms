local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent.Parent)

local Shared = RoRooms.Shared

local OnyxUI = require(Shared.ExtPackages.OnyxUI)
local Colors = require(OnyxUI.Utils.Colors)

return {
	Colors = {
		Primary = {
			Main = Colors.White,
		},
		Secondary = {
			Main = Colors.White,
		},
		Accent = {
			Main = Colors.White,
		},

		Neutral = {
			Main = Colors.Stone["700"],
		},
		NeutralContent = {
			Main = Colors.Stone["300"],
		},

		Base = {
			Main = Colors.Black,
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
		Body = "rbxasset://fonts/families/Montserrat.json",
		Heading = "rbxasset://fonts/families/Montserrat.json",
		Monospace = "rbxasset://fonts/families/Montserrat.json",
	},
	FontWeight = {
		Body = Enum.FontWeight.SemiBold,
		Bold = Enum.FontWeight.SemiBold,
		Heading = Enum.FontWeight.SemiBold,
	},
	TextSize = {
		Base = 16,
	},
	CornerRadius = {
		Base = 6,
	},
	StrokeThickness = {
		Base = 1,
	},
	Spacing = {
		Base = 14,
	},
	SpringSpeed = {
		Base = 50,
	},
	SpringDampening = 1,
	Sound = {},
}
