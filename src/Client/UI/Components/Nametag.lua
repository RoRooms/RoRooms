local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent)

local OnyxUI = require(RoRooms.Packages.OnyxUI)
local Fusion = require(OnyxUI.Parent.Fusion)
local Themer = require(OnyxUI.Utils.Themer)

local Children = Fusion.Children
local Computed = Fusion.Computed
local Hydrate = Fusion.Hydrate

local Base = require(OnyxUI.Components.Base)
local Text = require(OnyxUI.Components.Text)

return function(Props)
	return Hydrate(Base {
		ClassName = "BillboardGui",
		Name = "Nametag",
		Parent = Props.Parent,
		Enabled = Props.Enabled,
		Size = UDim2.fromScale(5, 1.55),
		ListEnabled = true,
		ListHorizontalAlignment = Enum.HorizontalAlignment.Center,
		ListVerticalAlignment = Enum.VerticalAlignment.Bottom,
		ListPadding = Computed(function()
			return UDim.new(0, 0)
		end),

		[Children] = {
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
	}) {
		Adornee = Props.Adornee,
		StudsOffset = Vector3.new(0, 2.4, 0),
		MaxDistance = 75,
		LightInfluence = 0,
		Brightness = 1.3,
		ResetOnSpawn = false,
	}
end
