local RoRooms = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(RoRooms.Parent.OnyxUI)
local Fusion = require(RoRooms.Parent.Fusion)
local States = require(RoRooms.SourceCode.Client.UI.States)
local Config = require(RoRooms.Config).Config
local Components = require(RoRooms.SourceCode.Client.UI.Components)
local Assets = require(RoRooms.SourceCode.Shared.Assets)

local Children = Fusion.Children
local Themer = OnyxUI.Themer
local Peek = Fusion.peek

return function(Scope: Fusion.Scope<any>, Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components, Components)
	local Theme = Themer.Theme:now()

	local MenuOpen = Scope:Computed(function(Use)
		return Use(States.Menus.CurrentMenu) == script.Name
	end)

	local NicknameText = Scope:Value("")
	local StatusText = Scope:Value("")

	Scope:Observer(States.Profile.Nickname):onChange(function()
		NicknameText:set(Peek(States.Profile.Nickname))
	end)
	Scope:Observer(States.Profile.Status):onChange(function()
		StatusText:set(Peek(States.Profile.Status))
	end)

	local ProfileMenu = Scope:Menu {
		Name = script.Name,
		Open = MenuOpen,
		Parent = Props.Parent,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.fromOffset(280, 0),
		ListHorizontalFlex = Enum.UIFlexAlignment.Fill,

		[Children] = {
			Scope:Frame {
				ListEnabled = true,
				ListHorizontalFlex = Enum.UIFlexAlignment.Fill,

				[Children] = {
					Scope:TextInput {
						Name = "NicknameInput",
						PlaceholderText = "Nickname",
						CharacterLimit = Config.Systems.Profiles.NicknameCharacterLimit,
						AutomaticSize = Enum.AutomaticSize.Y,
						Text = NicknameText,

						OnFocusLost = function()
							States.Profile.Nickname:set(Peek(NicknameText))
						end,
					},
					Scope:TextInput {
						Name = "StatusInput",
						PlaceholderText = "Status",
						Text = StatusText,
						CharacterLimit = Config.Systems.Profiles.BioCharacterLimit,
						TextWrapped = true,
						Size = UDim2.new(UDim.new(0, 0), UDim.new(0, 60)),
						AutomaticSize = Enum.AutomaticSize.Y,

						OnFocusLost = function()
							States.Profile.Status:set(Peek(StatusText))
						end,
					},
				},
			},
			Scope:Button {
				Name = "EditAvatarButton",
				Content = { Assets.Icons.General.EditPerson, "Edit Avatar" },
				Color = Theme.Colors.Primary.Main,
				AutomaticSize = Enum.AutomaticSize.Y,
				Visible = Scope:Computed(function(Use)
					return Config.Systems.Profiles.AvatarEditorCallback ~= nil
				end),

				OnActivated = function()
					States.Menus.CurrentMenu:set()

					if Config.Systems.Profiles.AvatarEditorCallback then
						Config.Systems.Profiles.AvatarEditorCallback()
					end
				end,
			},
		},
	}

	return ProfileMenu
end
