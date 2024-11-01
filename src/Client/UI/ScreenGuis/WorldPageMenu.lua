local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")

local RoRooms = script.Parent.Parent.Parent.Parent.Parent
local Future = require(script.Parent.Parent.Parent.Parent.Parent.Parent.Future)
local OnyxUI = require(RoRooms.Parent.OnyxUI)
local Fusion = require(RoRooms.Parent.Fusion)
local States = require(RoRooms.SourceCode.Client.UI.States)
local Components = require(RoRooms.SourceCode.Client.UI.Components)
local Assets = require(RoRooms.SourceCode.Shared.Assets)
local WorldsController = RunService:IsRunning() and require(RoRooms.SourceCode.Client.Worlds.WorldsController)

local Children = Fusion.Children
local Themer = OnyxUI.Themer
local Peek = Fusion.peek

return function(Scope: Fusion.Scope<any>, Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components, Components)
	local Theme = Themer.Theme:now()

	local MenuOpen = Scope:Computed(function(Use)
		return Use(States.Menus.CurrentMenu) == script.Name
	end)
	local ProductInfo = Scope:Value({})

	local function UpdatePlaceInfo()
		if Peek(States.WorldPageMenu.PlaceId) == nil then
			return
		end

		task.spawn(function()
			Future.Try(function()
				return MarketplaceService:GetProductInfo(Peek(States.WorldPageMenu.PlaceId))
			end):After(function(Success, Result)
				if Success then
					ProductInfo:set(Result)
				else
					warn(Result)
				end
			end)
		end)
	end

	Scope:Observer(States.WorldPageMenu.PlaceId):onChange(function()
		UpdatePlaceInfo()
	end)
	UpdatePlaceInfo()

	local WorldPageMenu = Scope:Menu {
		Name = script.Name,
		Open = MenuOpen,
		Parent = Props.Parent,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.fromOffset(340, 0),
		ListHorizontalFlex = Enum.UIFlexAlignment.Fill,

		[Children] = {
			Scope:Frame {
				Name = "Contents",
				AutomaticSize = Enum.AutomaticSize.Y,
				ListEnabled = true,
				ListPadding = Scope:Computed(function(Use)
					return UDim.new(0, Use(Theme.Spacing["1"]))
				end),
				ListHorizontalFlex = Enum.UIFlexAlignment.Fill,

				[Children] = {
					Scope:Image {
						Name = "Thumbnail",
						Image = Scope:Computed(function(Use)
							local PlaceIdValue = Use(States.WorldPageMenu.PlaceId)
							if PlaceIdValue then
								return `rbxthumb://type=GameThumbnail&id={PlaceIdValue}&w=480&h=270`
							else
								return "rbxasset://textures/ui/GuiImagePlaceholder.png"
							end
						end),
						Size = UDim2.new(UDim.new(1, 0), UDim.new(0, 80)),
						ScaleType = Enum.ScaleType.Crop,
						CornerRadius = Scope:Computed(function(Use)
							return UDim.new(0, Use(Theme.CornerRadius["1"]))
						end),
					},
					Scope:Frame {
						Name = "Details",
						AutomaticSize = Enum.AutomaticSize.Y,
						ListEnabled = true,
						ListHorizontalFlex = Enum.UIFlexAlignment.Fill,
						ListPadding = Scope:Computed(function(Use)
							return UDim.new(0, Use(Theme.Spacing["0.25"]))
						end),

						[Children] = {
							Scope:Text {
								Name = "Name",
								AutomaticSize = Enum.AutomaticSize.Y,
								Text = Scope:Computed(function(Use)
									if Use(ProductInfo) and Use(ProductInfo).Name then
										return Use(ProductInfo).Name
									else
										return "Name"
									end
								end),
								TextSize = Theme.TextSize["1.5"],
								FontFace = Scope:Computed(function(Use)
									return Font.new(Use(Theme.Font.Heading), Use(Theme.FontWeight.Heading))
								end),
								TextTruncate = Enum.TextTruncate.AtEnd,
								RichText = false,
								AutoLocalize = false,
							},
							Scope:Text {
								Name = "Description",
								Text = Scope:Computed(function(Use)
									if Use(ProductInfo) and Use(ProductInfo).Description then
										return Use(ProductInfo).Description
									else
										return "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
									end
								end),
								AutomaticSize = Enum.AutomaticSize.Y,
								TextTruncate = Enum.TextTruncate.AtEnd,
								TextWrapped = true,
								RichText = false,
								AutoLocalize = false,
								MaxSize = Scope:Computed(function(Use)
									return Vector2.new(math.huge, Use(Theme.TextSize["1"]) * 2)
								end),
							},
						},
					},
					Scope:Button {
						Name = "PlayButton",
						Color = OnyxUI.Util.Colors.Green["500"],
						AutomaticSize = Enum.AutomaticSize.Y,
						Content = { Assets.Icons.General.Play },
						ContentSize = Theme.TextSize["1.5"],

						OnActivated = function(): ()
							if WorldsController then
								States.Menus.CurrentMenu:set(nil)
								WorldsController:TeleportToWorld(Peek(States.WorldPageMenu.PlaceId))
							end
						end,
					},
				},
			},
		},
	}

	return WorldPageMenu
end
