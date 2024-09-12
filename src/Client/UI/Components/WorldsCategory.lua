local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent)
local OnyxUI = require(RoRooms.Packages.OnyxUI)
local Fusion = require(RoRooms.Packages.Fusion)

local Children = Fusion.Children

local Frame = require(OnyxUI.Components.Frame)
local Text = require(OnyxUI.Components.Text)
local Icon = require(OnyxUI.Components.Icon)

return function(Props: { [any]: any })
	Props.Title = Scope:EnsureValue(Props.Title, "string", "General")
	Props.Icon = Scope:EnsureValue(Props.Icon, "string", "rbxassetid://17266112920")
	Props.Name = Scope:EnsureValue(Props.Name, "string", "WorldsCategory")
	Props.Size = Scope:EnsureValue(Props.Size, "UDim2", UDim2.fromScale(1, 0))
	Props.AutomaticSize = Scope:EnsureValue(Props.AutomaticSize, "EnumItem", Enum.AutomaticSize.Y)
	Props.LayoutOrder = Scope:EnsureValue(Props.LayoutOrder, "number", 0)
	Props.Visible = Scope:EnsureValue(Props.Visible, "boolean", true)

	return Frame(CombineProps(Props, {
		Name = Props.Name,
		Size = Props.Size,
		AutomaticSize = Props.AutomaticSize,
		LayoutOrder = Props.LayoutOrder,
		Visible = Props.Visible,
		ListEnabled = true,

		[Children] = {
			Frame {
				Name = "Title",
				ListEnabled = true,
				ListFillDirection = Enum.FillDirection.Horizontal,
				ListPadding = Scope:Computed(function(Use)
					return UDim.new(0, Theme.Spacing["0.25"]:get())
				end),

				[Children] = {
					Icon {
						Image = Props.Icon,
						Size = Scope:Computed(function(Use)
							return UDim2.fromOffset(Theme.TextSize["1"]:get(), Theme.TextSize["1"]:get())
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
				ListEnabled = true,

				[Children] = Props[Children],
			},
		},
	}, { Children }))
end
