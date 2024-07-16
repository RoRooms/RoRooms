local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent)
local OnyxUI = require(RoRooms.Packages.OnyxUI)
local Fusion = require(OnyxUI.Parent.Fusion)
local EnsureValue = require(OnyxUI.Utils.EnsureValue)
local States = require(RoRooms.Client.UI.States)
local ColorUtils = require(OnyxUI.Parent.ColorUtils)

local Themer = require(OnyxUI.Utils.Themer)

local Children = Fusion.Children
local Spring = Fusion.Spring
local Computed = Fusion.Computed
local Value = Fusion.Value

local Text = require(OnyxUI.Components.Text)
local Icon = require(OnyxUI.Components.Icon)
local Frame = require(OnyxUI.Components.Frame)
local Image = require(OnyxUI.Components.Image)
local CustomButton = require(script.Parent.CustomButton)

return function(Props)
	Props.ItemId = EnsureValue(Props.ItemId, "string", "ItemId")
	Props.Item = EnsureValue(Props.Item, "table", {})
	Props.Color = EnsureValue(Props.Color, "Color3", Themer.Theme.Colors.Neutral.Dark)

	local IsHolding = Value(false)
	local IsEquipped = Computed(function()
		return table.find(States.EquippedItems:get(), Props.ItemId:get()) ~= nil
	end)

	return CustomButton {
		Name = "ItemButton",
		Color = Props.Color,
		IsHolding = IsHolding,
		Size = UDim2.fromOffset(70, 70),
		AutomaticSize = Enum.AutomaticSize.None,
		LayoutOrder = Computed(function()
			return Props.Item:get().LayoutOrder or 0
		end),
		StrokeEnabled = IsEquipped,
		StrokeColor = Spring(
			Computed(function()
				if IsEquipped:get() then
					return ColorUtils.Emphasize(Props.Color:get(), Themer.Theme.Emphasis.Light:get() * 4)
				else
					return ColorUtils.Emphasize(Props.Color:get(), 0.2)
				end
			end),
			Themer.Theme.SpringSpeed["1"],
			Themer.Theme.SpringDampening
		),
		ListEnabled = false,

		OnActivated = function()
			if Props.Callback then
				Props.Callback()
			end
			if States.Controllers.ItemsController then
				States.Controllers.ItemsController:ToggleEquipItem(Props.ItemId:get())
			end
		end,

		[Children] = {
			Computed(function()
				local Tool = Props.Item:get().Tool
				if not Tool then
					return
				end

				local Size = UDim2.fromOffset(60, 60)
				local AnchorPoint = Vector2.new(0.5, 0.5)
				local Position = UDim2.fromScale(0.5, 0.5)

				if string.len(Tool.TextureId) >= 1 then
					return Image {
						Name = "Icon",
						Image = Tool.TextureId,
						BackgroundTransparency = 1,
						AnchorPoint = AnchorPoint,
						Position = Position,
						Size = Size,
					}
				else
					return Text {
						Name = "ItemName",
						Text = Computed(function()
							if Props.Item:get() and Props.Item:get().Name then
								return Props.Item:get().Name
							else
								return Props.ItemId:get()
							end
						end),
						TextSize = Themer.Theme.TextSize["1"],
						AnchorPoint = AnchorPoint,
						Position = Position,
						Size = Size,
						TextTruncate = Enum.TextTruncate.AtEnd,
						AutomaticSize = Enum.AutomaticSize.None,
						TextXAlignment = Enum.TextXAlignment.Center,
						TextYAlignment = Enum.TextYAlignment.Center,
						AutoLocalize = false,
						TextWrapped = true,
					}
				end
			end, Fusion.cleanup),
			Frame {
				Name = "Label",
				ZIndex = 2,
				ListEnabled = true,
				ListFillDirection = Enum.FillDirection.Horizontal,
				ListPadding = Computed(function()
					return UDim.new(0, Themer.Theme.Spacing["0.25"]:get())
				end),

				[Children] = {
					Icon {
						Name = "LabelIcon",
						Size = Computed(function()
							return UDim2.fromOffset(
								Themer.Theme.TextSize["0.875"]:get(),
								Themer.Theme.TextSize["0.875"]:get()
							)
						end),
						Image = Computed(function()
							local LabelIcon = Props.Item:get().LabelIcon
							local LevelRequirement = Props.Item:get().LevelRequirement

							if LabelIcon then
								return LabelIcon
							elseif LevelRequirement then
								return "rbxassetid://5743022869"
							else
								return ""
							end
						end),
						ImageColor3 = Computed(function()
							return ColorUtils.Lighten(Props.Color:get(), 0.25)
						end),
					},
					Text {
						Name = "LabelText",
						Text = Computed(function()
							if Props.Item:get() then
								if Props.Item:get().LabelText then
									return Props.Item:get().LabelText
								elseif Props.Item:get().LevelRequirement then
									return Props.Item:get().LevelRequirement
								else
									return ""
								end
							else
								return ""
							end
						end),
						TextSize = Themer.Theme.TextSize["0.875"],
						TextColor3 = Computed(function()
							return ColorUtils.Lighten(Props.Color:get(), 0.5)
						end),
						AutoLocalize = false,
					},
				},
			},
		},
	}
end
