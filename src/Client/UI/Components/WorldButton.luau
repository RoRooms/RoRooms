local MarketplaceService = game:GetService("MarketplaceService")

local Rorooms = script.Parent.Parent.Parent.Parent.Parent
local Future = require(script.Parent.Parent.Parent.Parent.Parent.Parent.Future)
local OnyxUI = require(Rorooms.Parent.OnyxUI)
local Fusion = require(Rorooms.Parent.Fusion)
local States = require(Rorooms.SourceCode.Client.UI.States)

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

	local PlaceId = Util.Fallback(Props.PlaceId, nil)

	local PlaceInfo = Scope:Value({})

	local function UpdatePlaceInfo()
		Future.Try(function()
			return MarketplaceService:GetProductInfo(Peek(PlaceId))
		end):After(function(Success, Result)
			if Success then
				PlaceInfo:set(Result)
			else
				warn(Result)
			end
		end)
	end

	Scope:Observer(PlaceId):onChange(UpdatePlaceInfo)
	UpdatePlaceInfo()

	return Scope:CustomButton {
		Name = "WorldButton",
		ListEnabled = true,
		ListFillDirection = Enum.FillDirection.Vertical,
		ListHorizontalAlignment = Enum.HorizontalAlignment.Center,
		ListPadding = Scope:Computed(function(Use)
			return UDim.new(0, Use(Theme.Spacing["0.5"]))
		end),
		PaddingLeft = Scope:Computed(function(Use)
			return UDim.new(0, Use(Theme.Spacing["0"]))
		end),
		PaddingTop = Scope:Computed(function(Use)
			return UDim.new(0, Use(Theme.Spacing["0"]))
		end),
		PaddingRight = Scope:Computed(function(Use)
			return UDim.new(0, Use(Theme.Spacing["0"]))
		end),

		OnActivated = function()
			States.WorldPageMenu.PlaceId:set(Peek(PlaceId))
			States.Menus.CurrentMenu:set("WorldPageMenu")
		end,

		[Children] = {
			Scope:Image {
				Name = "Icon",
				Size = UDim2.fromOffset(105, 105),
				Image = Scope:Computed(function(Use)
					if Use(PlaceInfo) and Use(PlaceInfo).IconImageAssetId then
						return `rbxassetid://{Use(PlaceInfo).IconImageAssetId}`
					else
						return "rbxasset://textures/ui/GuiImagePlaceholder.png"
					end
				end),
				BackgroundTransparency = 1,
				CornerRadius = Scope:Computed(function(Use)
					return UDim.new(0, Use(Theme.CornerRadius["1.5"]))
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
