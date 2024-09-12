local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent)

local OnyxUI = require(RoRooms.Packages.OnyxUI)
local Fusion = require(RoRooms.Packages.Fusion)

local Children = Fusion.Children

local Image = require(OnyxUI.Components.Image)
local CustomButton = require(script.Parent.CustomButton)

return function(Scope: Fusion.Scope<any>, Props)
	local Name = Scope:EnsureValue(Props.Name, "CategoryButton")
	local Category = Scope:EnsureValue(Props.Category, "Category")
	local Icon = Scope:EnsureValue(Props.Icon, nil)
	local FallbackIcon = Scope:EnsureValue(Props.FallbackIcon, "rbxassetid://17266112920")
	local OnActivated = Scope:EnsureValue(Props.OnActivated, function() end)

	local IsHolding = Scope:Value(false)

	return CustomButton {
		Name = Props.Name,
		LayoutOrder = Props.LayoutOrder,

		OnActivated = function()
			Use(Props.OnActivated)()
		end,
		IsHolding = IsHolding,

		[Children] = {
			Image {
				Name = "Icon",
				Image = Props.Icon,
				FallbackImage = Props.FallbackIcon,
				Size = Scope:Computed(function(Use)
					return UDim2.fromOffset(Theme.TextSize["1.5"]:get(), Theme.TextSize["1.5"]:get())
				end),
				BackgroundTransparency = 1,
			},
		},
	}
end
