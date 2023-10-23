local RoRooms = require(game:GetService("ReplicatedStorage").RoRooms)

local Shared = RoRooms.Shared
local Client = RoRooms.Client

local SoundService = game:GetService("SoundService")

local Knit = require(Shared.Packages.Knit)
local States = require(Client.UI.States)
local Fusion = require(Shared.Packages.Fusion)

local MusicService

local Observer = Fusion.Observer

local MusicController = {
  Name = "MusicController"
}

function MusicController:SetMuted(Muted: boolean)
  self.Muted = Muted
  self.SoundGroup.Volume = (Muted and 0) or 1
  if Muted then
    States.TopbarIcons.Music:setImage(6413981913)
  else
    States.TopbarIcons.Music:setImage(7059338404)
  end
end

function MusicController:StopAllSongs()
  for _, Song in ipairs(self.SoundGroup:GetChildren()) do
    Song:Stop()
  end
end

function MusicController:KnitStart()
  MusicService = Knit.GetService("MusicService")
  
  States.TopbarIcons.Music:setEnabled(true)
  States.TopbarIcons.Music.selected:Connect(function()
    self:SetMuted(true)
  end)
  States.TopbarIcons.Music.deselected:Connect(function()
    self:SetMuted(false)
  end)

  Observer(States.UserSettings.MuteMusic):onChange(function()
    self:SetMuted(States.UserSettings.MuteMusic:get())
  end)

  self.SoundGroup = RoRooms.Config.MusicSystem.SoundGroup
  self.SoundGroup.Parent = SoundService

  MusicService.CurrentSong:Observe(function(CurrentSong)
    if not CurrentSong then return end
    self:StopAllSongs()
    self.CurrentSong = CurrentSong
    CurrentSong.Parent = self.SoundGroup
    CurrentSong.SoundGroup = self.SoundGroup
    CurrentSong:Play()
    States.TopbarIcons.Music:setTip("🎵 "..CurrentSong.Name)
  end)
end

function MusicController:KnitInit()
  self.Muted = false
end

return MusicController