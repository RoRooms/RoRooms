local Rorooms = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(Rorooms.Parent.OnyxUI)
local Fusion = require(Rorooms.Parent.Fusion)
local Components = require(Rorooms.SourceCode.Client.UI.Components)
local States = require(Rorooms.SourceCode.Client.UI.States)

local Children = Fusion.Children

export type Props = {
	Parent: Fusion.UsedAs<Instance>?,
}

return function(Scope: Fusion.Scope<typeof(Fusion)>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components, Components)
	local Theme = OnyxUI.Themer.Theme:now()

	local GlowIntensity = Scope:Value(0)

	local Thread = task.spawn(function()
		while true do
			GlowIntensity:set(1)
			task.wait(1)
			GlowIntensity:set(0)
			task.wait(1)
		end
	end)

	table.insert(Scope, function()
		task.cancel(Thread)
	end)

	return Scope:New "ScreenGui" {
		Name = script.Name,
		Parent = Props.Parent,
		ScreenInsets = Enum.ScreenInsets.None,
		DisplayOrder = 10000,

		[Children] = {
			Scope:Group {
				BackgroundTransparency = 0,
				BackgroundColor3 = OnyxUI.Util.Colors.Black,
				Size = UDim2.fromScale(1, 1),
				Active = States.Loading,
				GroupTransparency = Scope:Spring(
					Scope:Computed(function(Use)
						return (Use(States.Loading) and 0) or 1
					end),
					Theme.SpringSpeed["0.5"],
					Theme.SpringDampening["1.5"]
				),

				[Children] = {
					Scope:Frame {
						BackgroundTransparency = 0,
						BackgroundColor3 = OnyxUI.Util.Colors.Black,
						Size = UDim2.fromScale(1, 1),

						[Children] = {
							Scope:Frame {
								AnchorPoint = Vector2.new(0.5, 0.5),
								Position = UDim2.fromScale(0.5, 0.5),
								ListEnabled = true,
								ListHorizontalAlignment = Enum.HorizontalAlignment.Center,

								[Children] = {
									Scope:Icon {
										Image = "rbxassetid://97237065883195",
										Size = Scope:Computed(function(Use)
											local Offset = Use(Theme.Spacing["8"])
											return UDim2.fromOffset(Offset, Offset)
										end),
										ImageColor3 = Color3.fromHex("8566FF"),
										GradientEnabled = true,
										GradientTransparency = NumberSequence.new({
											NumberSequenceKeypoint.new(0, 0),
											NumberSequenceKeypoint.new(1, 0.5),
										}),
										GradientRotation = Scope:Spring(
											Scope:Computed(function(Use)
												local GlowIntensityValue = Use(GlowIntensity)
												return GlowIntensityValue * 360
											end),
											6,
											Theme.SpringDampening["1.5"]
										),
									},
								},
							},
						},
					},
				},
			},
		},
	}
end
