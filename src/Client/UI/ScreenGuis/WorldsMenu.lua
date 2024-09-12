local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent)
local OnyxUI = require(RoRooms.Packages.OnyxUI)
local Fusion = require(RoRooms.Packages.Fusion)
local States = require(RoRooms.Client.UI.States)

local Worlds = require(RoRooms.Client.UI.States.Worlds)

local Children = Fusion.Children
local Computed = Fusion.Computed
local New = Fusion.New
local Spring = Fusion.Spring
local ForValues = Fusion.ForValues
local Value = Fusion.Value

local AutoScaleFrame = require(OnyxUI.Components.AutoScaleFrame)
local MenuFrame = require(OnyxUI.Components.MenuFrame)
local TitleBar = require(OnyxUI.Components.TitleBar)
local ScrollingFrame = require(OnyxUI.Components.ScrollingFrame)
local WorldButton = require(RoRooms.Client.UI.Components.WorldButton)
local WorldsCategory = require(RoRooms.Client.UI.Components.WorldsCategory)
local Button = require(OnyxUI.Components.Button)
local Frame = require(OnyxUI.Components.Frame)

local DEFAULT_LOAD_MORE_BUTTON_CONTENTS = { "rbxassetid://17293213744", "Load more" }
local DEFAULT_REFRESH_BUTTON_CONTENTS = { "rbxassetid://13858012326", "Refresh" }

return function(Props)
	local MenuOpen = Computed(function()
		return Use(States.CurrentMenu) == script.Name
	end)
	local LoadMoreButtonContents = Value(DEFAULT_LOAD_MORE_BUTTON_CONTENTS)
	local RefreshButtonContents = Value(DEFAULT_REFRESH_BUTTON_CONTENTS)

	local WorldsMenu = New "ScreenGui" {
		Name = "WorldsMenu",
		Parent = Props.Parent,
		Enabled = MenuOpen,
		ResetOnSpawn = false,

		[Children] = {
			AutoScaleFrame {
				AnchorPoint = Vector2.new(0.5, 0),
				Position = Spring(
					Computed(function()
						local YPos = Use(States.TopbarBottomPos)
						if not Use(MenuOpen) then
							YPos = YPos + 15
						end
						return UDim2.new(UDim.new(0.5, 0), UDim.new(0, YPos))
					end),
					Theme.SpringSpeed["1"],
					Theme.SpringDampening
				),
				BaseResolution = Vector2.new(739, 789),
				MinScale = 1,
				MaxScale = 1,

				[Children] = {
					MenuFrame {
						Size = UDim2.fromOffset(375, 0),
						GroupTransparency = Spring(
							Computed(function()
								if Use(MenuOpen) then
									return 0
								else
									return 1
								end
							end),
							Theme.SpringSpeed["1"],
							Theme.SpringDampening
						),
						BackgroundTransparency = States.PreferredTransparency,
						ListEnabled = true,

						[Children] = {
							TitleBar {
								Title = "Worlds",
								CloseButtonDisabled = true,
							},
							ScrollingFrame {
								Name = "WorldsList",
								Size = UDim2.new(UDim.new(1, 0), UDim.new(0, 205)),
								ScrollBarThickness = Theme.StrokeThickness["1"],
								ScrollBarImageColor3 = Theme.Colors.NeutralContent.Dark,
								Padding = Computed(function()
									return UDim.new(0, Theme.StrokeThickness["1"]:get())
								end),
								PaddingRight = Computed(function()
									return UDim.new(0, Theme.Spacing["0.75"]:get())
								end),
								ListEnabled = true,
								ListPadding = Computed(function()
									return UDim.new(0, Theme.Spacing["1.5"]:get())
								end),
								ListFillDirection = Enum.FillDirection.Horizontal,
								ListWraps = true,

								[Children] = {
									WorldsCategory {
										Name = "Featured",
										Title = "From creator",
										Icon = "rbxassetid://17292608120",
										Visible = Computed(function()
											return #RoRooms.Config.Systems.Worlds.FeaturedWorlds >= 1
										end),

										[Children] = {
											Frame {
												Name = "Worlds",
												Size = UDim2.fromScale(1, 0),
												AutomaticSize = Enum.AutomaticSize.Y,
												ListEnabled = true,
												ListPadding = Computed(function()
													return UDim.new(0, Theme.Spacing["0.75"]:get())
												end),
												ListFillDirection = Enum.FillDirection.Horizontal,
												ListWraps = true,

												[Children] = {
													ForValues(
														RoRooms.Config.Systems.Worlds.FeaturedWorlds,
														function(PlaceId: number)
															return WorldButton {
																PlaceId = PlaceId,
															}
														end,
														Fusion.cleanup
													),
												},
											},
										},
									},
									WorldsCategory {
										Name = "Popular",
										Title = "Popular",
										Icon = "rbxassetid://17292608258",

										[Children] = {
											Frame {
												Name = "Worlds",
												Size = UDim2.fromScale(1, 0),
												AutomaticSize = Enum.AutomaticSize.Y,
												ListEnabled = true,
												ListPadding = Computed(function()
													return UDim.new(0, Theme.Spacing["0.75"]:get())
												end),
												ListFillDirection = Enum.FillDirection.Horizontal,
												ListWraps = true,

												[Children] = {
													ForValues(
														States.Worlds.TopWorlds,
														function(World: { [string]: any })
															return WorldButton(table.clone(World))
														end,
														Fusion.cleanup
													),
												},
											},
											Button {
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
									WorldsCategory {
										Name = "Random",
										Title = "Random",
										Icon = "rbxassetid://17292608467",

										[Children] = {
											Frame {
												Name = "Worlds",
												Size = UDim2.fromScale(1, 0),
												AutomaticSize = Enum.AutomaticSize.Y,
												ListEnabled = true,
												ListPadding = Computed(function()
													return UDim.new(0, Theme.Spacing["0.75"]:get())
												end),
												ListFillDirection = Enum.FillDirection.Horizontal,
												ListWraps = true,

												[Children] = {
													ForValues(
														States.Worlds.RandomWorlds,
														function(World: { [string]: any })
															return WorldButton(table.clone(World))
														end,
														Fusion.cleanup
													),
												},
											},
											Button {
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
