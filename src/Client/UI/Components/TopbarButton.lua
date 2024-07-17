local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent)

local OnyxUI = require(RoRooms.Packages.OnyxUI)
local Fusion = require(OnyxUI.Parent.Fusion)
local EnsureValue = require(OnyxUI.Utils.EnsureValue)
local States = require(RoRooms.Client.UI.States)
local Themer = require(OnyxUI.Utils.Themer)

local Children = Fusion.Children
local Computed = Fusion.Computed
local Value = Fusion.Value

local BaseButton = require(OnyxUI.Components.BaseButton)
local Icon = require(OnyxUI.Components.Icon)
local Base = require(OnyxUI.Components.Base)

return function(Props)
	Props.SizeMultiplier = EnsureValue(Props.SizeMultiplier, "number", 1)
	Props.IconImage = EnsureValue(Props.IconImage, "string", "")
	Props.MenuName = EnsureValue(Props.MenuName, "string", "")
	Props.Icon = EnsureValue(Props.Icon, "string", "")
	Props.IconFilled = EnsureValue(Props.IconFilled, "string", "")
	local IndicatorEnabled = EnsureValue(Props.IndicatorEnabled, "boolean", false)
	local IndicatorColor = EnsureValue(Props.IndicatorColor, "Color3", Color3.fromRGB(255, 255, 255))

	local IsHovering = Value(false)
	local IsHolding = Value(false)
	local MenuOpen = Computed(function()
		return States.CurrentMenu:get() == Props.MenuName:get()
	end)

	return BaseButton {
		Name = "TopbarButton",
		BackgroundColor3 = Themer.Theme.Colors.BaseContent.Main,
		BackgroundTransparency = Computed(function()
			if IsHovering:get() or MenuOpen:get() then
				return 0.9
			else
				return 1
			end
		end),
		Size = Computed(function()
			local BaseSize = UDim2.fromOffset(45, 45)
			local SizeMultiplier = Props.SizeMultiplier:get()
			return UDim2.fromOffset(BaseSize.X.Offset * SizeMultiplier, BaseSize.Y.Offset * SizeMultiplier)
		end),
		AutomaticSize = Enum.AutomaticSize.None,
		LayoutOrder = Props.LayoutOrder,
		CornerRadius = Computed(function()
			return UDim.new(0, Themer.Theme.CornerRadius["Full"]:get())
		end),

		IsHovering = IsHovering,
		IsHolding = IsHolding,
		OnActivated = function()
			if States.CurrentMenu:get() == Props.MenuName:get() then
				States.CurrentMenu:set()
			else
				States.CurrentMenu:set(Props.MenuName:get())
				if States.ScreenSize:get().Y < 900 then
					States.ItemsMenu.Open:set()
				end
			end
		end,

		[Children] = {
			Icon {
				Name = "Icon",
				Image = Computed(function()
					if MenuOpen:get() then
						return Props.IconFilled:get()
					else
						return Props.Icon:get()
					end
				end),
				Size = UDim2.fromOffset(30, 30),
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.fromScale(0.5, 0.5),
			},
			Base {
				Name = "Indicator",
				BackgroundTransparency = 0,
				BackgroundColor3 = IndicatorColor,
				Size = UDim2.fromOffset(12, 3),
				AnchorPoint = Vector2.new(0.5, 1),
				Position = UDim2.fromScale(0.5, 1),
				CornerRadius = Computed(function()
					return UDim.new(0, Themer.Theme.CornerRadius.Full:get())
				end),
				Visible = IndicatorEnabled,
			},
		},
	}
end
