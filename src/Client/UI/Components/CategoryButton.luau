local Rorooms = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(Rorooms.Parent.OnyxUI)
local Fusion = require(Rorooms.Parent.Fusion)
local Assets = require(Rorooms.SourceCode.Shared.Assets)

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
	local CategoryName = Util.Fallback(Props.CategoryName, "General")
	local Icon = Util.Fallback(Props.Icon, nil)
	local FallbackIcon = Util.Fallback(Props.FallbackIcon, Assets.Icons.Categories.General)
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
				Image = Scope:Computed(function(Use)
					local IconValue = Use(Icon)
					local CategoryNameValue = Use(CategoryName)
					local DefaultIcon = Assets.Icons.Categories[CategoryNameValue]

					if IconValue then
						return IconValue
					elseif DefaultIcon then
						return DefaultIcon
					else
						return Assets.Icons.Categories.General
					end
				end),
				FallbackImage = FallbackIcon,
				Size = Scope:Computed(function(Use)
					return UDim2.fromOffset(Use(Theme.TextSize["1.5"]), Use(Theme.TextSize["1.5"]))
				end),
				BackgroundTransparency = 1,
			},
		},
	}
end
