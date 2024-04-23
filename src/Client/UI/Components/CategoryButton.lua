local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent)

local Shared = RoRooms.Shared

local Fusion = require(Shared.ExtPackages.OnyxUI.Packages.Fusion)
local OnyxUI = require(Shared.ExtPackages.OnyxUI)
local EnsureValue = require(OnyxUI.Utils.EnsureValue)
local ColourUtils = require(OnyxUI._Packages.ColourUtils)
local Modifier = require(OnyxUI.Utils.Modifier)
local Themer = require(OnyxUI.Utils.Themer)

local Children = Fusion.Children
local Spring = Fusion.Spring
local Computed = Fusion.Computed
local Value = Fusion.Value

local BaseButton = require(OnyxUI.Components.BaseButton)
local Image = require(OnyxUI.Components.Image)

return function(Props)
	Props.Name = EnsureValue(Props.Name, "string", "CategoryButton")
	Props.Category = EnsureValue(Props.Category, "string", "Category")
	Props.Color = EnsureValue(Props.Color, "Color3", Themer.Theme.Colors.Base.Light)
	Props.Icon = EnsureValue(Props.Icon, "string", nil)
	Props.FallbackIcon = EnsureValue(Props.FallbackIcon, "string", "rbxassetid://17266112920")
	Props.OnActivated = EnsureValue(Props.OnActivated, "function", function() end)

	local IsHolding = Value(false)

	return BaseButton {
		Name = Props.Name,
		BackgroundColor3 = Spring(
			Computed(function()
				if IsHolding:get() then
					return ColourUtils.Lighten(Props.Color:get(), 0.1)
				else
					return Props.Color:get()
				end
			end),
			Themer.Theme.SpringSpeed["1"],
			Themer.Theme.SpringDampening
		),
		BackgroundTransparency = 0,
		LayoutOrder = Props.LayoutOrder,

		OnActivated = function()
			Props.OnActivated:get()()
		end,
		IsHolding = IsHolding,

		[Children] = {
			Modifier.Stroke {
				Color = Computed(function()
					return ColourUtils.Lighten(Props.Color:get(), 0.1)
				end),
			},
			Modifier.Padding {
				Padding = Computed(function()
					return UDim.new(0, Themer.Theme.Spacing["0.5"]:get())
				end),
			},
			Modifier.Corner {},

			Image {
				Name = "Icon",
				Image = Props.Icon,
				FallbackImage = Props.FallbackIcon,
				Size = Computed(function()
					return UDim2.fromOffset(Themer.Theme.TextSize["1.5"]:get(), Themer.Theme.TextSize["1.5"]:get())
				end),
				BackgroundTransparency = 1,
			},
		},
	}
end
