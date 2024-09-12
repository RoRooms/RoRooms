local MarketplaceService = game:GetService("MarketplaceService")

local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent)
local Future = require(script.Parent.Parent.Parent.Parent.Parent.Parent.Future)
local OnyxUI = require(RoRooms.Packages.OnyxUI)
local Fusion = require(RoRooms.Packages.Fusion)
local States = require(RoRooms.Client.UI.States)

local Children = Fusion.Children

local CustomButton = require(script.Parent.CustomButton)

return function(Scope: Fusion.Scope<any>, Props)
	local PlaceId = Scope:EnsureValue(Props.PlaceId, nil)

	local IsHolding = Scope:Value(false)
	local PlaceInfo = Scope:Value({})

	local function UpdatePlaceInfo()
		Future.Try(function()
			return MarketplaceService:GetProductInfo(Use(Props.PlaceId))
		end):After(function(Success, Result)
			if Success then
				PlaceInfo:set(Result)
			else
				warn(Result)
			end
		end)
	end

	local Observers = {
		Scope:Observer(Props.PlaceId):onChange(UpdatePlaceInfo),
	}
	UpdatePlaceInfo()

	return CustomButton {
		Name = "WorldButton",
		IsHolding = IsHolding,
		ListEnabled = true,
		ListFillDirection = Enum.FillDirection.Vertical,
		ListHorizontalAlignment = Enum.HorizontalAlignment.Center,

		OnActivated = function()
			States.WorldPageMenu.PlaceId:set(Use(Props.PlaceId))
			States.CurrentMenu:set("WorldPageMenu")
		end,

		[Children] = {
			Scope:Image {
				Name = "Icon",
				Size = UDim2.fromOffset(90, 90),
				Image = Scope:Computed(function(Use)
					if Use(PlaceInfo) and Use(PlaceInfo).IconImageAssetId then
						return `rbxassetid://{Use(PlaceInfo).IconImageAssetId}`
					else
						return "rbxasset://textures/ui/GuiImagePlaceholder.png"
					end
				end),
				BackgroundTransparency = 1,
				CornerRadius = Scope:Computed(function(Use)
					return UDim.new(0, Use(Theme.CornerRadius["1"]))
				end),
				AspectRatio = 1,
				AspectType = Enum.AspectType.FitWithinMaxSize,
				DominantAxis = Enum.DominantAxis.Height,
			},
			Scope:Text {
				Name = "Title",
				Text = Scope:Computed(function(Use)
					if Use(PlaceInfo) and Use(PlaceInfo).Name then
						return Use(PlaceInfo).Name
					else
						return "Title"
					end
				end),
				Size = Scope:Computed(function(Use)
					return UDim2.fromOffset(90, Use(Theme.TextSize["1"]) * 2)
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
