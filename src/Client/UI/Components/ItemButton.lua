local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent)
local OnyxUI = require(RoRooms.Packages.OnyxUI)
local Fusion = require(RoRooms.Packages.Fusion)
local States = require(RoRooms.Client.UI.States)
local ColorUtils = require(RoRooms.Packages.ColorUtils)

local Children = Fusion.Children
local Util = OnyxUI.Util
local Themer = OnyxUI.Themer
local Peek = Fusion.peek

local CustomButton = require(script.Parent.CustomButton)

return function(Scope: Fusion.Scope<any>, Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components)
	local Theme = Themer.Theme:now()

	local ItemId = Util.Fallback(Props.ItemId, "ItemId")
	local Item = Util.Fallback(Props.Item, {})
	local Color = Util.Fallback(Props.Color, Theme.Util.Colors.Neutral.Main)
	local Callback = Util.Fallback(Props.Callback, function() end)

	local IsHolding = Scope:Value(false)
	local IsEquipped = Scope:Computed(function(Use)
		return table.find(Use(States.EquippedItems), Use(ItemId)) ~= nil
	end)

	return Scope:CustomButton {
		Name = "ItemButton",
		Color = Color,
		IsHolding = IsHolding,
		Size = UDim2.fromOffset(70, 70),
		AutomaticSize = Enum.AutomaticSize.None,
		LayoutOrder = Scope:Computed(function(Use)
			return Use(Item).LayoutOrder or 0
		end),
		StrokeEnabled = IsEquipped,
		StrokeColor = Scope:Spring(
			Scope:Computed(function(Use)
				if Use(IsEquipped) then
					return ColorUtils.Emphasize(Use(Color), Use(Theme.Emphasis.Light) * 4)
				else
					return ColorUtils.Emphasize(Use(Color), 0.2)
				end
			end),
			Theme.SpringSpeed["1"],
			Theme.SpringDampening["1"]
		),
		ListEnabled = false,

		OnActivated = function()
			if Callback then
				Callback()
			end
			if States.Controllers.ItemsController then
				States.Controllers.ItemsController:ToggleEquipItem(Peek(ItemId))
			end
		end,

		[Children] = {
			Scope:Computed(function(Use)
				local Tool = Use(Item).Tool
				if not Tool then
					return
				end

				local Size = UDim2.fromOffset(60, 60)
				local AnchorPoint = Vector2.new(0.5, 0.5)
				local Position = UDim2.fromScale(0.5, 0.5)

				if string.len(Tool.TextureId) >= 1 then
					return Scope:Image {
						Name = "Icon",
						Image = Tool.TextureId,
						BackgroundTransparency = 1,
						AnchorPoint = AnchorPoint,
						Position = Position,
						Size = Size,
					}
				else
					return Scope:Text {
						Name = "ItemName",
						Text = Scope:Computed(function(Use)
							if Use(Item) and Use(Item).Name then
								return Use(Item).Name
							else
								return Use(ItemId)
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
			end),
			Scope:Frame {
				Name = "Label",
				ZIndex = 2,
				ListEnabled = true,
				ListFillDirection = Enum.FillDirection.Horizontal,
				ListPadding = Scope:Computed(function(Use)
					return UDim.new(0, Use(Theme.Spacing["0.25"]))
				end),

				[Children] = {
					Scope:Icon {
						Name = "LabelIcon",
						Size = Scope:Computed(function(Use)
							return UDim2.fromOffset(Use(Theme.TextSize["0.875"]), Use(Theme.TextSize["0.875"]))
						end),
						Image = Scope:Computed(function(Use)
							local LabelIcon = Use(Item).LabelIcon
							local LevelRequirement = Use(Item).LevelRequirement

							if LabelIcon then
								return LabelIcon
							elseif LevelRequirement then
								return "rbxassetid://5743022869"
							else
								return ""
							end
						end),
						ImageColor3 = Scope:Computed(function(Use)
							return ColorUtils.Lighten(Use(Color), 0.25)
						end),
					},
					Scope:Text {
						Name = "LabelText",
						Text = Scope:Computed(function(Use)
							if Use(Item) then
								if Use(Item).LabelText then
									return Use(Item).LabelText
								elseif Use(Item).LevelRequirement then
									return Use(Item).LevelRequirement
								else
									return ""
								end
							else
								return ""
							end
						end),
						TextSize = Theme.TextSize["0.875"],
						TextColor3 = Scope:Computed(function(Use)
							return ColorUtils.Lighten(Use(Color), 0.5)
						end),
						AutoLocalize = false,
					},
				},
			},
		},
	}
end
