local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent)

local Shared = RoRooms.Shared
local Client = RoRooms.Client
local Config = RoRooms.Config

local Fusion = require(Shared.ExtPackages.NekaUI.Packages.Fusion)
local NekaUI = require(Shared.ExtPackages.NekaUI)
local States = require(Client.UI.States)

local Children = Fusion.Children
local Computed = Fusion.Computed
local ForValues = Fusion.ForValues
local New = Fusion.New
local Spring = Fusion.Spring
local Value = Fusion.Value
local Cleanup = Fusion.Cleanup

local Components = Client.UI.Components
local TopbarButton = require(Components.TopbarButton)
local AutoScaleFrame = require(NekaUI.Components.AutoScaleFrame)
local Frame = require(NekaUI.Components.Frame)
local BaseButton = require(NekaUI.Components.BaseButton)

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
				BaseResolution = Vector2.new(883, 893),
				ScaleClamps = { Min = 0.75, Max = math.huge },

				[Children] = {
					New "UIListLayout" {
						SortOrder = Enum.SortOrder.LayoutOrder,
						Padding = UDim.new(0, 15),
						HorizontalAlignment = Enum.HorizontalAlignment.Center,
					},
					Frame {
						Name = "TopbarButtons",

						[Children] = {
							New "UIListLayout" {
								SortOrder = Enum.SortOrder.LayoutOrder,
								Padding = UDim.new(0, 13),
								FillDirection = Enum.FillDirection.Horizontal,
								VerticalAlignment = Enum.VerticalAlignment.Center,
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
						BackgroundTransparency = 0,
						BackgroundColor3 = Color3.fromRGB(26, 26, 26),
						Visible = Computed(function()
							return (typeof(States.CurrentMenu:get()) == "string") == false
						end),

						OnActivated = function()
							States.TopbarVisible:set(not States.TopbarVisible:get())
							States.CurrentMenu:set(nil)
							-- States.UserSettings.HideUI:set(false)
						end,

						[Children] = {
							New "UICorner" {
								CornerRadius = UDim.new(0, 25),
							},
							New "UIStroke" {
								ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
								Thickness = 3,
								Color = Color3.fromRGB(56, 56, 56),
							},
							New "UIPadding" {
								PaddingLeft = UDim.new(0, 16),
								PaddingBottom = UDim.new(0, 8),
								PaddingTop = UDim.new(0, 8),
								PaddingRight = UDim.new(0, 16),
							},
							New "Frame" {
								Size = UDim2.fromOffset(120, 3),
								AutomaticSize = Enum.AutomaticSize.None,
								BackgroundTransparency = 0,
								BackgroundColor3 = Color3.fromRGB(255, 255, 255),
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
