local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent)

local Shared = RoRooms.Shared
local Client = RoRooms.Client
local Config = RoRooms.Config

local Fusion = require(Shared.ExtPackages.OnyxUI.Packages.Fusion)
local OnyxUI = require(Shared.ExtPackages.OnyxUI)
local EnsureValue = require(OnyxUI.Utils.EnsureValue)
local States = require(Client.UI.States)
local ColourUtils = require(OnyxUI._Packages.ColourUtils)
local Modifier = require(OnyxUI.Utils.Modifier)
local Themer = require(OnyxUI.Utils.Themer)

local Children = Fusion.Children
local Spring = Fusion.Spring
local Computed = Fusion.Computed
local Value = Fusion.Value

local IconButton = require(OnyxUI.Components.IconButton)

return function(Props)
	Props.CategoryName = EnsureValue(Props.CategoryName, "string", "Category")
	Props.BaseColor3 = EnsureValue(Props.BaseColor3, "Color3", Themer.Theme.Colors.Base.Light)

	local Category = Computed(function()
		return Config.ItemsSystem.Categories[Props.CategoryName:get()]
	end)

	local IsHolding = Value(false)

	return IconButton {
		Name = "ItemCategoryButton",
		BackgroundColor3 = Spring(
			Computed(function()
				local BaseColor = Props.BaseColor3:get()
				if IsHolding:get() then
					return ColourUtils.Lighten(Props.BaseColor3:get(), 0.1)
				else
					return BaseColor
				end
			end),
			Themer.Theme.SpringSpeed["1"],
			Themer.Theme.SpringDampening
		),
		BackgroundTransparency = 0,
		LayoutOrder = Computed(function()
			if Category:get() and Category:get().LayoutOrder then
				return Category:get().LayoutOrder
			else
				return 0
			end
		end),
		Image = Computed(function()
			if Category:get() and Category:get().Icon then
				return Category:get().Icon
			else
				return "rbxassetid://7058763764"
			end
		end),
		ContentSize = 25,
		Color = Props.BaseColor3,
		Padding = Modifier.Padding {
			Padding = Computed(function()
				return UDim.new(0, Themer.Theme.Spacing["0.5"]:get())
			end),
		},

		OnActivated = function()
			States.ItemsMenu.FocusedCategory:set(Props.CategoryName:get(), true)
		end,
		IsHolding = IsHolding,

		[Children] = {
			Modifier.Stroke {
				Color = Themer.Theme.Colors.Neutral.Light,
			},
		},
	}
end
