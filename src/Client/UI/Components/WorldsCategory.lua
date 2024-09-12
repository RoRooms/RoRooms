local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent)
local OnyxUI = require(RoRooms.Packages.OnyxUI)
local Fusion = require(RoRooms.Packages.Fusion)

local Children = Fusion.Children

local Frame = require(OnyxUI.Components.Frame)
local Text = require(OnyxUI.Components.Text)
local Icon = require(OnyxUI.Components.Icon)

return function(Props: { [any]: any })
	local Title = Scope:EnsureValue(Props.Title, "General")
	local Icon = Scope:EnsureValue(Props.Icon, "rbxassetid://17266112920")
	local Name = Scope:EnsureValue(Props.Name, "WorldsCategory")
	local Size = Scope:EnsureValue(Props.Size, UDim2.fromScale(1, 0))
	local AutomaticSize = Scope:EnsureValue(Props.AutomaticSize, Enum.AutomaticSize.Y)
	local LayoutOrder = Scope:EnsureValue(Props.LayoutOrder, 0)
	local Visible = Scope:EnsureValue(Props.Visible, true)

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
