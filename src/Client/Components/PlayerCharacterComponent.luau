local Players = game:GetService("Players")

local Rorooms = script.Parent.Parent.Parent.Parent
local Component = require(Rorooms.Parent.Component)
local RemoteComponent = require(Rorooms.Parent.RemoteComponent)
local Nametagger = require(Rorooms.SourceCode.Shared.ExtPackages.Nametagger)
local OnyxUI = require(Rorooms.Parent.OnyxUI)
local Fusion = require(Rorooms.Parent.Fusion)
local Assets = require(Rorooms.SourceCode.Shared.Assets)
local Profiles = require(Rorooms.SourceCode.Client.UI.States.Profiles)
local Config = require(Rorooms.Config).Config
local AnimatedComponent = require(Rorooms.SourceCode.Shared.ExtPackages.AnimatedComponent)

local NAMETAGGER_THEME = Fusion.scoped(OnyxUI.Themer):NewTheme({
	Font = {
		Body = "rbxasset://fonts/families/Montserrat.json",
	},
	FontWeight = {
		Body = Enum.FontWeight.SemiBold,
		Bold = Enum.FontWeight.Bold,
	},
	TextSize = {
		Base = 20,
	},
})

local PlayerCharacterComponent = Component.new {
	Tag = "RR_PlayerCharacter",
	Extensions = { RemoteComponent, AnimatedComponent },

	PlayingEmote = nil,
}
PlayerCharacterComponent.RemoteNamespace = PlayerCharacterComponent.Tag

function PlayerCharacterComponent:ToggleEmote(EmoteId: string)
	local Emote = Config.Systems.Emotes.Emotes[EmoteId]
	local PlayingEmote = self.PlayingEmote

	if Emote then
		if Emote == PlayingEmote then
			self:StopEmote()
		else
			self:PlayEmote(EmoteId)
		end
	end
end

function PlayerCharacterComponent:PlayEmote(EmoteId: string)
	if self.Player ~= Players.LocalPlayer then
		return
	end
	if not self.Humanoid then
		return
	end
	if self.Humanoid.SeatPart ~= nil then
		return
	end

	local Emote = Config.Systems.Emotes.Emotes[EmoteId]
	if Emote then
		local Animator: Animator? = self.Humanoid:FindFirstChildOfClass("Animator")

		if Animator ~= nil then
			self:StopEmote()
			self.PlayingEmote = Emote

			self:PlayAnimation(Emote.Animation.AnimationId)
		end
	end
end

function PlayerCharacterComponent:StopEmote()
	local PlayingEmote = self.PlayingEmote
	if PlayingEmote then
		self:StopAnimation(PlayingEmote.Animation.AnimationId)
		self.PlayingEmote = nil
	end
end

function PlayerCharacterComponent:_UpdateNametag()
	local SafeProfileValue = Fusion.peek(self.SafeProfile)

	if self.Humanoid then
		self.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	end

	OnyxUI.Themer.Theme:is(NAMETAGGER_THEME):during(function()
		local ShownName = SafeProfileValue.Nickname
		local Properties = {
			{ Value = SafeProfileValue.Level, Image = Assets.Icons.UserBadges.Level },
		}

		if string.len(SafeProfileValue.Nickname or "") > 0 then
			ShownName = SafeProfileValue.Nickname
		else
			ShownName = SafeProfileValue.DisplayName
		end

		if utf8.len(SafeProfileValue.Bio or "") > 0 then
			table.insert(Properties, { Value = "", Image = Assets.Icons.General.EditPerson })
		end

		local Role = Config.Systems.Profiles.Roles[SafeProfileValue.Role]

		Nametagger:TagCharacter(self.Instance, {
			DisplayName = ShownName,
			Color = (Role and Role.Color) or OnyxUI.Util.Colors.White,
			Properties = Properties,
		})
	end)
end

function PlayerCharacterComponent:_StartNametag()
	self.Scope:Observer(self.SafeProfile):onChange(function()
		self:_UpdateNametag()
	end)

	self:_UpdateNametag()
end

function PlayerCharacterComponent:Start()
	if self.Server then
		self.Server.PlayEmote:Connect(function(EmoteId: string)
			self:ToggleEmote(EmoteId)
		end)
	end

	self:_StartNametag()

	local Animator: Animator? = self.Humanoid:FindFirstChildOfClass("Animator")
	if Animator then
		self:SetAnimator(Animator)
	end

	self.Humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
		local PlayingEmote: Config.Emote? = self.PlayingEmote
		if (PlayingEmote ~= nil) and not PlayingEmote.AllowMovement then
			if self.Humanoid.MoveDirection.Magnitude > 0 then
				self:StopEmote()
			end
		end
	end)

	self.Humanoid.Jumping:Connect(function(IsJumping: boolean)
		local PlayingEmote: Config.Emote? = self.PlayingEmote
		if (PlayingEmote ~= nil) and not PlayingEmote.AllowMovement then
			if IsJumping then
				self:StopEmote()
			end
		end
	end)
end

function PlayerCharacterComponent:Construct()
	self.Scope = Fusion.scoped(Fusion)
	self.Player = Players:GetPlayerFromCharacter(self.Instance)
	self.Humanoid = self.Instance:WaitForChild("Humanoid")

	if self.Player then
		self.Profile = Profiles.ProfileValue(self.Scope, self.Player.UserId)
		self.SafeProfile = Profiles.SafeProfileValue(self.Scope, self.Profile)
	end
end

return PlayerCharacterComponent
