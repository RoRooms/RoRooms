local Players = game:GetService("Players")

local RoRooms = script.Parent.Parent.Parent.Parent
local ProfileService = require(RoRooms.SourceCode.Storage.Packages.ProfileService)
local Signal = require(RoRooms.Parent.Signal)
local DataTemplate = require(script.Parent.DataTemplate)

local KICK_MESSAGE = "Data failure. Please rejoin."

export type ProfileData = typeof(DataTemplate)
export type Profile = ProfileService.Profile<ProfileData, { Player: Player }, {}> & {
	Player: Player?,
}

local PlayerDataStoreService = {
	Name = "PlayerDataStoreService",

	ProfileStore = ProfileService.GetProfileStore("RoRoomsPlayerData", DataTemplate),
	ProfileLoaded = Signal.new(),
	Profiles = {},
}

function PlayerDataStoreService:GetProfiles(): { [number]: Profile }
	return self.Profiles
end

function PlayerDataStoreService:GetProfile(UserId: number): Profile?
	return self.Profiles[UserId]
end

function PlayerDataStoreService:_AddPlayer(Player: Player)
	if Player.UserId < 1 then
		return
	end

	local Profile = self.ProfileStore:LoadProfileAsync(tostring(Player.UserId))
	if Profile ~= nil then
		Profile:AddUserId(Player.UserId)
		Profile:Reconcile()
		Profile:ListenToRelease(function()
			self.Profiles[Player] = nil
			Player:Kick(KICK_MESSAGE)
		end)
		Profile.Player = Player

		if Player:IsDescendantOf(Players) then
			self.Profiles[Player] = Profile
			self.ProfileLoaded:Fire(Profile)
		else
			Profile:Release()
			return
		end

		Profile.XPMultipliers = {}

		self.Client.Profile:SetFor(Player, Profile.Data.Profile)
	else
		Player:Kick(KICK_MESSAGE)
	end
end

function PlayerDataStoreService:_RemovePlayer(Player: Player)
	local Profile = self:GetProfile(Player.UserId)
	if Profile ~= nil then
		Profile:Release()
	end
end

function PlayerDataStoreService:KnitStart()
	for _, Player in ipairs(Players:GetPlayers()) do
		task.spawn(function()
			self:_AddPlayer(Player)
		end)
	end
	Players.PlayerAdded:Connect(function(Player)
		self:_AddPlayer(Player)
	end)

	Players.PlayerRemoving:Connect(function(Player)
		self:_RemovePlayer(Player)
	end)
end

return PlayerDataStoreService
