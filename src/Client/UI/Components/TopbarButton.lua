local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent)

local Shared = RoRooms.Shared
local Client = RoRooms.Client

local Fusion = require(Shared.ExtPackages.OnyxUI.Packages.Fusion)
local OnyxUI = require(Shared.ExtPackages.OnyxUI)
local EnsureValue = require(OnyxUI.Utils.EnsureValue)
local States = require(Client.UI.States)
local Themer = require(OnyxUI.Utils.Themer)
local Modifier = require(OnyxUI.Utils.Modifier)

local Children = Fusion.Children
local Computed = Fusion.Computed
local Value = Fusion.Value

local BaseButton = require(OnyxUI.Components.BaseButton)
local Icon = require(OnyxUI.Components.Icon)

return function(Props)
	Props.SizeMultiplier = EnsureValue(Props.SizeMultiplier, "number", 1)
	Props.IconImage = EnsureValue(Props.IconImage, "string", "")
	Props.MenuName = EnsureValue(Props.MenuName, "string", "")
	Props.Icon = EnsureValue(Props.Icon, "string", "")
	Props.IconFilled = EnsureValue(Props.IconFilled, "string", "")

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
			Modifier.ListLayout {
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
				VerticalAlignment = Enum.VerticalAlignment.Center,
			},
			Modifier.Corner {
				CornerRadius = Computed(function()
					return UDim.new(0, Themer.Theme.CornerRadius["Full"]:get())
				end),
			},

			Icon {
				Name = "Icon",
				Visible = Computed(function()
					return not MenuOpen:get()
				end),
				Image = Props.Icon,
				Size = UDim2.fromOffset(30, 30),
			},
			Icon {
				Name = "IconFilled",
				Visible = MenuOpen,
				Image = Props.IconFilled,
				Size = UDim2.fromOffset(30, 30),
			},
		},
	}
end
