local RoRooms = script.Parent.Parent.Parent.Parent.Parent.Parent

return {
	Colors = {
		Primary = {
			Main = Util.Colors.Violet["400"],
		},
		Secondary = {
			Main = Util.Colors.White,
		},
		Accent = {
			Main = Util.Colors.White,
		},

		Neutral = {
			Main = Util.Colors.Slate["700"],
		},
		NeutralContent = {
			Main = Util.Colors.Slate["300"],
		},

		Base = {
			Main = Util.Colors.Slate["950"],
		},
		BaseContent = {
			Main = Util.Colors.White,
		},

		Success = {
			Main = Util.Colors.Green["500"],
		},
		Error = {
			Main = Util.Colors.Red["500"],
		},
		Warning = {
			Main = Util.Colors.Amber["500"],
		},
		Info = {
			Main = Util.Colors.Cyan["400"],
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
