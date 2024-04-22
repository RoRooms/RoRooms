local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent)

local Shared = RoRooms.Shared
local Client = RoRooms.Client

local Fusion = require(Shared.ExtPackages.OnyxUI.Packages.Fusion)
local OnyxUI = require(Shared.ExtPackages.OnyxUI)
local EnsureProp = require(OnyxUI.Utils.EnsureProp)
local States = require(Client.UI.States)
local ColourUtils = require(OnyxUI._Packages.ColourUtils)

local Children = Fusion.Children
local New = Fusion.New
local Spring = Fusion.Spring
local Computed = Fusion.Computed
local Value = Fusion.Value

local BaseButton = require(OnyxUI.Components.BaseButton)
local Text = require(OnyxUI.Components.Text)
local Icon = require(OnyxUI.Components.Icon)
local Frame = require(OnyxUI.Components.Frame)

return function(Props)
	Props.ItemId = EnsureProp(Props.ItemId, "string", "ItemId")
	Props.Item = EnsureProp(Props.Item, "table", {})
	Props.BaseColor3 = EnsureProp(Props.BaseColor3, "Color3", Color3.fromRGB(41, 41, 41))

	local IsHolding = Value(false)
	local Equipped = Computed(function()
		return table.find(States.EquippedItems:get(), Props.ItemId:get()) ~= nil
	end)

	local LabelIconImage = Computed(function()
		local Item = Props.Item:get()
		if Item.LabelIcon then
			return Item.LabelIcon
		elseif Item.LevelRequirement then
			return "rbxassetid://5743022869"
		else
			return ""
		end
	end)
	local LabelTextText = Computed(function()
		local Item = Props.Item:get()
		if Item.LabelText then
			return Item.LabelText
		elseif Item.LevelRequirement then
			return Item.LevelRequirement
		else
			return ""
		end
	end)

	return BaseButton {
		Name = "ItemButton",
		BackgroundColor3 = Spring(
			Computed(function()
				local BaseColor = Props.BaseColor3:get()
				if IsHolding:get() then
					return ColourUtils.Lighten(BaseColor, 0.05)
				else
					return BaseColor
				end
			end),
			35,
			1
		),
		BackgroundTransparency = 0,
		ClipsDescendants = true,
		LayoutOrder = Computed(function()
			return Props.Item:get().LayoutOrder or 0
		end),

		OnActivated = function()
			if Props.Callback then
				Props.Callback()
			end
			if States.ItemsController then
				States.ItemsController:ToggleEquipItem(Props.ItemId:get())
			end
		end,
		IsHolding = IsHolding,

		[Children] = {
			New "UICorner" {
				CornerRadius = UDim.new(0, 10),
			},
			New "UIPadding" {
				PaddingLeft = UDim.new(0, 5),
				PaddingBottom = UDim.new(0, 5),
				PaddingTop = UDim.new(0, 5),
				PaddingRight = UDim.new(0, 5),
			},
			New "UIStroke" {
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Thickness = 2,
				Color = Spring(
					Computed(function()
						if Equipped:get() then
							return ColourUtils.Lighten(Props.BaseColor3:get(), 0.16)
						else
							return Props.BaseColor3:get()
						end
					end),
					40,
					1
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
				local LayoutOrder = 2
				if string.len(Tool.TextureId) >= 1 then
					return New "ImageLabel" {
						Name = "Icon",
						LayoutOrder = LayoutOrder,
						AnchorPoint = AnchorPoint,
						Position = Position,
						Size = Size,
						Image = Tool.TextureId,
						BackgroundTransparency = 1,
					}
				else
					return Text {
						Name = "ItemName",
						LayoutOrder = LayoutOrder,
						AnchorPoint = AnchorPoint,
						Position = Position,
						Size = Size,
						Text = Computed(function()
							return Props.Item:get().Name or Props.ItemId:get()
						end),
						TextSize = 16,
						TextTruncate = Enum.TextTruncate.AtEnd,
						TextWrapped = true,
						AutomaticSize = Enum.AutomaticSize.None,
						TextXAlignment = Enum.TextXAlignment.Center,
						TextYAlignment = Enum.TextYAlignment.Center,
						AutoLocalize = false,
					}
				end
			end, Fusion.cleanup),
			Frame {
				Name = "Label",
				ZIndex = 2,

				[Children] = {
					New "UIListLayout" {
						Padding = UDim.new(0, 3),
						FillDirection = Enum.FillDirection.Horizontal,
						VerticalAlignment = Enum.VerticalAlignment.Center,
					},
					Computed(function()
						if string.len(LabelIconImage:get()) > 0 then
							return Icon {
								Name = "LabelIcon",
								AnchorPoint = Vector2.new(0, 0),
								Position = UDim2.fromScale(0, 0),
								Size = UDim2.fromOffset(13, 13),
								Image = LabelIconImage,
								ImageColor3 = Computed(function()
									return ColourUtils.Lighten(Props.BaseColor3:get(), 0.25)
								end),
							}
						end
					end, Fusion.cleanup),
					Computed(function()
						if string.len(LabelTextText:get()) > 0 then
							return Text {
								Name = "LabelText",
								AnchorPoint = Vector2.new(0, 0),
								Position = UDim2.fromScale(0, 0),
								Text = LabelTextText,
								TextSize = 13,
								TextColor3 = Computed(function()
									return ColourUtils.Lighten(Props.BaseColor3:get(), 0.5)
								end),
								ClipsDescendants = false,
								AutoLocalize = false,
							}
						end
					end, Fusion.cleanup),
				},
			},
		},
	}
end
