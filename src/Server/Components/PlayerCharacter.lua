local Players = game:GetService("Players")
local RoRooms = require(script.Parent.Parent.Parent.Parent)

local Packages = RoRooms.Packages

local Component = require(Packages.Component)
local RemoteComponent = require(Packages.RemoteComponent)
local Knit = require(Packages.Knit)

local PlayerCharacter = Component.new {
	Tag = "RR_PlayerCharacter",
	Extensions = { RemoteComponent },
}
PlayerCharacter.RemoteNamespace = PlayerCharacter.Tag
PlayerCharacter.Client = {
	PlayEmote = Knit.CreateSignal(),
}

function PlayerCharacter:PlayEmote(EmoteId: string, Emote: { [any]: any })
	if self.Player then
		self.Client.PlayEmote:Fire(self.Player, EmoteId, Emote)

		if Emote.PlayedCallback then
			Emote.PlayedCallback(self.Player, EmoteId, Emote)
		end
	end
end

function PlayerCharacter:Start() end

function PlayerCharacter:Construct()
	self.Player = Players:GetPlayerFromCharacter(self.Instance)
	self.Humanoid = self.Instance:WaitForChild("Humanoid")
end

return PlayerCharacter
