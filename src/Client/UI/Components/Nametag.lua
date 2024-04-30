local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent)

local Shared = RoRooms.Shared

local OnyxUI = require(RoRooms.Packages.OnyxUI)
local Fusion = require(OnyxUI.Packages.Fusion)
local Themer = require(OnyxUI.Utils.Themer)
local Modifier = require(OnyxUI.Utils.Modifier)

local New = Fusion.New
local Children = Fusion.Children
local Computed = Fusion.Computed

local Text = require(OnyxUI.Components.Text)

return function(Props)
	return New "BillboardGui" {
		Name = "Nametag",
		Parent = Props.Parent,
		Adornee = Props.Adornee,
		Enabled = Props.Enabled,
		Size = UDim2.fromScale(5, 1.55),
		StudsOffset = Vector3.new(0, 2.4, 0),
		MaxDistance = 75,
		LightInfluence = 0,
		Brightness = 1.3,
		ResetOnSpawn = false,

		[Children] = {
			Modifier.ListLayout {
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Bottom,
				Padding = Computed(function()
					return UDim.new(0, 0)
				end),
			},

			Text {
				Name = "Nickname",
				Text = Props.Nickname,
				Visible = Computed(function()
					return Props.Nickname:get() ~= ""
				end),
				Size = UDim2.fromScale(1, 0.45),
				AutomaticSize = Enum.AutomaticSize.None,
				TextScaled = true,
				FontFace = Computed(function()
					return Font.new(Themer.Theme.Font.Heading:get(), Themer.Theme.FontWeight.Heading:get())
				end),
				RichText = false,
				TextXAlignment = Enum.TextXAlignment.Center,
				TextYAlignment = Enum.TextYAlignment.Bottom,
			},
			Text {
				Name = "Status",
				Text = Props.Status,
				Visible = Computed(function()
					return Props.Status:get() ~= ""
				end),
				Size = UDim2.fromScale(1, 0.25),
				AutomaticSize = Enum.AutomaticSize.None,
				TextScaled = true,
				RichText = false,
				TextXAlignment = Enum.TextXAlignment.Center,
				TextYAlignment = Enum.TextYAlignment.Bottom,
			},
		},
	}
end
