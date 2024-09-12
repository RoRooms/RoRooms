local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent)
local OnyxUI = require(RoRooms.Packages.OnyxUI)
local Fusion = require(RoRooms.Packages.Fusion)

local Children = Fusion.Children

return function(Scope: Fusion.Scope<any>, Props)
	local Title = Scope:EnsureValue(Props.Title, "General")
	local Icon = Scope:EnsureValue(Props.Icon, "rbxassetid://17266112920")
	local Name = Scope:EnsureValue(Props.Name, "WorldsCategory")
	local Size = Scope:EnsureValue(Props.Size, UDim2.fromScale(1, 0))
	local AutomaticSize = Scope:EnsureValue(Props.AutomaticSize, Enum.AutomaticSize.Y)
	local LayoutOrder = Scope:EnsureValue(Props.LayoutOrder, 0)
	local Visible = Scope:EnsureValue(Props.Visible, true)

	return Frame(Util.CombineProps(Props, {
		Name = Props.Name,
		Size = Props.Size,
		AutomaticSize = Props.AutomaticSize,
		LayoutOrder = Props.LayoutOrder,
		Visible = Props.Visible,
		ListEnabled = true,

		[Children] = {
			Scope:Frame {
				Name = "Title",
				ListEnabled = true,
				ListFillDirection = Enum.FillDirection.Horizontal,
				ListPadding = Scope:Computed(function(Use)
					return UDim.new(0, Use(Theme.Spacing["0.25"]))
				end),

				[Children] = {
					Scope:Icon {
						Image = Props.Icon,
						Size = Scope:Computed(function(Use)
							return UDim2.fromOffset(Use(Theme.TextSize["1"]), Use(Theme.TextSize["1"]))
						end),
					},
					Scope:Text {
						Text = Props.Title,
					},
				},
			},
			Scope:Frame {
				Name = "Contents",
				Size = UDim2.fromScale(1, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				ListEnabled = true,

				[Children] = Props[Children],
			},
		},
	}, { Children }))
end
