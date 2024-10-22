local RoRooms = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(RoRooms.Parent.OnyxUI)
local Fusion = require(RoRooms.Parent.Fusion)
local Assets = require(RoRooms.SourceCode.Shared.Assets)

local Children = Fusion.Children

local OnyxUIFolder = RoRooms.Parent._Index["imavafe_onyx-ui@0.4.3"]["onyx-ui"]
local Avatar = require(OnyxUIFolder.Components.Avatar)

export type Props = Avatar.Props & {
	Disabled: Fusion.UsedAs<boolean>?,
	Image: Fusion.UsedAs<string>?,
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Components, OnyxUI.Util)
	local Theme = OnyxUI.Themer.Theme:now()

	local Disabled = OnyxUI.Util.Fallback(Props.Disabled, false)
	local Image = OnyxUI.Util.Fallback(Props.Image, "")

	local IsHovering = Scope:Value(false)
	local IsHolding = Scope:Value(false)

	return Scope:BaseButton(OnyxUI.Util.CombineProps(Props, {
		Name = "EditableAvatar",
		Disabled = Disabled,
		CornerRadius = Scope:Computed(function(Use)
			return UDim.new(0, Use(Theme.CornerRadius.Full))
		end),

		IsHolding = IsHolding,
		IsHovering = IsHovering,

		[Children] = {
			Scope:Avatar {
				Image = Image,
				ImageTransparency = Scope:Spring(
					Scope:Computed(function(Use)
						if Use(Disabled) then
							return 0
						elseif Use(IsHolding) then
							return Use(Theme.Emphasis.Strong) * 1.25
						elseif Use(IsHovering) then
							return Use(Theme.Emphasis.Strong)
						else
							return 0
						end
					end),
					Theme.SpringSpeed["0.5"],
					Theme.SpringDampening["1"]
				),
				Size = Scope:Computed(function(Use)
					local Offset = Use(Theme.TextSize["4.5"])
					return UDim2.fromOffset(Offset, Offset)
				end),
				CornerRadius = Scope:Computed(function(Use)
					return UDim.new(0, Use(Theme.CornerRadius.Full))
				end),
				RingEnabled = true,
				RingColor = Theme.Colors.Base.Main,
				RingThickness = Theme.StrokeThickness["4"],

				[Children] = {
					Scope:Icon {
						AnchorPoint = Vector2.new(0.5, 0.5),
						Position = UDim2.fromScale(0.5, 0.5),
						Image = Assets.Icons.General.EditPerson,
						Size = Scope:Computed(function(Use)
							local Offset = Use(Theme.TextSize["3"])
							return UDim2.fromOffset(Offset, Offset)
						end),
						ImageTransparency = Scope:Spring(
							Scope:Computed(function(Use)
								if Use(Disabled) then
									return 1
								elseif Use(IsHolding) then
									return Use(Theme.Emphasis.Regular)
								elseif Use(IsHovering) then
									return 0
								else
									return 1
								end
							end),
							Theme.SpringSpeed["0.5"],
							Theme.SpringDampening["1"]
						),
					},
				},
			},
		},
	}, { "Image" }))
end
