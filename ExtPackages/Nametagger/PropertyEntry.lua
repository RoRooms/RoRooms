local RoRooms = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(RoRooms.Parent.OnyxUI)
local Fusion = require(RoRooms.Parent.Fusion)
local OnyxUIFolder = RoRooms.Parent._Index["imavafe_onyx-ui@0.4.1"]["onyx-ui"]

local Children = Fusion.Children
local Themer = OnyxUI.Themer
local Util = OnyxUI.Util

local Frame = require(OnyxUIFolder.Components.Frame)
local TagText = require(script.Parent.TagText)

export type Props = Frame.Props & {
	Value: Fusion.UsedAs<any>,
	Image: Fusion.UsedAs<string>?,
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, Util, OnyxUI.Components, {
		TagText = TagText,
	})
	local Theme = Themer.Theme:now()

	local ValueProp = Util.Fallback(Props.Value, nil)
	local Image = Util.Fallback(Props.Image, nil)

	return Scope:Frame(Util.CombineProps(Props, {
		Name = script.Name,
		ListEnabled = true,
		ListFillDirection = Enum.FillDirection.Horizontal,
		ListPadding = Scope:Computed(function(Use)
			return UDim.new(0, Use(Theme.Spacing["0.25"]) / 2)
		end),

		[Children] = {
			Scope:Computed(function(Use)
				if Use(Image) then
					return Scope:Icon {
						Image = Image,
						Size = Scope:Computed(function(Use)
							local Offset = Use(Theme.TextSize["0.875"])
							return UDim2.fromOffset(Offset, Offset)
						end),
					}
				else
					return
				end
			end),
			Scope:TagText {
				Name = "Value",
				Text = Scope:Computed(function(Use)
					return tostring(Use(ValueProp)) or ""
				end),
				TextSize = Theme.TextSize["0.875"],
				StrokeEnabled = false,
			},
		},
	}))
end
