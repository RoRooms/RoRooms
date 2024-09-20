local RoRooms = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(RoRooms.Parent.OnyxUI)
local Fusion = require(RoRooms.Parent.Fusion)
local States = require(RoRooms.SourceCode.Client.UI.States)
local Components = require(RoRooms.SourceCode.Client.UI.Components)

local Children = Fusion.Children
local Themer = OnyxUI.Themer
local Peek = Fusion.peek

return function(Scope: Fusion.Scope<any>, Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components, Components)
	local Theme = Themer.Theme:now()

	local TopbarButtonsHeight = Scope:Value(0)

	local CleanupHolder = {}

	local TopbarInstance = Scope:New "ScreenGui" {
		Name = "TopbarHUD",
		Parent = Props.Parent,
		ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets,
		ResetOnSpawn = false,

		[Children] = {
			Scope:Frame {
				Name = "Topbar",
				AnchorPoint = Vector2.new(0.5, 0),
				Position = Scope:Spring(
					Scope:Computed(function(Use)
						if Use(States.Topbar.Visible) then
							return UDim2.new(UDim.new(0.5, 0), UDim.new(0, 14))
						else
							return UDim2.new(UDim.new(0.5, 0), UDim.new(0, (-Use(TopbarButtonsHeight)) - 2))
						end
					end),
					40,
					1
				),
				ListEnabled = true,
				ListPadding = Scope:Computed(function(Use)
					return UDim.new(0, Use(Theme.Spacing["0.5"]))
				end),
				ListHorizontalAlignment = Enum.HorizontalAlignment.Center,

				[Children] = {
					Scope:Frame {
						Name = "TopbarButtons",
						BackgroundColor3 = Theme.Colors.Base.Main,
						BackgroundTransparency = States.CoreGui.PreferredTransparency,
						ListEnabled = true,
						ListPadding = Scope:Computed(function(Use)
							return UDim.new(0, Use(Theme.Spacing["0.25"]))
						end),
						ListFillDirection = Enum.FillDirection.Horizontal,
						ListVerticalAlignment = Enum.VerticalAlignment.Center,
						CornerRadius = Scope:Computed(function(Use)
							return UDim.new(0, Use(Theme.CornerRadius.Full))
						end),
						Padding = Scope:Computed(function(Use)
							return UDim.new(0, Use(Theme.Spacing["0.5"]) / 1.25)
						end),

						[Children] = {
							Scope:ForValues(States.Topbar.Buttons, function(Use, Scope, Button)
								return Scope:TopbarButton(table.clone(Button))
							end),
						},
					},
					Scope:BaseButton {
						Name = "PullButton",
						BackgroundTransparency = States.CoreGui.PreferredTransparency,
						BackgroundColor3 = Theme.Colors.Base.Main,
						Visible = Scope:Computed(function(Use)
							return not (typeof(Use(States.Menus.CurrentMenu)) == "string")
						end),
						TextSize = 0,
						CornerRadius = Scope:Computed(function(Use)
							return UDim.new(0, Use(Theme.CornerRadius.Full))
						end),
						PaddingTop = Scope:Computed(function(Use)
							return UDim.new(0, Use(Theme.Spacing["0.5"]))
						end),
						PaddingLeft = Scope:Computed(function(Use)
							return UDim.new(0, Use(Theme.Spacing["0.75"]))
						end),
						PaddingRight = Scope:Computed(function(Use)
							return UDim.new(0, Use(Theme.Spacing["0.75"]))
						end),
						PaddingBottom = Scope:Computed(function(Use)
							return UDim.new(0, Use(Theme.Spacing["0.5"]))
						end),
						StrokeColor = Theme.Colors.Neutral.Main,

						OnActivated = function()
							States.Topbar.Visible:set(not Peek(States.Topbar.Visible))
							States.Menus.CurrentMenu:set(nil)
						end,

						[Children] = {
							Scope:Frame {
								Size = Scope:Computed(function(Use)
									return UDim2.fromOffset(100, Use(Theme.StrokeThickness["1"]))
								end),
								AutomaticSize = Enum.AutomaticSize.None,
								BackgroundTransparency = 0,
								BackgroundColor3 = Theme.Colors.BaseContent.Main,
							},
						},
					},
				},
			},
		},
	}

	local TopbarButtons = TopbarInstance.Topbar.TopbarButtons
	local TopbarPully = TopbarInstance.Topbar.PullButton

	local function UpdateTopbarBottomPos()
		States.Topbar.YPosition:set(TopbarPully.AbsolutePosition.Y)
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

	table.insert(Scope, {
		function()
			Fusion.doCleanup(CleanupHolder)
		end,
	})

	return TopbarInstance
end
