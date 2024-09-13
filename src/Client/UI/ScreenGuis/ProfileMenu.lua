local RoRooms = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(RoRooms.Parent.OnyxUI)
local Fusion = require(RoRooms.Parent.Fusion)
local States = require(RoRooms.SourceCode.Client.UI.States)
local Config = require(RoRooms.Config)
local Components = require(RoRooms.SourceCode.Client.UI.Components)

local Children = Fusion.Children
local Util = OnyxUI.Util
local Themer = OnyxUI.Themer
local Peek = Fusion.peek

return function(Scope: Fusion.Scope<any>, Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components, Components)
	local Theme = Themer.Theme:now()

	local MenuOpen = Scope:Computed(function(Use)
		return Use(States.CurrentMenu) == script.Name
	end)

	local NicknameText = Scope:Value("")
	local StatusText = Scope:Value("")

	if States.Services.PlayerDataService then
		States.Services.PlayerDataService.UserProfile:Observe(function(UserProfile: { [any]: any })
			NicknameText:set(UserProfile.Nickname)
			StatusText:set(UserProfile.Status)
		end)
	end

	local ProfileMenu = Scope:Menu {
		Name = script.Name,
		Open = MenuOpen,
		Parent = Props.Parent,
		AutomaticSize = Enum.AutomaticSize.Y,
		Size = UDim2.fromOffset(280, 0),

		[Children] = {
			Scope:TitleBar {
				Title = "Profile",
				CloseButtonDisabled = true,
			},
			Scope:Frame {
				Size = UDim2.fromScale(1, 0),
				ListEnabled = true,

				[Children] = {
					Scope:TextInput {
						Name = "NicknameInput",
						PlaceholderText = "Nickname",
						CharacterLimit = Config.Systems.Profiles.NicknameCharacterLimit,
						Size = UDim2.fromScale(1, 0),
						AutomaticSize = Enum.AutomaticSize.Y,
						Text = NicknameText,

						OnFocusLost = function()
							if States.Services.UserProfileService then
								States.Services.UserProfileService:SetNickname(Peek(NicknameText))
							end
						end,
					},
					Scope:TextInput {
						Name = "StatusInput",
						PlaceholderText = "Status",
						Text = StatusText,
						CharacterLimit = Config.Systems.Profiles.BioCharacterLimit,
						TextWrapped = true,
						Size = UDim2.new(UDim.new(1, 0), UDim.new(0, 60)),
						AutomaticSize = Enum.AutomaticSize.Y,

						OnFocusLost = function()
							if States.Services.UserProfileService then
								States.Services.UserProfileService:SetStatus(Peek(StatusText))
							end
						end,
					},
				},
			},
			Scope:Button {
				Name = "EditAvatarButton",
				Content = { "rbxassetid://13285615740", "Edit Avatar" },
				Color = Theme.Colors.Primary.Main,
				Size = UDim2.fromScale(1, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				Visible = Scope:Computed(function(Use)
					return Config.Systems.Profiles.AvatarEditorCallback ~= nil
				end),

				OnActivated = function()
					States.CurrentMenu:set()

					if Config.Systems.Profiles.AvatarEditorCallback then
						Config.Systems.Profiles.AvatarEditorCallback()
					end
				end,
			},
		},
	}

	return ProfileMenu
end
