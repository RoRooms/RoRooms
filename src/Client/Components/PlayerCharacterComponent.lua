local Players = game:GetService("Players")
local RoRooms = require(script.Parent.Parent.Parent.Parent)

local Packages = RoRooms.Packages

local Component = require(Packages.Component)
local RemoteComponent = require(Packages.RemoteComponent)

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

function PlayerCharacterComponent:Start()
	self.Server.PlayEmote:Connect(function(EmoteId: string, Emote: { [any]: any })
		self:_PlayEmote(EmoteId, Emote)
	end)
end

function PlayerCharacterComponent:Construct()
	self.Player = Players:GetPlayerFromCharacter(self.Instance)
	self.Humanoid = self.Instance:WaitForChild("Humanoid")
end

return PlayerCharacterComponent
