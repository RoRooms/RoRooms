local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent)
local OnyxUI = require(RoRooms.Packages.OnyxUI)
local Fusion = require(RoRooms.Packages.Fusion)
local States = require(RoRooms.Client.UI.States)

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
					Theme.SpringSpeed["1"],
					Theme.SpringDampening
				),
				BaseResolution = Vector2.new(739, 789),
				MinScale = 1,
				MaxScale = 1,

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
							Theme.SpringSpeed["1"],
							Theme.SpringDampening
						),
						BackgroundTransparency = States.PreferredTransparency,
						AutomaticSize = Enum.AutomaticSize.XY,
						ListEnabled = true,

						[Children] = {
							TitleBar {
								Title = "Emotes",
								CloseButtonDisabled = true,
							},
							Frame {
								Size = UDim2.new(UDim.new(0, 0), UDim.new(0, 185)),
								AutomaticSize = Enum.AutomaticSize.X,
								ListEnabled = true,
								ListFillDirection = Enum.FillDirection.Horizontal,
								ListPadding = Computed(function()
									return UDim.new(0, Theme.Spacing["0.75"]:get())
								end),

								[Children] = {
									EmoteCategoriesSidebar {
										Size = UDim2.fromScale(0, 1),
									},
									ScrollingFrame {
										Name = "EmotesList",
										Size = Computed(function()
											return UDim2.new(UDim.new(0, 260), UDim.new(1, 0))
										end),
										ScrollBarThickness = Theme.StrokeThickness["1"],
										ScrollBarImageColor3 = Theme.Colors.NeutralContent.Dark,
										Padding = Computed(function()
											return UDim.new(0, Theme.StrokeThickness["1"]:get())
										end),
										ListEnabled = true,
										ListPadding = Computed(function()
											return UDim.new(0, Theme.Spacing["1"]:get())
										end),
										ListFillDirection = Enum.FillDirection.Horizontal,
										ListWraps = true,

										[Children] = {
											ForPairs(
												RoRooms.Config.Systems.Emotes.Categories,
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
		local EmotesList = EmotesMenu.AutoScaleFrame.MenuFrame.Contents.Frame.EmotesList
		local Category = EmotesList:FindFirstChild(`{States.EmotesMenu.FocusedCategory:get()}EmotesCategory`)
		if Category then
			EmotesList.CanvasPosition = Vector2.new(0, 0)
			EmotesList.CanvasPosition = Vector2.new(0, Category.AbsolutePosition.Y - EmotesList.AbsolutePosition.Y)
		end
	end)

	EmotesMenu:GetPropertyChangedSignal("Parent"):Connect(function()
		if EmotesMenu.Parent == nil then
			DisconnectFocusedCategory()
		end
	end)

	return EmotesMenu
end
