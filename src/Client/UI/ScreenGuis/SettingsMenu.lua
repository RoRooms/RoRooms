local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")

local RoRooms = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(RoRooms.Parent.OnyxUI)
local Fusion = require(RoRooms.Packages.Fusion)
local States = require(RoRooms.SourceCode.Client.UI.States)
local Version = require(RoRooms.Version)

local Children = Fusion.Children
local Computed = Fusion.Computed
local Spring = Fusion.Spring
local Observer = Fusion.Observer
local New = Fusion.New

local AutoScaleFrame = require(OnyxUI.Components.AutoScaleFrame)
local MenuFrame = require(OnyxUI.Components.MenuFrame)
local TitleBar = require(OnyxUI.Components.TitleBar)
local SettingToggle = require(OnyxUI.Examples.SettingToggle)
local ScrollingFrame = require(OnyxUI.Components.ScrollingFrame)
local Text = require(OnyxUI.Components.Text)

local TOGGLEABLE_CORE_GUIS = { Enum.CoreGuiType.Chat, Enum.CoreGuiType.PlayerList }

return function(Props)
	local MenuOpen = Computed(function()
		return Use(States.CurrentMenu) == script.Name
	end)

	Observer(States.UserSettings.HideUI):onChange(function()
		for _, CoreGuiType in ipairs(TOGGLEABLE_CORE_GUIS) do
			StarterGui:SetCoreGuiEnabled(CoreGuiType, not Use(States.UserSettings.HideUI))
		end
		States.TopbarVisible:set(not Use(States.UserSettings.HideUI))
		if Use(States.UserSettings.HideUI) then
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
						local YPos = Use(States.TopbarBottomPos)
						if not Use(MenuOpen) then
							YPos = YPos + Theme.Spacing["1"]:get()
						end
						return UDim2.new(UDim.new(0.5, 0), UDim.new(0, YPos))
					end),
					37,
					1
				),
				BaseResolution = Vector2.new(739, 789),
				MinScale = 1,
				MaxScale = 1,
				ListEnabled = true,

				[Children] = {
					MenuFrame {
						Size = UDim2.fromOffset(305, 0),
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
								Title = "Settings",
								CloseButtonDisabled = true,
							},
							ScrollingFrame {
								Size = UDim2.new(UDim.new(1, 0), UDim.new(0, 135)),
								AutomaticSize = Enum.AutomaticSize.None,
								ScrollBarThickness = Theme.StrokeThickness["1"],
								ScrollBarImageColor3 = Theme.Colors.NeutralContent.Dark,
								ListEnabled = true,
								PaddingTop = Computed(function()
									return UDim.new(0, Theme.StrokeThickness["1"]:get())
								end),
								PaddingRight = Computed(function()
									return UDim.new(0, Theme.Spacing["1"]:get())
								end),

								[Children] = {
									SettingToggle {
										Label = "Mute music",
										Switched = States.UserSettings.MuteMusic,
									},
									SettingToggle {
										Label = "Hide UI",
										Switched = States.UserSettings.HideUI,
									},

									Text {
										Text = Computed(function()
											local VersionStamp = `[RoRooms v{Version}]`
											if not Use(States.RoRooms.UpToDate) then
												return `{VersionStamp} - Out of date`
											else
												return VersionStamp
											end
										end),
										TextColor3 = Computed(function()
											if not Use(States.RoRooms.UpToDate) then
												return Use(Theme.Colors.Warning.Main)
											else
												return Use(Theme.Colors.NeutralContent.Dark)
											end
										end),
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
