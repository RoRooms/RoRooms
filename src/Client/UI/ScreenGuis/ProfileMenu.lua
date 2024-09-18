local RoRooms = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(RoRooms.Parent.OnyxUI)
local Fusion = require(RoRooms.Parent.Fusion)
local States = require(RoRooms.SourceCode.Client.UI.States)
local Config = require(RoRooms.Config).Config
local Components = require(RoRooms.SourceCode.Client.UI.Components)

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

	if States.Services.PlayerDataStoreService then
		States.Services.PlayerDataStoreService.Profile:Observe(function(Profile: { [any]: any })
			NicknameText:set(Profile.Nickname)
			StatusText:set(Profile.Status)
		end)
	end

	local ProfileMenu = Scope:Menu {
		Name = script.Name,
		Open = MenuOpen,
		Parent = Props.Parent,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.fromOffset(280, 0),
		ListHorizontalFlex = Enum.UIFlexAlignment.Fill,

		[Children] = {
			Scope:TitleBar {
				Title = "Profile",
				CloseButtonDisabled = true,
			},
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
							if States.Services.ProfilesService then
								States.Services.ProfilesService:SetNickname(Peek(NicknameText))
							end
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
							if States.Services.ProfilesService then
								States.Services.ProfilesService:SetStatus(Peek(StatusText))
							end
						end,
					},
				},
			},
			Scope:Button {
				Name = "EditAvatarButton",
				Content = { "rbxassetid://13285615740", "Edit Avatar" },
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
