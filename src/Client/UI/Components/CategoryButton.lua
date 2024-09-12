local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent)

local OnyxUI = require(RoRooms.Packages.OnyxUI)
local Fusion = require(RoRooms.Packages.Fusion)

local Children = Fusion.Children
local Util = OnyxUI.Util
local Themer = OnyxUI.Themer
local Peek = Fusion.peek

local CustomButton = require(script.Parent.CustomButton)

return function(Scope: Fusion.Scope<any>, Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components)
	local Theme = Themer.Theme:now()

	local Name = Util.Fallback(Props.Name, "CategoryButton")
	local Category = Util.Fallback(Props.Category, "Category")
	local Icon = Util.Fallback(Props.Icon, nil)
	local FallbackIcon = Util.Fallback(Props.FallbackIcon, "rbxassetid://17266112920")
	local OnActivated = Util.Fallback(Props.OnActivated, function() end)

	local IsHolding = Scope:Value(false)

	return Scope:CustomButton {
		Name = Name,
		LayoutOrder = Props.LayoutOrder,

		OnActivated = function()
			Peek(OnActivated)()
		end,
		IsHolding = IsHolding,

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
