local RoRooms = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(RoRooms.Parent.OnyxUI)
local Fusion = require(RoRooms.Parent.Fusion)
local States = require(RoRooms.SourceCode.Client.UI.States)
local ColorUtils = require(RoRooms.Parent.ColorUtils)
local ItemsController = require(RoRooms.SourceCode.Client.Items.ItemsController)
local Assets = require(RoRooms.SourceCode.Shared.Assets)

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

	local ItemId = Util.Fallback(Props.ItemId, "ItemId")
	local Item = Util.Fallback(Props.Item, {})
	local Color = Util.Fallback(Props.Color, Theme.Colors.Neutral.Main)
	local Callback = Util.Fallback(Props.Callback, function() end)
	local LevelRequirement = Scope:Computed(function(Use)
		local ItemValue = Use(Item)
		if ItemValue and ItemValue.LevelRequirement then
			return ItemValue.LevelRequirement
		else
			return nil
		end
	end)
	local LabelText = Scope:Computed(function(Use)
		local ItemValue = Use(Item)
		local LevelRequirementValue = Use(LevelRequirement)
		if ItemValue and ItemValue.LabelText then
			return ItemValue.LabelText
		elseif LevelRequirementValue then
			return LevelRequirementValue
		else
			return ""
		end
	end)
	local LabelIcon = Scope:Computed(function(Use)
		local ItemValue = Use(Item)
		local LevelRequirementValue = Use(LevelRequirement)
		if ItemValue and ItemValue.LabelIcon then
			return ItemValue.LabelIcon
		elseif LevelRequirementValue then
			return Assets.Icons.Categories.Unlockable
		else
			return ""
		end
	end)

	local IsEquipped = Scope:Computed(function(Use)
		return table.find(Use(States.Items.Equipped), Use(ItemId)) ~= nil
	end)

	return Scope:CustomButton {
		Name = "ItemButton",
		Color = Color,
		Size = UDim2.fromOffset(70, 70),
		AutomaticSize = Enum.AutomaticSize.None,
		LayoutOrder = Scope:Computed(function(Use)
			return Use(Item).LayoutOrder or 0
		end),
		StrokeColor = Scope:Spring(
			Scope:Computed(function(Use)
				if Use(IsEquipped) then
					return ColorUtils.Emphasize(Use(Color), Use(Theme.Emphasis.Strong))
				else
					return ColorUtils.Emphasize(Use(Color), Use(Theme.Emphasis.Regular))
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

			ItemsController:ToggleEquipItem(Peek(ItemId))
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
			Scope:IconText {
				Name = "Label",
				Content = Scope:Computed(function(Use)
					local LabelTextValue = Use(LabelText)
					local LabelIconValue = Use(LabelIcon)
					return { LabelIconValue, LabelTextValue }
				end),
				ContentSize = Theme.TextSize["0.875"],
				ContentColor = Scope:Computed(function(Use)
					return ColorUtils.Emphasize(Use(Color), Use(Theme.Emphasis.Strong))
				end),
				ContentWrapped = false,
				Visible = Scope:Computed(function(Use)
					local LabelTextValue = Use(LabelText)
					local LabelIconValue = Use(LabelIcon)
					return (LabelTextValue ~= nil) or (LabelIconValue ~= nil)
				end),
				ListPadding = Scope:Computed(function(Use)
					return UDim.new(0, Use(Theme.Spacing["0.25"]))
				end),
				ListVerticalAlignment = Enum.VerticalAlignment.Center,
			},
		},
	}
end
