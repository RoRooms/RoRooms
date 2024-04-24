local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent)

local Shared = RoRooms.Shared
local Client = RoRooms.Client

local Fusion = require(Shared.ExtPackages.OnyxUI.Packages.Fusion)
local OnyxUI = require(Shared.ExtPackages.OnyxUI)
local States = require(Client.UI.States)
local Modifier = require(OnyxUI.Utils.Modifier)
local Themer = require(OnyxUI.Utils.Themer)

local Children = Fusion.Children
local Computed = Fusion.Computed
local ForValues = Fusion.ForValues
local New = Fusion.New
local Spring = Fusion.Spring
local Value = Fusion.Value
local Cleanup = Fusion.Cleanup

local Components = Client.UI.Components
local TopbarButton = require(Components.TopbarButton)
local AutoScaleFrame = require(OnyxUI.Components.AutoScaleFrame)
local Frame = require(OnyxUI.Components.Frame)
local BaseButton = require(OnyxUI.Components.BaseButton)

return function(Props)
	local TopbarButtonsHeight = Value(0)

	local CleanupHolder = {}

	local TopbarInstance = New "ScreenGui" {
		Name = "Topbar",
		Parent = Props.Parent,
		ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets,
		ResetOnSpawn = false,

		[Cleanup] = {
			CleanupHolder,
		},

		[Children] = {
			AutoScaleFrame {
				AnchorPoint = Vector2.new(0.5, 0),
				Position = Spring(
					Computed(function()
						if States.TopbarVisible:get() then
							return UDim2.new(UDim.new(0.5, 0), UDim.new(0, 14))
						else
							return UDim2.new(UDim.new(0.5, 0), UDim.new(0, (-TopbarButtonsHeight:get()) - 2))
						end
					end),
					40,
					1
				),
				BaseResolution = Vector2.new(739, 789),
				ScaleClamps = { Min = 1, Max = math.huge },

				[Children] = {
					Modifier.ListLayout {
						Padding = Computed(function()
							return UDim.new(0, Themer.Theme.Spacing["0.5"]:get())
						end),
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
					},

					Frame {
						Name = "TopbarButtons",
						BackgroundColor3 = Themer.Theme.Colors.Base.Main,
						BackgroundTransparency = States.PreferredTransparency,

						[Children] = {
							Modifier.ListLayout {
								Padding = Computed(function()
									return UDim.new(0, Themer.Theme.Spacing["0.25"]:get())
								end),
								FillDirection = Enum.FillDirection.Horizontal,
								VerticalAlignment = Enum.VerticalAlignment.Center,
							},
							Modifier.Corner {
								CornerRadius = Computed(function()
									return UDim.new(0, Themer.Theme.CornerRadius.Full:get())
								end),
							},
							Modifier.Padding {
								Padding = Computed(function()
									return UDim.new(0, Themer.Theme.Spacing["0.5"]:get() / 1.25)
								end),
							},

							ForValues(States.TopbarButtons, function(Button)
								return TopbarButton {
									MenuName = Button.MenuName,
									IconImage = Button.IconImage,
									SizeMultiplier = Button.SizeMultiplier,
									LayoutOrder = Button.LayoutOrder,
								}
							end, Fusion.cleanup),
						},
					},
					BaseButton {
						Name = "PullButton",
						BackgroundTransparency = States.PreferredTransparency,
						BackgroundColor3 = Themer.Theme.Colors.Base.Main,
						Visible = Computed(function()
							return not (typeof(States.CurrentMenu:get()) == "string")
						end),
						TextSize = 0,

						OnActivated = function()
							States.TopbarVisible:set(not States.TopbarVisible:get())
							States.CurrentMenu:set(nil)
						end,

						[Children] = {
							Modifier.Corner {
								CornerRadius = Computed(function()
									return UDim.new(0, Themer.Theme.CornerRadius.Full:get())
								end),
							},
							Modifier.Padding {
								PaddingTop = Computed(function()
									return UDim.new(0, Themer.Theme.Spacing["0.5"]:get())
								end),
								PaddingLeft = Computed(function()
									return UDim.new(0, Themer.Theme.Spacing["0.75"]:get())
								end),
								PaddingRight = Computed(function()
									return UDim.new(0, Themer.Theme.Spacing["0.75"]:get())
								end),
								PaddingBottom = Computed(function()
									return UDim.new(0, Themer.Theme.Spacing["0.5"]:get())
								end),
							},
							Modifier.Stroke {
								Color = Themer.Theme.Colors.Neutral.Main,
							},

							Frame {
								Size = Computed(function()
									return UDim2.fromOffset(100, Themer.Theme.StrokeThickness["1"]:get())
								end),
								AutomaticSize = Enum.AutomaticSize.None,
								BackgroundTransparency = 0,
								BackgroundColor3 = Themer.Theme.Colors.BaseContent.Main,
							},
						},
					},
				},
			},
		},
	}

	local TopbarButtons = TopbarInstance.AutoScaleFrame.TopbarButtons
	local TopbarPully = TopbarInstance.AutoScaleFrame.PullButton

	local function UpdateTopbarBottomPos()
		States.TopbarBottomPos:set(TopbarPully.AbsolutePosition.Y)
	end

	table.insert(CleanupHolder, TopbarPully:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateTopbarBottomPos))
	table.insert(CleanupHolder, TopbarPully:GetPropertyChangedSignal("AbsolutePosition"):Connect(UpdateTopbarBottomPos))
	UpdateTopbarBottomPos()

	local function UpdateTopbarButtonsHeight()
		TopbarButtonsHeight:set(TopbarButtons.AbsoluteSize.Y)
	end

	table.insert(
		CleanupHolder,
		TopbarButtons:GetPropertyChangedSignal("AbsoluteSize"):Connect(UpdateTopbarButtonsHeight)
	)
	UpdateTopbarButtonsHeight()

	return TopbarInstance
end
