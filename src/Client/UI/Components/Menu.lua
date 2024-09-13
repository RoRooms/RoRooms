local RoRooms = script.Parent.Parent.Parent.Parent.Parent
local Fusion = require(RoRooms.Parent.Fusion)
local OnyxUI = require(RoRooms.Parent.OnyxUI)
local States = require(RoRooms.SourceCode.Client.UI.States)

local Children = Fusion.Children
local Themer = OnyxUI.Themer
local Util = OnyxUI.Util

export type Props = {
	Name: Fusion.UsedAs<string>?,
	Open: Fusion.UsedAs<boolean>?,
	Size: Fusion.UsedAs<UDim2>?,
	AutomaticSize: Fusion.UsedAs<Enum.AutomaticSize>?,
	ListFillDirection: Fusion.UsedAs<Enum.FillDirection>?,

	[typeof(Children)]: { any },
}

return function(Scope: Fusion.Scope<any>, Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components)
	local Theme = Themer.Theme:now()

	local Name = Util.Fallback(Props.Name, "Menu")
	local Open = Util.Fallback(Props.Open, false)
	local AnchorPoint = Util.Fallback(Props.AnchorPoint, Vector2.new(0.5, 0))
	local Position = Util.Fallback(
		Props.Position,
		Scope:Computed(function(Use)
			local YPos = Use(States.TopbarBottomPos)
			if not Use(Open) then
				YPos = YPos + 15
			end
			return UDim2.new(UDim.new(0.5, 0), UDim.new(0, YPos))
		end)
	)
	local Size = Util.Fallback(Props.Size, UDim2.fromOffset(0, 0))
	local AutomaticSize = Util.Fallback(Props.AutomaticSize, Enum.AutomaticSize.Y)
	local ListFillDirection = Util.Fallback(Props.ListFillDirection, Enum.FillDirection.Vertical)

	return Scope:New "ScreenGui" {
		Name = Name,
		Parent = Props.Parent,
		Enabled = Open,
		ResetOnSpawn = false,

		[Children] = {
			Scope:AutoScaleFrame {
				AnchorPoint = AnchorPoint,
				Position = Scope:Spring(Position, Theme.SpringSpeed["1"], Theme.SpringDampening["1.5"]),
				BaseResolution = Vector2.new(739, 789),
				MinScale = 1,
				MaxScale = 1,

				[Children] = {
					Scope:MenuFrame {
						Size = Size,
						AutomaticSize = AutomaticSize,
						GroupTransparency = Scope:Spring(
							Scope:Computed(function(Use)
								if Use(Open) then
									return 0
								else
									return 1
								end
							end),
							Theme.SpringSpeed["1"],
							Theme.SpringDampening["1"]
						),
						BackgroundTransparency = States.PreferredTransparency,
						ListEnabled = true,
						ListFillDirection = ListFillDirection,

						[Children] = Props[Children],
					},
				},
			},
		},
	}
end
