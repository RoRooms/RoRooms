local SoundService = game:GetService("SoundService")

local Rorooms = script.Parent.Parent.Parent.Parent
local Knit = require(Rorooms.Parent.Knit)
local States = require(Rorooms.SourceCode.Client.UI.States)
local Fusion = require(Rorooms.Parent.Fusion)
local Config = require(Rorooms.Config).Config

local Peek = Fusion.peek

local MusicService

local MusicController = {
	Name = "MusicController",

	Scope = Fusion.scoped(Fusion),
	Muted = false,
}

function MusicController:SetMuted(Muted: boolean)
	self.Muted = Muted
	self.SoundGroup.Volume = (Muted and 0) or 1
end

function MusicController:StopAllSongs()
	for _, Song in ipairs(self.SoundGroup:GetChildren()) do
		Song:Stop()
	end
end

function MusicController:KnitStart()
	MusicService = Knit.GetService("MusicService")

	self.Scope:Observer(States.UserSettings.MuteMusic):onChange(function()
		self:SetMuted(Peek(States.UserSettings.MuteMusic))
	end)

	self.SoundGroup = Config.Systems.Music.SoundGroup
	self.SoundGroup.Parent = SoundService

	MusicService.CurrentSong:Observe(function(CurrentSong)
		if not CurrentSong then
			return
		end
		self:StopAllSongs()
		self.CurrentSong = CurrentSong
		CurrentSong.Parent = self.SoundGroup
		CurrentSong.SoundGroup = self.SoundGroup
		CurrentSong:Play()
	end)
end

return MusicController
