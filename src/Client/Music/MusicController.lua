local SoundService = game:GetService("SoundService")

local RoRooms = require(script.Parent.Parent.Parent.Parent)
local Knit = require(RoRooms.Packages.Knit)
local States = require(RoRooms.Client.UI.States)
local OnyxUI = require(RoRooms.Packages.OnyxUI)
local Fusion = require(RoRooms.Packages.Fusion)

local Peek = Fusion.peek

local MusicService

local MusicController = {
	Name = "MusicController",
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

	Scope:Observer(States.UserSettings.MuteMusic):onChange(function()
		self:SetMuted(Peek(States.UserSettings.MuteMusic))
	end)

	self.SoundGroup = RoRooms.Config.Systems.Music.SoundGroup
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

function MusicController:KnitInit()
	self.Muted = false
end

return MusicController
