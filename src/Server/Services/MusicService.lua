local RoRooms = require(script.Parent.Parent.Parent.Parent)
local SoundService = game:GetService("SoundService")

local Shared = RoRooms.Shared
local Packages = RoRooms.Packages

local Knit = require(Packages.Knit)

local MusicService = {
  Name = "MusicService",
  Client = {
    CurrentSong = Knit.CreateProperty(),
  }
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

function MusicService:KnitInit()
  self.CurrentIndex = 0
  self.Songs = RoRooms.Config.MusicSystem.SoundGroup:GetChildren()
  
  for _, Song in ipairs(self.Songs) do
    if not Song:IsA("Sound") then
      Song:Destroy()
    end
    Song.Looped = false
    Song.PlayOnRemove = false
    Song.Playing = false
  end
end

return MusicService