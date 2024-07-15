local MarketplaceService = game:GetService("MarketplaceService")

local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent)
local Future = require(script.Parent.Parent.Parent.Parent.Parent.Parent.Future)
local OnyxUI = require(RoRooms.Packages.OnyxUI)
local Fusion = require(OnyxUI.Parent.Fusion)
local EnsureValue = require(OnyxUI.Utils.EnsureValue)
local States = require(RoRooms.Client.UI.States)
local ColorUtils = require(OnyxUI.Parent.ColorUtils)
local Themer = require(OnyxUI.Utils.Themer)
local Modifier = require(OnyxUI.Utils.Modifier)

local Children = Fusion.Children
local Spring = Fusion.Spring
local Computed = Fusion.Computed
local Value = Fusion.Value
local Observer = Fusion.Observer
local Cleanup = Fusion.Cleanup

local BaseButton = require(OnyxUI.Components.BaseButton)
local Text = require(OnyxUI.Components.Text)
local Image = require(OnyxUI.Components.Image)

return function(Props)
	Props.PlaceId = EnsureValue(Props.PlaceId, "number", nil)
	Props.Color = EnsureValue(Props.Color, "Color3", Themer.Theme.Colors.Base.Main)

	local IsHolding = Value(false)
	local PlaceInfo = Value({})

	local function UpdatePlaceInfo()
		Future.Try(function()
			return MarketplaceService:GetProductInfo(Props.PlaceId:get())
		end):After(function(Success, Result)
			if Success then
				PlaceInfo:set(Result)
			else
				warn(Result)
			end
		end)
	end

	local Observers = {
		Observer(Props.PlaceId):onChange(UpdatePlaceInfo),
	}
	UpdatePlaceInfo()

	return BaseButton {
		Name = "WorldButton",
		BackgroundColor3 = Spring(
			Computed(function()
				if IsHolding:get() then
					return ColorUtils.Lighten(Props.Color:get(), 0.05)
				else
					return Props.Color:get()
				end
			end),
			Themer.Theme.SpringSpeed["1"],
			Themer.Theme.SpringDampening
		),
		BackgroundTransparency = 0,
		OnActivated = function()
			States.WorldPageMenu.PlaceId:set(Props.PlaceId:get())
			States.CurrentMenu:set("WorldPageMenu")
		end,
		IsHolding = IsHolding,

		[Cleanup] = { Observers },

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
				ColorUtils.Lighten(Props.Color:get(), 0.15),
			},
			Modifier.ListLayout {
				HorizontalAlignment = Enum.HorizontalAlignment.Center,
			},

			Image {
				Name = "Icon",
				Size = UDim2.fromOffset(90, 90),
				Image = Computed(function()
					if PlaceInfo:get() and PlaceInfo:get().IconImageAssetId then
						return `rbxassetid://{PlaceInfo:get().IconImageAssetId}`
					else
						return "rbxasset://textures/ui/GuiImagePlaceholder.png"
					end
				end),
				BackgroundTransparency = 1,

				[Children] = {
					Modifier.Corner {},
					Modifier.AspectRatioConstraint {
						AspectRatio = 1,
						AspectType = Enum.AspectType.FitWithinMaxSize,
						DominantAxis = Enum.DominantAxis.Height,
					},
				},
			},
			Text {
				Name = "Title",
				Text = Computed(function()
					if PlaceInfo:get() and PlaceInfo:get().Name then
						return PlaceInfo:get().Name
					else
						return "Title"
					end
				end),
				Size = Computed(function()
					return UDim2.fromOffset(90, Themer.Theme.TextSize["1"]:get() * 2)
				end),
				AutomaticSize = Enum.AutomaticSize.None,
				TextTruncate = Enum.TextTruncate.AtEnd,
				TextXAlignment = Enum.TextXAlignment.Center,
				TextYAlignment = Enum.TextYAlignment.Top,
				AutoLocalize = false,
				TextWrapped = true,
				RichText = false,
			},
		},
	}
end
