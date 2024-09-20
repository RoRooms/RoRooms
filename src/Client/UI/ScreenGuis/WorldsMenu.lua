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

local DEFAULT_LOAD_MORE_BUTTON_CONTENTS = { Assets.Icons.General.Download, "Load more" }
local DEFAULT_REFRESH_BUTTON_CONTENTS = { Assets.Icons.General.Repeat, "Refresh" }

return function(Scope: Fusion.Scope<any>, Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components, Components)
	local Theme = Themer.Theme:now()

	local MenuOpen = Scope:Computed(function(Use)
		return Use(States.Menus.CurrentMenu) == script.Name
	end)
	local LoadMoreButtonContent = Scope:Value(DEFAULT_LOAD_MORE_BUTTON_CONTENTS)
	local RefreshButtonContent = Scope:Value(DEFAULT_REFRESH_BUTTON_CONTENTS)

	local WorldsMenu = Scope:Menu {
		Name = script.Name,
		Open = MenuOpen,
		Parent = Props.Parent,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.fromOffset(375, 0),
		ListHorizontalFlex = Enum.UIFlexAlignment.Fill,

		[Children] = {
			Scope:TitleBar {
				Title = "Worlds",
				CloseButtonDisabled = true,
			},
			Scope:Scroller {
				Name = "WorldsList",
				Size = UDim2.new(UDim.new(0, 0), UDim.new(0, 205)),
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
					Scope:WorldsCategory {
						Name = "Featured",
						Title = "From creator",
						Icon = Assets.Icons.General.Star,
						Visible = Scope:Computed(function(Use)
							return #Config.Systems.Worlds.FeaturedWorlds >= 1
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
						Name = "Popular",
						Title = "Popular",
						Icon = Assets.Icons.General.People,

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
									Scope:ForValues(States.Worlds.TopWorlds, function(Use, Scope, World)
										return Themer.Theme:is(OnyxUITheme):during(function()
											return Scope:WorldButton {
												PlaceId = World.PlaceId,
											}
										end)
									end),
								},
							},
							Scope:Button {
								Name = "LoadMoreButton",
								Content = LoadMoreButtonContent,
								Color = Theme.Colors.Primary.Main,
								AutomaticSize = Enum.AutomaticSize.Y,

								OnActivated = function()
									LoadMoreButtonContent:set({
										"Loading..",
									})

									Worlds:FetchTopWorlds():andThen(function(Result)
										if typeof(Result) == "table" then
											LoadMoreButtonContent:set({
												Assets.Icons.General.Checkmark,
												"Loaded",
											})
											task.wait(0.5)
											LoadMoreButtonContent:set(DEFAULT_LOAD_MORE_BUTTON_CONTENTS)
										else
											LoadMoreButtonContent:set({
												Assets.Icons.General.Warning,
												"Error",
											})
											task.wait(0.5)
											LoadMoreButtonContent:set(DEFAULT_LOAD_MORE_BUTTON_CONTENTS)
										end
									end)
								end,
							},
						},
					},
					Scope:WorldsCategory {
						Name = "Random",
						Title = "Random",
						Icon = Assets.Icons.General.Die,

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
									Scope:ForValues(States.Worlds.RandomWorlds, function(Use, Scope, World)
										return Themer.Theme:is(OnyxUITheme):during(function()
											return Scope:WorldButton {
												PlaceId = World.PlaceId,
											}
										end)
									end),
								},
							},
							Scope:Button {
								Name = "RefreshButton",
								Content = RefreshButtonContent,
								Color = Theme.Colors.Primary.Main,
								AutomaticSize = Enum.AutomaticSize.Y,

								OnActivated = function()
									RefreshButtonContent:set({
										"Refreshing..",
									})

									Worlds:ClearRandomWorlds()
									Worlds:FetchRandomWorlds(1, true):andThen(function(Result)
										if typeof(Result) == "table" then
											RefreshButtonContent:set({
												Assets.Icons.General.Checkmark,
												"Refreshed",
											})
											task.wait(0.5)
											RefreshButtonContent:set(DEFAULT_REFRESH_BUTTON_CONTENTS)
										else
											RefreshButtonContent:set({
												Assets.Icons.General.Warning,
												"Error",
											})
											task.wait(0.5)
											RefreshButtonContent:set(DEFAULT_REFRESH_BUTTON_CONTENTS)
										end
									end)
								end,
							},
						},
					},
				},
			},
		},
	}

	return WorldsMenu
end
