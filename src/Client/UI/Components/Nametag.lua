local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent)

local OnyxUI = require(RoRooms.Packages.OnyxUI)
local Fusion = require(RoRooms.Packages.Fusion)

local Children = Fusion.Children
local Util = OnyxUI.Util

return function(Scope: Fusion.Scope<any>, Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components)
	local Theme = Themer.Theme:now()

	return Scope:Hydrate(Scope:Base {
		ClassName = "BillboardGui",
		Name = "Nametag",
		Parent = Props.Parent,
		Enabled = Props.Enabled,
		Size = UDim2.fromScale(5, 1.55),
		ListEnabled = true,
		ListHorizontalAlignment = Enum.HorizontalAlignment.Center,
		ListVerticalAlignment = Enum.VerticalAlignment.Bottom,
		ListPadding = Scope:Computed(function(Use)
			return UDim.new(0, 0)
		end),

		[Children] = {
			Scope:Text {
				Name = "Nickname",
				Text = Props.Nickname,
				Visible = Scope:Computed(function(Use)
					return Use(Props.Nickname) ~= ""
				end),
				Size = UDim2.fromScale(1, 0.45),
				AutomaticSize = Enum.AutomaticSize.None,
				TextScaled = true,
				FontFace = Scope:Computed(function(Use)
					return Font.new(Use(Theme.Font.Heading), Use(Theme.FontWeight.Heading))
				end),
				RichText = false,
				TextXAlignment = Enum.TextXAlignment.Center,
				TextYAlignment = Enum.TextYAlignment.Bottom,
			},
			Scope:Text {
				Name = "Status",
				Text = Props.Status,
				Visible = Scope:Computed(function(Use)
					return Use(Props.Status) ~= ""
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
