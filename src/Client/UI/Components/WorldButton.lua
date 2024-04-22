local MarketplaceService = game:GetService("MarketplaceService")
local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent)

local Shared = RoRooms.Shared
local Client = RoRooms.Client

local Fusion = require(Shared.ExtPackages.OnyxUI.Packages.Fusion)
local OnyxUI = require(Shared.ExtPackages.OnyxUI)
local EnsureProp = require(OnyxUI.Utils.EnsureProp)
local States = require(Client.UI.States)
local ColourUtils = require(OnyxUI.Packages.ColourUtils)

local Children = Fusion.Children
local New = Fusion.New
local Spring = Fusion.Spring
local Computed = Fusion.Computed
local Value = Fusion.Value

local BaseButton = require(OnyxUI.Components.BaseButton)
local Text = require(OnyxUI.Components.Text)
local Frame = require(OnyxUI.Components.Frame)

return function(Props)
	Props.PlaceId = EnsureProp(Props.PlaceId, "number", nil)
	Props.BaseColor3 = EnsureProp(Props.BaseColor3, "Color3", Color3.fromRGB(41, 41, 41))

	local IsHolding = Value(false)
	local PlaceInfo = Computed(function()
		if Props.PlaceId:get() then
			local Success, Result = pcall(function()
				return MarketplaceService:GetProductInfo(Props.PlaceId:get())
			end)
			if Success then
				return Result
			else
				warn(Result)
			end
		end
	end)

	return BaseButton {
		Name = "WorldButton",
		BackgroundColor3 = Spring(
			Computed(function()
				if IsHolding:get() then
					return ColourUtils.Lighten(Props.BaseColor3:get(), 0.02)
				else
					return Props.BaseColor3:get()
				end
			end),
			35,
			1
		),
		BackgroundTransparency = 0,
		ClipsDescendants = true,
		LayoutOrder = Props.LayoutOrder,

		OnActivated = function()
			States.WorldPageMenu.PlaceId:set(Props.PlaceId:get())
			States.CurrentMenu:set("WorldPageMenu")
		end,
		IsHolding = IsHolding,

		[Children] = {
			New "UICorner" {
				CornerRadius = UDim.new(0, 10),
			},
			New "UIPadding" {
				PaddingLeft = UDim.new(0, 8),
				PaddingBottom = UDim.new(0, 8),
				PaddingTop = UDim.new(0, 8),
				PaddingRight = UDim.new(0, 8),
			},
			New "UIStroke" {
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				Thickness = 2,
				Color = ColourUtils.Lighten(Props.BaseColor3:get(), 0.05),
			},
			New "UIListLayout" {
				Padding = UDim.new(0, 8),
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
			},
			New "ImageLabel" {
				Name = "GameIcon",
				Size = UDim2.fromOffset(85, 85),
				Image = Computed(function()
					if PlaceInfo:get() then
						return `rbxassetid://{PlaceInfo:get().IconImageAssetId}`
					else
						return "rbxasset://textures/ui/GuiImagePlaceholder.png"
					end
				end),
				BackgroundTransparency = 1,

				[Children] = {
					New "UICorner" {
						CornerRadius = UDim.new(0, 8),
					},
					New "UIAspectRatioConstraint" {
						AspectRatio = 1,
					},
				},
			},
			Frame {
				Name = "NameContainer",
				Size = UDim2.new(UDim.new(1, 0), UDim.new(0, 32)),
				AutomaticSize = Enum.AutomaticSize.None,

				[Children] = {
					New "UIListLayout" {},
					Text {
						Name = "WorldName",
						Size = UDim2.fromScale(1, 1),
						AutomaticSize = Enum.AutomaticSize.None,
						Text = Computed(function()
							if PlaceInfo:get() then
								return PlaceInfo:get().Name
							else
								return "Name"
							end
						end),
						TextSize = 16,
						TextTruncate = Enum.TextTruncate.AtEnd,
						TextWrapped = true,
						RichText = true,
						TextXAlignment = Enum.TextXAlignment.Center,
						TextYAlignment = Enum.TextYAlignment.Top,
						AutoLocalize = false,
					},
				},
			},
		},
	}
end
