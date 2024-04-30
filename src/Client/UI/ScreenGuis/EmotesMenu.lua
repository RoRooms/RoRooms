local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent)
local OnyxUI = require(RoRooms.Packages.OnyxUI)
local Fusion = require(OnyxUI.Packages.Fusion)
local States = require(RoRooms.Client.UI.States)
local Modifier = require(OnyxUI.Utils.Modifier)
local Themer = require(OnyxUI.Utils.Themer)

local Children = Fusion.Children
local New = Fusion.New
local Computed = Fusion.Computed
local Spring = Fusion.Spring
local Observer = Fusion.Observer
local ForPairs = Fusion.ForPairs

local AutoScaleFrame = require(OnyxUI.Components.AutoScaleFrame)
local MenuFrame = require(OnyxUI.Components.MenuFrame)
local TitleBar = require(OnyxUI.Components.TitleBar)
local ScrollingFrame = require(OnyxUI.Components.ScrollingFrame)
local EmotesCategory = require(RoRooms.Client.UI.Components.EmotesCategory)
local EmoteCategoriesSidebar = require(RoRooms.Client.UI.Components.EmoteCategoriesSidebar)
local Frame = require(OnyxUI.Components.Frame)

return function(Props)
	local MenuOpen = Computed(function()
		return States.CurrentMenu:get() == script.Name
	end)

	local EmotesMenu = New "ScreenGui" {
		Name = "EmotesMenu",
		Parent = Props.Parent,
		Enabled = MenuOpen,
		ResetOnSpawn = false,

		[Children] = {
			AutoScaleFrame {
				AnchorPoint = Vector2.new(0.5, 0),
				Position = Spring(
					Computed(function()
						local YPos = States.TopbarBottomPos:get()
						if not MenuOpen:get() then
							YPos = YPos + 15
						end
						return UDim2.new(UDim.new(0.5, 0), UDim.new(0, YPos))
					end),
					Themer.Theme.SpringSpeed["1"],
					Themer.Theme.SpringDampening
				),
				BaseResolution = Vector2.new(739, 789),
				ScaleClamps = { Min = 1, Max = 1 },

				[Children] = {
					MenuFrame {
						Size = UDim2.fromOffset(0, 0),
						GroupTransparency = Spring(
							Computed(function()
								if MenuOpen:get() then
									return 0
								else
									return 1
								end
							end),
							Themer.Theme.SpringSpeed["1"],
							Themer.Theme.SpringDampening
						),
						BackgroundTransparency = States.PreferredTransparency,
						AutomaticSize = Enum.AutomaticSize.XY,

						[Children] = {
							Modifier.ListLayout {},

							TitleBar {
								Title = "Emotes",
								CloseButtonDisabled = true,
							},
							Frame {
								Size = UDim2.new(UDim.new(0, 0), UDim.new(0, 185)),
								AutomaticSize = Enum.AutomaticSize.X,

								[Children] = {
									Modifier.ListLayout {
										FillDirection = Enum.FillDirection.Horizontal,
										Padding = Computed(function()
											return UDim.new(0, Themer.Theme.Spacing["0.75"]:get())
										end),
									},

									EmoteCategoriesSidebar {
										Size = UDim2.fromScale(0, 1),
									},
									ScrollingFrame {
										Name = "EmotesList",
										Size = Computed(function()
											return UDim2.new(UDim.new(0, 255), UDim.new(1, 0))
										end),
										ScrollBarThickness = Themer.Theme.StrokeThickness["1"],
										ScrollBarImageColor3 = Themer.Theme.Colors.NeutralContent.Dark,

										[Children] = {
											Modifier.Padding {
												Padding = Computed(function()
													return UDim.new(0, Themer.Theme.StrokeThickness["1"]:get())
												end),
											},
											Modifier.ListLayout {
												Padding = Computed(function()
													return UDim.new(0, Themer.Theme.Spacing["1"]:get())
												end),
												FillDirection = Enum.FillDirection.Horizontal,
												Wraps = true,
											},

											ForPairs(
												RoRooms.Config.EmotesSystem.Categories,
												function(Name: string, Category)
													return Name,
														EmotesCategory {
															CategoryName = Name,
															LayoutOrder = Category.LayoutOrder,
														}
												end,
												Fusion.cleanup
											),
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

	local DisconnectFocusedCategory = Observer(States.EmotesMenu.FocusedCategory):onChange(function()
		local Emotes = EmotesMenu.AutoScaleFrame.MenuFrame.Contents.Frame.EmotesList
		local Category = Emotes.Contents:FindFirstChild(`{States.EmotesMenu.FocusedCategory:get()}EmotesCategory`)
		if Category then
			Emotes.CanvasPosition = Vector2.new(0, 0)
			Emotes.CanvasPosition = Vector2.new(0, Category.AbsolutePosition.Y - Emotes.AbsolutePosition.Y)
		end
	end)

	EmotesMenu:GetPropertyChangedSignal("Parent"):Connect(function()
		if EmotesMenu.Parent == nil then
			DisconnectFocusedCategory()
		end
	end)

	return EmotesMenu
end
