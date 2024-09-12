local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent)

local OnyxUI = require(RoRooms.Packages.OnyxUI)
local Fusion = require(RoRooms.Packages.Fusion)

local Children = Fusion.Children
local Computed = Fusion.Computed
local Value = Fusion.Value

local Image = require(OnyxUI.Components.Image)
local CustomButton = require(script.Parent.CustomButton)

return function(Props)
	Props.Name = EnsureValue(Props.Name, "string", "CategoryButton")
	Props.Category = EnsureValue(Props.Category, "string", "Category")
	Props.Icon = EnsureValue(Props.Icon, "string", nil)
	Props.FallbackIcon = EnsureValue(Props.FallbackIcon, "string", "rbxassetid://17266112920")
	Props.OnActivated = EnsureValue(Props.OnActivated, "function", function() end)

	local IsHolding = Value(false)

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
				Size = Computed(function(Use)
					return UDim2.fromOffset(Theme.TextSize["1.5"]:get(), Theme.TextSize["1.5"]:get())
				end),
				BackgroundTransparency = 1,
			},
		},
	}
end
