local MarketplaceService = game:GetService("MarketplaceService")

local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent)
local Future = require(script.Parent.Parent.Parent.Parent.Parent.Parent.Future)
local OnyxUI = require(RoRooms.Packages.OnyxUI)
local Fusion = require(OnyxUI.Parent.Fusion)
local EnsureValue = require(OnyxUI.Utils.EnsureValue)
local States = require(RoRooms.Client.UI.States)
local Themer = require(OnyxUI.Utils.Themer)

local Children = Fusion.Children
local Computed = Fusion.Computed
local Value = Fusion.Value
local Observer = Fusion.Observer
local Cleanup = Fusion.Cleanup

local Text = require(OnyxUI.Components.Text)
local Image = require(OnyxUI.Components.Image)
local Button = require(OnyxUI.Components.Button)

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

	return Button {
		Name = "WorldButton",
		Color = Props.Color,
		IsHolding = IsHolding,
		CornerRadius = Computed(function()
			return UDim.new(0, Themer.Theme.CornerRadius["2"]:get())
		end),
		ListEnabled = true,
		ListFillDirection = Enum.FillDirection.Vertical,
		ListHorizontalAlignment = Enum.HorizontalAlignment.Center,
		PaddingTop = Computed(function()
			return UDim.new(0, Themer.Theme.Spacing["0.75"]:get())
		end),
		PaddingBottom = Computed(function()
			return UDim.new(0, Themer.Theme.Spacing["0.75"]:get())
		end),
		PaddingLeft = Computed(function()
			return UDim.new(0, Themer.Theme.Spacing["0.75"]:get())
		end),
		PaddingRight = Computed(function()
			return UDim.new(0, Themer.Theme.Spacing["0.75"]:get())
		end),

		OnActivated = function()
			States.WorldPageMenu.PlaceId:set(Props.PlaceId:get())
			States.CurrentMenu:set("WorldPageMenu")
		end,

		[Cleanup] = { Observers },

		[Children] = {
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
				CornerRadius = Computed(function()
					return UDim.new(0, Themer.Theme.CornerRadius["1"]:get())
				end),
				AspectRatio = 1,
				AspectType = Enum.AspectType.FitWithinMaxSize,
				DominantAxis = Enum.DominantAxis.Height,
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
