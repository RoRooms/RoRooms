local RoRooms = script.Parent.Parent.Parent.Parent
local OnyxUI = require(RoRooms.Parent.OnyxUI)
local Fusion = require(RoRooms.Parent.Fusion)
local ColorUtils = require(RoRooms.Parent.ColorUtils)

local Util = OnyxUI.Util
local Themer = OnyxUI.Themer

local Scope = Fusion.scoped(Fusion)

return Themer.NewTheme(Scope, {
	Colors = {
		Primary = {
			Main = Util.Colors.White,
		},
		Secondary = {
			Main = Util.Colors.White,
		},
		Accent = {
			Main = Util.Colors.White,
		},

		Neutral = {
			Main = ColorUtils.Lighten(Util.Colors.Stone["800"], 0.1),
		},
		NeutralContent = {
			Main = Util.Colors.Stone["300"],
		},

		Base = {
			Main = Util.Colors.Black,
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
		Base = 60,
	},
	SpringDampening = {
		Base = 1.25,
	},
	Sound = {
		Hover = Scope:New "Sound" {
			SoundId = "rbxassetid://10066936758",
			Volume = 0,
		},
		Click = Scope:New "Sound" {
			SoundId = "rbxassetid://16480549841",
			Volume = 0,
		},
		Focus = Scope:New "Sound" {
			SoundId = "rbxassetid://16480549841",
			Volume = 0,
		},
		Switch = Scope:New "Sound" {
			SoundId = "rbxassetid://9119713951",
			Volume = 0,
		},
	},
	Emphasis = {
		Light = 0.1,
		Regular = 0.15,
		Strong = 0.5,
		Contrast = 1,
	},
})
