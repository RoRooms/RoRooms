local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")

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

local AutoScaleFrame = require(OnyxUI.Components.AutoScaleFrame)
local MenuFrame = require(OnyxUI.Components.MenuFrame)
local TitleBar = require(OnyxUI.Components.TitleBar)
local SettingToggle = require(OnyxUI.Components.SettingToggle)
local ScrollingFrame = require(OnyxUI.Components.ScrollingFrame)
local Text = require(OnyxUI.Components.Text)

local TOGGLEABLE_CORE_GUIS = { Enum.CoreGuiType.Chat, Enum.CoreGuiType.PlayerList }

return function(Props)
	local MenuOpen = Computed(function()
		return States.CurrentMenu:get() == script.Name
	end)

	Observer(States.UserSettings.HideUI):onChange(function()
		for _, CoreGuiType in ipairs(TOGGLEABLE_CORE_GUIS) do
			StarterGui:SetCoreGuiEnabled(CoreGuiType, not States.UserSettings.HideUI:get())
		end
		States.TopbarVisible:set(not States.UserSettings.HideUI:get())
		if States.UserSettings.HideUI:get() then
			States.CurrentMenu:set(nil)
		end
	end)
	if Players.LocalPlayer then
		Players.LocalPlayer.CharacterAdded:Connect(function()
			States.UserSettings.HideUI:set(false)
		end)
	end

	local SettingsMenu = New "ScreenGui" {
		Name = "SettingsMenu",
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
							YPos = YPos + Themer.Theme.Spacing["1"]:get()
						end
						return UDim2.new(UDim.new(0.5, 0), UDim.new(0, YPos))
					end),
					37,
					1
				),
				BaseResolution = Vector2.new(739, 789),
				ScaleClamps = { Min = 1, Max = 1 },

				[Children] = {
					Modifier.ListLayout {},

					MenuFrame {
						Size = UDim2.fromOffset(305, 0),
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

						[Children] = {
							Modifier.ListLayout {},

							TitleBar {
								Title = "Settings",
								CloseButtonDisabled = true,
							},
							ScrollingFrame {
								Size = UDim2.new(UDim.new(1, 0), UDim.new(0, 135)),
								AutomaticSize = Enum.AutomaticSize.None,
								ScrollBarThickness = Themer.Theme.StrokeThickness["1"],
								ScrollBarImageColor3 = Themer.Theme.Colors.NeutralContent.Dark,

								[Children] = {
									Modifier.ListLayout {},
									Modifier.Padding {
										PaddingTop = Computed(function()
											return UDim.new(0, Themer.Theme.StrokeThickness["1"]:get())
										end),
										PaddingRight = Computed(function()
											return UDim.new(0, Themer.Theme.Spacing["1"]:get())
										end),
									},

									SettingToggle {
										Label = "Mute music",
										SwitchedOn = States.UserSettings.MuteMusic,
									},
									SettingToggle {
										Label = "Hide UI",
										SwitchedOn = States.UserSettings.HideUI,
									},
									Text {
										Text = "[RoRooms v0.0.0]",
										TextColor3 = Themer.Theme.Colors.NeutralContent.Dark,
									},
								},
							},
						},
					},
				},
			},
		},
	}

	return SettingsMenu
end
