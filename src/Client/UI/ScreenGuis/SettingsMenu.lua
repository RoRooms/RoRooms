local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")

local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent)
local OnyxUI = require(RoRooms.Packages.OnyxUI)
local Fusion = require(RoRooms.Packages.Fusion)
local States = require(RoRooms.SourceCode.Client.UI.States)
local Version = require(RoRooms.Version)

local Children = Fusion.Children

local TOGGLEABLE_CORE_GUIS = { Enum.CoreGuiType.Chat, Enum.CoreGuiType.PlayerList }

return function(Scope: Fusion.Scope<any>, Props)
	local MenuOpen = Scope:Computed(function(Use)
		return Use(States.CurrentMenu) == script.Name
	end)

	Scope:Observer(States.UserSettings.HideUI):onChange(function()
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

	local SettingsMenu = Scope:New "ScreenGui" {
		Name = "SettingsMenu",
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
							YPos = YPos + Use(Theme.Spacing["1"])
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
					Scope:MenuFrame {
						Size = UDim2.fromOffset(305, 0),
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
								Title = "Settings",
								CloseButtonDisabled = true,
							},
							Scope:Scroller {
								Size = UDim2.new(UDim.new(1, 0), UDim.new(0, 135)),
								AutomaticSize = Enum.AutomaticSize.None,
								ScrollBarThickness = Theme.StrokeThickness["1"],
								ScrollBarImageColor3 = Theme.Colors.NeutralContent.Dark,
								ListEnabled = true,
								PaddingTop = Scope:Computed(function(Use)
									return UDim.new(0, Use(Theme.StrokeThickness["1"]))
								end),
								PaddingRight = Scope:Computed(function(Use)
									return UDim.new(0, Use(Theme.Spacing["1"]))
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

									Scope:Text {
										Text = Scope:Computed(function(Use)
											local VersionStamp = `[RoRooms v{Version}]`
											if not Use(States.RoRooms.UpToDate) then
												return `{VersionStamp} - Out of date`
											else
												return VersionStamp
											end
										end),
										TextColor3 = Scope:Computed(function(Use)
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
