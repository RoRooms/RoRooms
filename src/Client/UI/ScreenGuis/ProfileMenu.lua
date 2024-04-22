local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent)

local Shared = RoRooms.Shared
local Client = RoRooms.Client
local Config = RoRooms.Config

local Fusion = require(Shared.ExtPackages.OnyxUI.Packages.Fusion)
local OnyxUI = require(Shared.ExtPackages.OnyxUI)
local States = require(Client.UI.States)
local SharedData = require(Shared.SharedData)
local AutomaticSizer = require(OnyxUI.Utils.AutomaticSizer)

local Children = Fusion.Children
local New = Fusion.New
local Computed = Fusion.Computed
local Spring = Fusion.Spring
local Value = Fusion.Value
local Observer = Fusion.Observer

local AutoScaleFrame = require(OnyxUI.Components.AutoScaleFrame)
local MenuFrame = require(OnyxUI.Components.MenuFrame)
local TitleBar = require(OnyxUI.Components.TitleBar)
local TextInput = require(OnyxUI.Components.TextInput)
local Button = require(OnyxUI.Components.Button)

return function(Props)
	local MenuOpen = Computed(function()
		return States.CurrentMenu:get() == script.Name
	end)

	local NicknameText = Value("")
	local StatusText = Value("")

	if States.PlayerDataService then
		States.PlayerDataService.UserProfile:Observe(function(UserProfile: { [any]: any })
			NicknameText:set(UserProfile.Nickname)
			StatusText:set(UserProfile.Status)
		end)
	end

	local ProfileMenu = New "ScreenGui" {
		Name = "ProfileMenu",
		Parent = Props.Parent,
		-- ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets,
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
								Title = "Profile",
								CloseButtonDisabled = true,
								TextSize = 24,
							},
							TextInput {
								Name = "NicknameInput",
								PlaceholderText = "Nickname",
								CharacterLimit = SharedData.NicknameCharLimit,
								Size = UDim2.fromScale(1, 0),
								AutomaticSize = Enum.AutomaticSize.Y,
								Text = NicknameText,
								OnFocusLost = function()
									if States.UserProfileService then
										States.UserProfileService:SetNickname(NicknameText:get())
									end
								end,
							},
							TextInput {
								Name = "StatusInput",
								PlaceholderText = "Status",
								CharacterLimit = SharedData.StatusCharLimit,
								TextWrapped = true,
								Size = UDim2.new(UDim.new(1, 0), UDim.new(0, 55)),
								AutomaticSize = Enum.AutomaticSize.None,
								Text = StatusText,
								OnFocusLost = function()
									if States.UserProfileService then
										States.UserProfileService:SetStatus(StatusText:get())
									end
								end,
							},
							Button {
								Name = "EditAvatarButton",
								Contents = { "rbxassetid://13285615740", "Edit Avatar" },
								BackgroundColor3 = Color3.fromRGB(82, 82, 82),
								ContentColor3 = Color3.fromRGB(240, 240, 240),
								Size = UDim2.fromScale(1, 0),
								AutomaticSize = Enum.AutomaticSize.Y,
								OnActivated = function()
									States.CurrentMenu:set()
									Config.ProfilesSystem.AvatarEditorCallback()
								end,
							},
						},
					},
				},
			},
		},
	}

	local DisconnectOpen = Observer(MenuOpen):onChange(function()
		local TextClasses = { "TextLabel", "TextButton", "TextBox" }
		for _, Descendant in ipairs(ProfileMenu:GetDescendants()) do
			if table.find(TextClasses, Descendant.ClassName) then
				task.wait()
				AutomaticSizer.ApplyLayout(Descendant)
			end
		end
	end)

	ProfileMenu:GetPropertyChangedSignal("Parent"):Connect(function()
		if ProfileMenu.Parent == nil then
			DisconnectOpen()
		end
	end)

	return ProfileMenu
end
