local SoundService = game:GetService("SoundService")

local RoRooms = script.Parent.Parent.Parent.Parent
local Knit = require(RoRooms.Parent.Knit)
local Config = require(RoRooms.Config)

local MusicService = {
	Name = "MusicService",
	Client = {
		CurrentSong = Knit.CreateProperty(),
	},

	CurrentIndex = 0,
	Songs = Config.Systems.Music.SoundGroup:GetChildren(),
}

function MusicService:PlayNextSong()
	if self.CurrentEndConnection then
		self.CurrentEndConnection:Disconnect()
		self.CurrentEndConnection = nil
	end
	if self.SongCopy then
		self.SongCopy:Destroy()
	end
	self.Client.CurrentSong:Set(nil)

	self.CurrentIndex += 1
	if not self.Songs[self.CurrentIndex] then
		self.CurrentIndex = 1
	end

	self.CurrentSong = self.Songs[self.CurrentIndex]
	if self.CurrentSong then
		self.Client.CurrentSong:Set(self.CurrentSong)
		self.SongCopy = self.CurrentSong:Clone()
		self.SongCopy.Parent = SoundService
		self.SongCopy.Volume = 0
		self.SongCopy:Play()
		self.CurrentEndConnection = self.SongCopy.Ended:Connect(function()
			self:PlayNextSong()
		end)
	end
end

function MusicService:KnitStart()
	self:PlayNextSong()
end

for _, Song in ipairs(MusicService.Songs) do
	if not Song:IsA("Sound") then
		Song:Destroy()
	end
	Song.Looped = false
	Song.PlayOnRemove = false
	Song.Playing = false
end

return MusicService
