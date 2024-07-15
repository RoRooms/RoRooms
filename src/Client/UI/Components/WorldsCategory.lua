local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent)

local OnyxUI = require(RoRooms.Packages.OnyxUI)
local Fusion = require(OnyxUI.Parent.Fusion)
local EnsureValue = require(OnyxUI.Utils.EnsureValue)
local Modifier = require(OnyxUI.Utils.Modifier)
local Themer = require(OnyxUI.Utils.Themer)

local Children = Fusion.Children
local Computed = Fusion.Computed

local Frame = require(OnyxUI.Components.Frame)
local Text = require(OnyxUI.Components.Text)
local Icon = require(OnyxUI.Components.Icon)

return function(Props: { [any]: any })
	Props.Title = EnsureValue(Props.Title, "string", "General")
	Props.Icon = EnsureValue(Props.Icon, "string", "rbxassetid://17266112920")
	Props.Name = EnsureValue(Props.Name, "string", "WorldsCategory")
	Props.Size = EnsureValue(Props.Size, "UDim2", UDim2.fromScale(1, 0))
	Props.AutomaticSize = EnsureValue(Props.AutomaticSize, "EnumItem", Enum.AutomaticSize.Y)
	Props.LayoutOrder = EnsureValue(Props.LayoutOrder, "number", 0)
	Props.Visible = EnsureValue(Props.Visible, "boolean", true)

	return Frame {
		Name = Props.Name,
		Size = Props.Size,
		AutomaticSize = Props.AutomaticSize,
		LayoutOrder = Props.LayoutOrder,
		Visible = Props.Visible,

		[Children] = {
			Modifier.ListLayout {},

			Frame {
				Name = "Title",

				[Children] = {
					Modifier.ListLayout {
						FillDirection = Enum.FillDirection.Horizontal,
						Padding = Computed(function()
							return UDim.new(0, Themer.Theme.Spacing["0.25"]:get())
						end),
					},

					Icon {
						Image = Props.Icon,
						Size = Computed(function()
							return UDim2.fromOffset(Themer.Theme.TextSize["1"]:get(), Themer.Theme.TextSize["1"]:get())
						end),
					},
					Text {
						Text = Props.Title,
					},
				},
			},
			Frame {
				Name = "Contents",
				Size = UDim2.fromScale(1, 0),
				AutomaticSize = Enum.AutomaticSize.Y,

				[Children] = Props[Children],
			},
		},
	}
end
