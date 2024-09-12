local RoRooms = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(RoRooms.Parent.OnyxUI)
local Fusion = require(RoRooms.Parent.Fusion)

local Children = Fusion.Children
local Util = OnyxUI.Util
local Themer = OnyxUI.Themer

return function(Scope: Fusion.Scope<any>, Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components)
	local Theme = Themer.Theme:now()

	local Title = Util.Fallback(Props.Title, "General")
	local Icon = Util.Fallback(Props.Icon, "rbxassetid://17266112920")
	local Name = Util.Fallback(Props.Name, "WorldsCategory")
	local Size = Util.Fallback(Props.Size, UDim2.fromScale(1, 0))
	local AutomaticSize = Util.Fallback(Props.AutomaticSize, Enum.AutomaticSize.Y)
	local LayoutOrder = Util.Fallback(Props.LayoutOrder, 0)
	local Visible = Util.Fallback(Props.Visible, true)

	return Scope:Frame(Util.CombineProps(Props, {
		Name = Name,
		Size = Size,
		AutomaticSize = AutomaticSize,
		LayoutOrder = LayoutOrder,
		Visible = Visible,
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
						Image = Icon,
						Size = Scope:Computed(function(Use)
							return UDim2.fromOffset(Use(Theme.TextSize["1"]), Use(Theme.TextSize["1"]))
						end),
					},
					Scope:Text {
						Text = Title,
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
