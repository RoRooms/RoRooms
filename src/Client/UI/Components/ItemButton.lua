local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent)

local Shared = RoRooms.Shared
local Client = RoRooms.Client

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

local BaseButton = require(OnyxUI.Components.BaseButton)
local Text = require(OnyxUI.Components.Text)
local Icon = require(OnyxUI.Components.Icon)
local Frame = require(OnyxUI.Components.Frame)
local Image = require(OnyxUI.Components.Image)

return function(Props)
	Props.ItemId = EnsureValue(Props.ItemId, "string", "ItemId")
	Props.Item = EnsureValue(Props.Item, "table", {})
	Props.BaseColor3 = EnsureValue(Props.BaseColor3, "Color3", Themer.Theme.Colors.Base.Light)

	local IsHolding = Value(false)
	local IsEquipped = Computed(function()
		return table.find(States.EquippedItems:get(), Props.ItemId:get()) ~= nil
	end)

	return BaseButton {
		Name = "ItemButton",
		BackgroundColor3 = Spring(
			Computed(function()
				if IsHolding:get() or IsEquipped:get() then
					return ColourUtils.Emphasise(Props.BaseColor3:get(), Themer.Theme.Emphasis:get())
				else
					return Props.BaseColor3:get()
				end
			end),
			Themer.Theme.SpringSpeed["1"],
			Themer.Theme.SpringDampening
		),
		BackgroundTransparency = 0,
		Size = UDim2.fromOffset(70, 70),
		AutomaticSize = Enum.AutomaticSize.None,
		ClipsDescendants = true,
		LayoutOrder = Computed(function()
			return Props.Item:get().LayoutOrder or 0
		end),

		OnActivated = function()
			if Props.Callback then
				Props.Callback()
			end
			if States.Controllers.ItemsController then
				States.Controllers.ItemsController:ToggleEquipItem(Props.ItemId:get())
			end
		end,
		IsHolding = IsHolding,

		[Children] = {
			Modifier.Corner {
				CornerRadius = Computed(function()
					return UDim.new(0, Themer.Theme.CornerRadius["2"]:get())
				end),
			},
			Modifier.Padding {
				Padding = Computed(function()
					return UDim.new(0, Themer.Theme.Spacing["0.5"]:get())
				end),
			},
			Modifier.Stroke {
				Color = Spring(
					Computed(function()
						if IsEquipped:get() then
							return ColourUtils.Emphasise(Props.BaseColor3:get(), Themer.Theme.Emphasis:get() * 4)
						else
							return ColourUtils.Emphasise(Props.BaseColor3:get(), 0.2)
						end
					end),
					Themer.Theme.SpringSpeed["1"],
					Themer.Theme.SpringDampening
				),
			},

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

				[Children] = {
					Modifier.ListLayout {
						FillDirection = Enum.FillDirection.Horizontal,
						Padding = Computed(function()
							return UDim.new(0, Themer.Theme.Spacing["0.25"]:get())
						end),
					},

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
							return ColourUtils.Lighten(Props.BaseColor3:get(), 0.25)
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
							return ColourUtils.Lighten(Props.BaseColor3:get(), 0.5)
						end),
						AutoLocalize = false,
					},
				},
			},
		},
	}
end
