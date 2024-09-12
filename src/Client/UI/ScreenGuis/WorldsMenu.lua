local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent)
local OnyxUI = require(RoRooms.Packages.OnyxUI)
local Fusion = require(RoRooms.Packages.Fusion)
local States = require(RoRooms.Client.UI.States)

local Worlds = require(RoRooms.Client.UI.States.Worlds)

local Children = Fusion.Children
local Util = OnyxUI.Util
local Themer = OnyxUI.Themer

local WorldButton = require(RoRooms.Client.UI.Components.WorldButton)
local WorldsCategory = require(RoRooms.Client.UI.Components.WorldsCategory)

local DEFAULT_LOAD_MORE_BUTTON_CONTENTS = { "rbxassetid://17293213744", "Load more" }
local DEFAULT_REFRESH_BUTTON_CONTENTS = { "rbxassetid://13858012326", "Refresh" }

return function(Scope: Fusion.Scope<any>, Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components)
	local Theme = Themer.Theme:now()

	local MenuOpen = Scope:Computed(function(Use)
		return Use(States.CurrentMenu) == script.Name
	end)
	local LoadMoreButtonContents = Scope:Value(DEFAULT_LOAD_MORE_BUTTON_CONTENTS)
	local RefreshButtonContents = Scope:Value(DEFAULT_REFRESH_BUTTON_CONTENTS)

	local WorldsMenu = Scope:New "ScreenGui" {
		Name = "WorldsMenu",
		Parent = Props.Parent,
		Enabled = MenuOpen,
		ResetOnSpawn = false,

		[Children] = {
			Scope:AutoScaleFrame {
				AnchorPoint = Vector2.new(0.5, 0),
				Position = Scope:Spring(
					Scope:Computed(function(Use)
						local YPos = Use(States.TopbarBottomPos)
						if not Use(MenuOpen) then
							YPos = YPos + 15
						end
						return UDim2.new(UDim.new(0.5, 0), UDim.new(0, YPos))
					end),
					Theme.SpringSpeed["1"],
					Theme.SpringDampening["1"]
				),
				BaseResolution = Vector2.new(739, 789),
				MinScale = 1,
				MaxScale = 1,

				[Children] = {
					Scope:MenuFrame {
						Size = UDim2.fromOffset(375, 0),
						GroupTransparency = Scope:Spring(
							Scope:Computed(function(Use)
								if Use(MenuOpen) then
									return 0
								else
									return 1
								end
							end),
							Theme.SpringSpeed["1"],
							Theme.SpringDampening["1"]
						),
						BackgroundTransparency = States.PreferredTransparency,
						ListEnabled = true,

						[Children] = {
							Scope:TitleBar {
								Title = "Worlds",
								CloseButtonDisabled = true,
							},
							Scope:Scroller {
								Name = "WorldsList",
								Size = UDim2.new(UDim.new(1, 0), UDim.new(0, 205)),
								ScrollBarThickness = Theme.StrokeThickness["1"],
								ScrollBarImageColor3 = Theme.Util.Colors.NeutralContent.Dark,
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
								ListFillDirection = Enum.FillDirection.Horizontal,
								ListWraps = true,

								[Children] = {
									Scope:WorldsCategory {
										Name = "Featured",
										Title = "From creator",
										Icon = "rbxassetid://17292608120",
										Visible = Scope:Computed(function(Use)
											return #RoRooms.Config.Systems.Worlds.FeaturedWorlds >= 1
										end),

										[Children] = {
											Scope:Frame {
												Name = "Worlds",
												Size = UDim2.fromScale(1, 0),
												AutomaticSize = Enum.AutomaticSize.Y,
												ListEnabled = true,
												ListPadding = Scope:Computed(function(Use)
													return UDim.new(0, Use(Theme.Spacing["0.75"]))
												end),
												ListFillDirection = Enum.FillDirection.Horizontal,
												ListWraps = true,

												[Children] = {
													Scope:ForValues(
														RoRooms.Config.Systems.Worlds.FeaturedWorlds,
														function(PlaceId: number)
															return Scope:WorldButton {
																PlaceId = PlaceId,
															}
														end
													),
												},
											},
										},
									},
									Scope:WorldsCategory {
										Name = "Popular",
										Title = "Popular",
										Icon = "rbxassetid://17292608258",

										[Children] = {
											Scope:Frame {
												Name = "Worlds",
												Size = UDim2.fromScale(1, 0),
												AutomaticSize = Enum.AutomaticSize.Y,
												ListEnabled = true,
												ListPadding = Scope:Computed(function(Use)
													return UDim.new(0, Use(Theme.Spacing["0.75"]))
												end),
												ListFillDirection = Enum.FillDirection.Horizontal,
												ListWraps = true,

												[Children] = {
													Scope:ForValues(
														States.Worlds.TopWorlds,
														function(World: { [string]: any })
															return Scope:WorldButton(table.clone(World))
														end
													),
												},
											},
											Scope:Button {
												Name = "LoadMoreButton",
												Contents = LoadMoreButtonContents,
												Size = UDim2.fromScale(1, 0),
												AutomaticSize = Enum.AutomaticSize.Y,

												OnActivated = function()
													LoadMoreButtonContents:set({
														"rbxassetid://14906067807",
														"Loading",
													})

													Worlds:FetchTopWorlds():andThen(function(Result)
														if typeof(Result) == "table" then
															LoadMoreButtonContents:set({
																"rbxassetid://13858820127",
																"Loaded",
															})
															task.wait(0.5)
															LoadMoreButtonContents:set(
																DEFAULT_LOAD_MORE_BUTTON_CONTENTS
															)
														else
															LoadMoreButtonContents:set({
																"rbxassetid://14906266795",
																"Error",
															})
															task.wait(0.5)
															LoadMoreButtonContents:set(
																DEFAULT_LOAD_MORE_BUTTON_CONTENTS
															)
														end
													end)
												end,
											},
										},
									},
									Scope:WorldsCategory {
										Name = "Random",
										Title = "Random",
										Icon = "rbxassetid://17292608467",

										[Children] = {
											Scope:Frame {
												Name = "Worlds",
												Size = UDim2.fromScale(1, 0),
												AutomaticSize = Enum.AutomaticSize.Y,
												ListEnabled = true,
												ListPadding = Scope:Computed(function(Use)
													return UDim.new(0, Use(Theme.Spacing["0.75"]))
												end),
												ListFillDirection = Enum.FillDirection.Horizontal,
												ListWraps = true,

												[Children] = {
													Scope:ForValues(
														States.Worlds.RandomWorlds,
														function(World: { [string]: any })
															return Scope:WorldButton(table.clone(World))
														end
													),
												},
											},
											Scope:Button {
												Name = "RefreshButton",
												Contents = RefreshButtonContents,
												Size = UDim2.fromScale(1, 0),
												AutomaticSize = Enum.AutomaticSize.Y,

												OnActivated = function()
													RefreshButtonContents:set({
														"rbxassetid://14906067807",
														"Refreshing",
													})

													Worlds:ClearRandomWorlds()
													Worlds:FetchRandomWorlds(1, true):andThen(function(Result)
														if typeof(Result) == "table" then
															RefreshButtonContents:set({
																"rbxassetid://13858820127",
																"Refreshed",
															})
															task.wait(0.5)
															RefreshButtonContents:set(DEFAULT_REFRESH_BUTTON_CONTENTS)
														else
															RefreshButtonContents:set({
																"rbxassetid://14906266795",
																"Error",
															})
															task.wait(0.5)
															RefreshButtonContents:set(DEFAULT_REFRESH_BUTTON_CONTENTS)
														end
													end)
												end,
											},
										},
									},
								},
							},
						},
					},
				},
			},
		},
	}

	return WorldsMenu
end
