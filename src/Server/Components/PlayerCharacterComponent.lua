local Players = game:GetService("Players")

local RoRooms = require(script.Parent.Parent.Parent.Parent)
local Component = require(RoRooms.Packages.Component)
local RemoteComponent = require(RoRooms.Packages.RemoteComponent)
local Knit = require(RoRooms.Packages.Knit)

local PlayerCharacterComponent = Component.new {
	Tag = "RR_PlayerCharacter",
	Extensions = { RemoteComponent },
}
PlayerCharacterComponent.RemoteNamespace = PlayerCharacterComponent.Tag
PlayerCharacterComponent.Client = {
	PlayEmote = Knit.CreateSignal(),
}

function PlayerCharacterComponent:PlayEmote(EmoteId: string, Emote: { [any]: any })
	if self.Player then
		self.Client.PlayEmote:Fire(self.Player, EmoteId, Emote)

		if Emote.PlayedCallback then
			Emote.PlayedCallback(self.Player, EmoteId, Emote)
		end
	end
end

function PlayerCharacterComponent:Start() end

function PlayerCharacterComponent:Construct()
	self.Player = Players:GetPlayerFromCharacter(self.Instance)
	self.Humanoid = self.Instance:WaitForChild("Humanoid")
end

return PlayerCharacterComponent
