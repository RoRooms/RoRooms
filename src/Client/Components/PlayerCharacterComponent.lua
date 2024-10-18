local Players = game:GetService("Players")

local RoRooms = script.Parent.Parent.Parent.Parent
local Component = require(RoRooms.Parent.Component)
local RemoteComponent = require(RoRooms.Parent.RemoteComponent)
local Nametagger = require(RoRooms.SourceCode.Shared.ExtPackages.Nametagger)
local OnyxUI = require(RoRooms.Parent.OnyxUI)
local Fusion = require(RoRooms.Parent.Fusion)
local Assets = require(RoRooms.SourceCode.Shared.Assets)

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
	Extensions = { RemoteComponent },
}
PlayerCharacterComponent.RemoteNamespace = PlayerCharacterComponent.Tag

function PlayerCharacterComponent:_PlayEmote(EmoteId: string, Emote: { [any]: any })
	if self.Player ~= Players.LocalPlayer then
		return
	end
	if not self.Humanoid then
		return
	end

	local HumanoidDescription = self.Humanoid.HumanoidDescription
	if not HumanoidDescription:GetEmotes()[EmoteId] then
		HumanoidDescription:AddEmote(EmoteId, string.gsub(Emote.Animation.AnimationId, "%D+", ""))
	end
	self.Humanoid:PlayEmote(EmoteId)
end

function PlayerCharacterComponent:_UpdateNametag()
	if self.Humanoid then
		self.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	end

	OnyxUI.Themer.Theme:is(NAMETAGGER_THEME):during(function()
		local DisplayName = self.Player:GetAttribute("RR_Nickname") or ""
		if string.len(DisplayName) == 0 then
			DisplayName = self.Player.DisplayName
		end

		Nametagger:TagCharacter(self.Instance, {
			DisplayName = DisplayName,
			Properties = {
				{ Value = self.Player:GetAttribute("RR_Level"), Image = Assets.Icons.UserBadges.Level },
			},
		})
	end)
end

function PlayerCharacterComponent:_StartNametag()
	self.Player:GetAttributeChangedSignal("RR_Nickname"):Connect(function()
		self:_UpdateNametag()
	end)
	self.Player:GetAttributeChangedSignal("RR_Level"):Connect(function()
		self:_UpdateNametag()
	end)

	self:_UpdateNametag()
end

function PlayerCharacterComponent:Start()
	self.Server.PlayEmote:Connect(function(EmoteId: string, Emote: { [any]: any })
		self:_PlayEmote(EmoteId, Emote)
	end)

	self:_StartNametag()
end

function PlayerCharacterComponent:Construct()
	self.Player = Players:GetPlayerFromCharacter(self.Instance)
	self.Humanoid = self.Instance:WaitForChild("Humanoid")
end

return PlayerCharacterComponent
