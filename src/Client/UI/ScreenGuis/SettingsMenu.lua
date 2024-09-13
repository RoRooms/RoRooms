local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")

local RoRooms = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(RoRooms.Parent.OnyxUI)
local Fusion = require(RoRooms.Parent.Fusion)
local States = require(RoRooms.SourceCode.Client.UI.States)
local Version = require(RoRooms.Version)
local Components = require(RoRooms.SourceCode.Client.UI.Components)

local Children = Fusion.Children
local Util = OnyxUI.Util
local Themer = OnyxUI.Themer
local Peek = Fusion.peek

local TOGGLEABLE_CORE_GUIS = { Enum.CoreGuiType.Chat, Enum.CoreGuiType.PlayerList }

return function(Scope: Fusion.Scope<any>, Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components, Components)
	local Theme = Themer.Theme:now()

	local MenuOpen = Scope:Computed(function(Use)
		return Use(States.CurrentMenu) == script.Name
	end)

	Scope:Observer(States.UserSettings.HideUI):onChange(function()
		for _, CoreGuiType in ipairs(TOGGLEABLE_CORE_GUIS) do
			StarterGui:SetCoreGuiEnabled(CoreGuiType, not Peek(States.UserSettings.HideUI))
		end
		States.TopbarVisible:set(not Peek(States.UserSettings.HideUI))
		if Peek(States.UserSettings.HideUI) then
			States.CurrentMenu:set(nil)
		end
	end)
	if Players.LocalPlayer then
		Players.LocalPlayer.CharacterAdded:Connect(function()
			States.UserSettings.HideUI:set(false)
		end)
	end

	local SettingsMenu = Scope:Menu {
		Name = script.Name,
		Parent = Props.Parent,
		Size = UDim2.fromOffset(305, 0),
		Open = MenuOpen,

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
					Scope:SettingToggle {
						Label = "Mute music",
						Switched = States.UserSettings.MuteMusic,
					},
					Scope:SettingToggle {
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
	}

	return SettingsMenu
end
