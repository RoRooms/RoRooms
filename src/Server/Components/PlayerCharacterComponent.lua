local Players = game:GetService("Players")

local RoRooms = script.Parent.Parent.Parent.Parent
local Component = require(RoRooms.Parent.Component)
local RemoteComponent = require(RoRooms.Parent.RemoteComponent)
local Knit = require(RoRooms.Parent.Knit)
local Config = require(RoRooms.Config).Config

local PlayerCharacterComponent = Component.new {
	Tag = "RR_PlayerCharacter",
	Extensions = { RemoteComponent },
}
PlayerCharacterComponent.RemoteNamespace = PlayerCharacterComponent.Tag
PlayerCharacterComponent.Client = {
	PlayEmote = Knit.CreateSignal(),
}

function PlayerCharacterComponent:PlayEmote(EmoteId: string)
	local Emote = Config.Systems.Emotes.Emotes[EmoteId]
	if Emote then
		if self.Player then
			self.Client.PlayEmote:Fire(self.Player, EmoteId)

			if Emote.PlayedCallback then
				Emote.PlayedCallback(self.Player, EmoteId)
			end
		end
	end
end

function PlayerCharacterComponent:Start() end

function PlayerCharacterComponent:Construct()
	self.Player = Players:GetPlayerFromCharacter(self.Instance)
	self.Humanoid = self.Instance:WaitForChild("Humanoid")
end

return PlayerCharacterComponent
