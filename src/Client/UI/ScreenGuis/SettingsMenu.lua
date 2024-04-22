local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent)

local Shared = RoRooms.Shared
local Client = RoRooms.Client

local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")

local Fusion = require(Shared.ExtPackages.OnyxUI.Packages.Fusion)
local OnyxUI = require(Shared.ExtPackages.OnyxUI)
local States = require(Client.UI.States)

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
							YPos = YPos + 15
						end
						return UDim2.new(UDim.new(0.5, 0), UDim.new(0, YPos))
					end),
					37,
					1
				),
				BaseResolution = Vector2.new(883, 893),

				[Children] = {
					New "UIListLayout" {},
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
							40,
							1
						),

						[Children] = {
							New "UIPadding" {
								PaddingBottom = UDim.new(0, 13),
								PaddingLeft = UDim.new(0, 13),
								PaddingRight = UDim.new(0, 13),
								PaddingTop = UDim.new(0, 9),
							},
							TitleBar {
								Title = "Settings",
								CloseButtonDisabled = true,
								TextSize = 24,
							},
							ScrollingFrame {
								Size = UDim2.new(UDim.new(1, 0), UDim.new(0, 135)),
								AutomaticSize = Enum.AutomaticSize.None,

								[Children] = {
									New "UIListLayout" {
										SortOrder = Enum.SortOrder.LayoutOrder,
										Padding = UDim.new(0, 10),
									},
									New "UIPadding" {
										PaddingTop = UDim.new(0, 2),
										PaddingBottom = UDim.new(0, 3),
										PaddingRight = UDim.new(0, 2),
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
										TextColor3 = Color3.fromRGB(124, 124, 124),
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
