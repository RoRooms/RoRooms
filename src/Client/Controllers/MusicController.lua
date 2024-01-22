local RoRooms = require(script.Parent.Parent.Parent.Parent)

local Client = RoRooms.Client
local Packages = RoRooms.Packages

local SoundService = game:GetService("SoundService")

local Knit = require(Packages.Knit)
local States = require(Client.UI.States)
local Fusion = require(Packages.Fusion)

local MusicService

local Observer = Fusion.Observer

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

	Observer(States.UserSettings.MuteMusic):onChange(function()
		self:SetMuted(States.UserSettings.MuteMusic:get())
	end)

	self.SoundGroup = RoRooms.Config.MusicSystem.SoundGroup
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
