local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent.Parent)

local OnyxUI = require(RoRooms.Packages.OnyxUI)
local Colors = require(OnyxUI.Utils.Colors)
local Fusion = require(OnyxUI.Parent.Fusion)

local New = Fusion.New

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
			Main = Colors.Stone["800"],
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
		Bold = Enum.FontWeight.Bold,
		Heading = Enum.FontWeight.Bold,
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
	Sound = {
		Hover = New "Sound" {
			SoundId = "rbxassetid://10066936758",
			Volume = 0,
		},
		Click = New "Sound" {
			SoundId = "rbxassetid://16480549841",
			Volume = 0,
		},
		Focus = New "Sound" {
			SoundId = "rbxassetid://16480549841",
			Volume = 0,
		},
		Switch = New "Sound" {
			SoundId = "rbxassetid://9119713951",
			Volume = 0,
		},
	},
}
