local RoRooms = script.Parent.Parent.Parent.Parent.Parent

local OnyxUI = require(RoRooms.Parent.OnyxUI)
local Fusion = require(RoRooms.Parent.Fusion)

local Children = Fusion.Children
local Util = OnyxUI.Util
local Themer = OnyxUI.Themer
local Peek = Fusion.peek

local CustomButton = require(script.Parent.CustomButton)

return function(Scope: Fusion.Scope<any>, Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components, {
		CustomButton = CustomButton,
	})
	local Theme = Themer.Theme:now()

	local Name = Util.Fallback(Props.Name, "CategoryButton")
	local Icon = Util.Fallback(Props.Icon, nil)
	local FallbackIcon = Util.Fallback(Props.FallbackIcon, "rbxassetid://17266112920")
	local OnActivated = Util.Fallback(Props.OnActivated, function() end)

	return Scope:CustomButton {
		Name = Name,
		LayoutOrder = Props.LayoutOrder,

		OnActivated = function()
			Peek(OnActivated)()
		end,

		[Children] = {
			Scope:Image {
				Name = "Icon",
				Image = Icon,
				FallbackImage = FallbackIcon,
				Size = Scope:Computed(function(Use)
					return UDim2.fromOffset(Use(Theme.TextSize["1.5"]), Use(Theme.TextSize["1.5"]))
				end),
				BackgroundTransparency = 1,
			},
		},
	}
end
