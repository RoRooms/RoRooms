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
local Spring = Fusion.Spring
local Computed = Fusion.Computed
local Value = Fusion.Value

local BaseButton = require(OnyxUI.Components.BaseButton)
local Icon = require(OnyxUI.Components.Icon)

return function(Props)
	Props.SizeMultiplier = EnsureValue(Props.SizeMultiplier, "number", 1)
	Props.IconImage = EnsureValue(Props.IconImage, "string", "")
	Props.MenuName = EnsureValue(Props.MenuName, "string", "")

	local IsHolding = Value(false)
	local MenuOpen = Computed(function()
		return States.CurrentMenu:get() == Props.MenuName:get()
	end)

	return BaseButton {
		Name = "TopbarButton",
		BackgroundColor3 = Themer.Theme.Colors.Base.Main,
		BackgroundTransparency = States.PreferredTransparency,
		Size = Computed(function()
			local BaseSize = UDim2.fromOffset(65, 65)
			local SizeMultiplier = Props.SizeMultiplier:get()
			return UDim2.fromOffset(BaseSize.X.Offset * SizeMultiplier, BaseSize.Y.Offset * SizeMultiplier)
		end),
		AutomaticSize = Enum.AutomaticSize.None,
		LayoutOrder = Props.LayoutOrder,

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
					return UDim.new(0, Themer.Theme.CornerRadius["4"]:get())
				end),
			},
			Modifier.Stroke {
				Thickness = Spring(
					Computed(function()
						if MenuOpen:get() then
							return Themer.Theme.StrokeThickness["2"]:get()
						else
							return Themer.Theme.StrokeThickness["1"]:get()
						end
					end),
					Themer.Theme.SpringSpeed["1"],
					Themer.Theme.SpringDampening
				),
				Color = Spring(
					Computed(function()
						if MenuOpen:get() then
							return Themer.Theme.Colors.Primary.Main:get()
						else
							return Themer.Theme.Colors.Neutral.Main:get()
						end
					end),
					Themer.Theme.SpringSpeed["1"],
					Themer.Theme.SpringDampening
				),
			},

			Icon {
				Image = Props.IconImage,
				Size = Spring(
					Computed(function()
						local BaseSize = 40
						BaseSize = BaseSize * Props.SizeMultiplier:get()
						if not IsHolding:get() then
							return UDim2.fromOffset(BaseSize, BaseSize)
						else
							return UDim2.fromOffset(BaseSize * 0.9, BaseSize * 0.9)
						end
					end),
					40,
					1
				),
			},
		},
	}
end
