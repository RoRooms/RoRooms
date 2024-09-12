local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent)
local OnyxUI = require(RoRooms.Packages.OnyxUI)
local Fusion = require(RoRooms.Packages.Fusion)
local States = require(RoRooms.Client.UI.States)
local ColorUtils = require(RoRooms.Packages.ColorUtils)

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
	Props.Color = EnsureValue(Props.Color, "Color3", Theme.Colors.Neutral.Main)

	local IsHolding = Value(false)
	local IsEquipped = Computed(function()
		return table.find(Use(States.EquippedItems), Use(Props.ItemId)) ~= nil
	end)

	return CustomButton {
		Name = "ItemButton",
		Color = Props.Color,
		IsHolding = IsHolding,
		Size = UDim2.fromOffset(70, 70),
		AutomaticSize = Enum.AutomaticSize.None,
		LayoutOrder = Computed(function()
			return Use(Props.Item).LayoutOrder or 0
		end),
		StrokeEnabled = IsEquipped,
		StrokeColor = Spring(
			Computed(function()
				if Use(IsEquipped) then
					return ColorUtils.Emphasize(Use(Props.Color), Use(Theme.Emphasis.Light) * 4)
				else
					return ColorUtils.Emphasize(Use(Props.Color), 0.2)
				end
			end),
			Theme.SpringSpeed["1"],
			Theme.SpringDampening
		),
		ListEnabled = false,

		OnActivated = function()
			if Props.Callback then
				Props.Callback()
			end
			if States.Controllers.ItemsController then
				States.Controllers.ItemsController:ToggleEquipItem(Use(Props.ItemId))
			end
		end,

		[Children] = {
			Computed(function()
				local Tool = Use(Props.Item).Tool
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
							if Use(Props.Item) and Use(Props.Item).Name then
								return Use(Props.Item).Name
							else
								return Use(Props.ItemId)
							end
						end),
						TextSize = Theme.TextSize["1"],
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
					return UDim.new(0, Theme.Spacing["0.25"]:get())
				end),

				[Children] = {
					Icon {
						Name = "LabelIcon",
						Size = Computed(function()
							return UDim2.fromOffset(Theme.TextSize["0.875"]:get(), Theme.TextSize["0.875"]:get())
						end),
						Image = Computed(function()
							local LabelIcon = Use(Props.Item).LabelIcon
							local LevelRequirement = Use(Props.Item).LevelRequirement

							if LabelIcon then
								return LabelIcon
							elseif LevelRequirement then
								return "rbxassetid://5743022869"
							else
								return ""
							end
						end),
						ImageColor3 = Computed(function()
							return ColorUtils.Lighten(Use(Props.Color), 0.25)
						end),
					},
					Text {
						Name = "LabelText",
						Text = Computed(function()
							if Use(Props.Item) then
								if Use(Props.Item).LabelText then
									return Use(Props.Item).LabelText
								elseif Use(Props.Item).LevelRequirement then
									return Use(Props.Item).LevelRequirement
								else
									return ""
								end
							else
								return ""
							end
						end),
						TextSize = Theme.TextSize["0.875"],
						TextColor3 = Computed(function()
							return ColorUtils.Lighten(Use(Props.Color), 0.5)
						end),
						AutoLocalize = false,
					},
				},
			},
		},
	}
end
