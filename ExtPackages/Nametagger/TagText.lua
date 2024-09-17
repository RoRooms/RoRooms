local RoRooms = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(RoRooms.Parent.OnyxUI)
local Fusion = require(RoRooms.Parent.Fusion)
local OnyxUIFolder = RoRooms.Parent._Index["imavafe_onyx-ui@0.4.3"]["onyx-ui"]

local Util = OnyxUI.Util

local Text = require(OnyxUIFolder.Components.Text)

export type Props = Text.Props & {}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Components)

	return Scope:Text(Util.CombineProps(Props, {
		Name = script.Name,
		TextColor3 = Util.Colors.White,
		TextWrapped = false,
		RichText = false,
		ClipsDescendants = false,
		StrokeThickness = 1,
		StrokeColor = Util.Colors.Black,
		StrokeTransparency = 0.5,
		StrokeApplyStrokeMode = Enum.ApplyStrokeMode.Contextual,
	}))
end
