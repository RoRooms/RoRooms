local RunService = game:GetService("RunService")
local RoRooms = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(RoRooms.Parent.OnyxUI)
local Fusion = require(RoRooms.Parent.Fusion)
local States = require(RoRooms.SourceCode.Client.UI.States)
local Worlds = require(RoRooms.SourceCode.Client.UI.States.Worlds)
local Config = require(RoRooms.Config).Config
local Components = require(RoRooms.SourceCode.Client.UI.Components)
local OnyxUITheme = require(RoRooms.SourceCode.Client.UI.OnyxUITheme)
local Assets = require(RoRooms.SourceCode.Shared.Assets)

local Children = Fusion.Children
local Themer = OnyxUI.Themer
local OnChange = Fusion.OnChange
local Out = Fusion.Out

return function(Scope: Fusion.Scope<any>, Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components, Components)
	local Theme = Themer.Theme:now()

	local MenuOpen = Scope:Computed(function(Use)
		return Use(States.Menus.CurrentMenu) == script.Name
	end)

	local AbsoluteCanvasSize = Scope:Value(Vector2.new())
	local AbsoluteWindowSize = Scope:Value(Vector2.new())

	local WorldsMenu = Scope:Menu {
		Name = script.Name,
		Open = MenuOpen,
		Parent = Props.Parent,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.fromOffset(390, 0),
		ListHorizontalFlex = Enum.UIFlexAlignment.Fill,

		[Children] = {
			Scope:Hydrate(Scope:Scroller {
				Name = "WorldsList",
				Size = UDim2.new(UDim.new(0, 0), UDim.new(0, 205)),
				CanvasSize = UDim2.fromOffset(0, 0),
				ScrollBarThickness = Theme.StrokeThickness["1"],
				Padding = Scope:Computed(function(Use)
					return UDim.new(0, Use(Theme.StrokeThickness["1"]))
				end),
				PaddingRight = Scope:Computed(function(Use)
					return UDim.new(0, Use(Theme.Spacing["0.75"]))
				end),
				ListEnabled = true,
				ListPadding = Scope:Computed(function(Use)
					return UDim.new(0, Use(Theme.Spacing["1.5"]))
				end),
				ListHorizontalFlex = Enum.UIFlexAlignment.Fill,

				[Children] = {
					Scope:Card {
						ListEnabled = true,
						ListPadding = Scope:Computed(function(Use)
							return UDim.new(0, Use(Theme.Spacing["0.5"]))
						end),
						ListHorizontalFlex = Enum.UIFlexAlignment.Fill,
						CornerRadius = Scope:Computed(function(Use)
							return UDim.new(0, Use(Theme.CornerRadius["2"]))
						end),
						Visible = Scope:Computed(function(Use)
							return (not Use(States.Worlds.Registered))
								and (RunService:IsStudio())
								and (Config.Systems.Worlds.DiscoveryEnabled == true)
						end),

						[Children] = {
							Scope:Heading {
								Text = "Not registered ⚠️",
								HeadingSize = 1.25,
							},
							Scope:Text {
								Text = "This world will not receive support from the network. If this is intentional, you may disable the worlds system.",
							},
							Scope:TextInput {
								Text = "docs.rorooms.com/docs/publishing",
								Disabled = true,
								TextTransparency = 0,
								StrokeTransparency = 0,
							},
						},
					},
					Scope:WorldsCategory {
						Name = "Featured",
						Title = "From creator",
						Icon = Assets.Icons.General.Star,
						Visible = Scope:Computed(function(Use)
							return (#Config.Systems.Worlds.FeaturedWorlds >= 1)
								and Config.Systems.Worlds.DiscoveryEnabled
						end),

						[Children] = {
							Scope:Frame {
								Name = "Worlds",
								AutomaticSize = Enum.AutomaticSize.Y,
								ListEnabled = true,
								ListPadding = Scope:Computed(function(Use)
									return UDim.new(0, Use(Theme.Spacing["0.75"]))
								end),
								ListFillDirection = Enum.FillDirection.Horizontal,
								ListWraps = true,

								[Children] = {
									Scope:ForValues(
										Config.Systems.Worlds.FeaturedWorlds,
										function(Use, Scope, PlaceId: number)
											return Themer.Theme:is(OnyxUITheme):during(function()
												return Scope:WorldButton {
													PlaceId = PlaceId,
												}
											end)
										end
									),
								},
							},
						},
					},
					Scope:WorldsCategory {
						Name = "Global",
						Title = "Global",
						Icon = Assets.Icons.General.Globe,
						Visible = Scope:Computed(function(Use)
							return Config.Systems.Worlds.DiscoveryEnabled
						end),

						[Children] = {
							Scope:Frame {
								Name = "Worlds",
								AutomaticSize = Enum.AutomaticSize.Y,
								ListEnabled = true,
								ListPadding = Scope:Computed(function(Use)
									return UDim.new(0, Use(Theme.Spacing["0.75"]))
								end),
								ListFillDirection = Enum.FillDirection.Horizontal,
								ListWraps = true,

								[Children] = {
									Scope:ForValues(States.Worlds.AssortedWorlds, function(Use, Scope, World)
										return Themer.Theme:is(OnyxUITheme):during(function()
											return Scope:WorldButton {
												PlaceId = World.PlaceId,
											}
										end)
									end),
								},
							},
						},
					},
				},
			}) {
				[OnChange "CanvasPosition"] = function(CanvasPosition)
					local CanvasHeight = Fusion.peek(AbsoluteCanvasSize).Y - Fusion.peek(AbsoluteWindowSize).Y

					if CanvasPosition.Y >= CanvasHeight then
						Worlds:LoadAssortedWorlds()
					end
				end,
				[Out "AbsoluteCanvasSize"] = AbsoluteCanvasSize,
				[Out "AbsoluteWindowSize"] = AbsoluteWindowSize,
			},
		},
	}

	return WorldsMenu
end
