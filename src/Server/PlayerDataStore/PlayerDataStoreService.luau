local Players = game:GetService("Players")

local RoRooms = script.Parent.Parent.Parent.Parent
local ProfileService = require(RoRooms.SourceCode.Storage.Packages.ProfileService)
local Signal = require(RoRooms.Parent.Signal)
local DataTemplate = require(script.Parent.DataTemplate)
local DeepCopy = require(RoRooms.SourceCode.Shared.ExtPackages.DeepCopy)
local DeepEquals = require(RoRooms.SourceCode.Shared.ExtPackages.DeepEquals)

local KICK_MESSAGE = "Data failure. Please rejoin."

export type ProfileData = typeof(DataTemplate)
export type Profile = ProfileService.Profile<ProfileData, { Player: Player }, {}> & {
	Player: Player?,
}

local PlayerDataStoreService = {
	Name = "PlayerDataStoreService",

	ProfileStore = ProfileService.GetProfileStore("RoRoomsPlayerData", DataTemplate),
	ProfileLoaded = Signal.new(),
	DataUpdated = Signal.new(),
	Profiles = {},
}

function PlayerDataStoreService:UpdateData(Player: Player, Callback: (ProfileData) -> ProfileData)
	local Profile = self:GetProfile(Player.UserId)
	if Profile then
		local OldData = Profile.Data
		local NewData = Callback(DeepCopy(OldData))

		if (NewData ~= nil) and (not DeepEquals(OldData, NewData)) then
			Profile.Data = NewData

			self.DataUpdated:Fire(Player, OldData, NewData)
			return true
		end
	end

	return false
end

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
			self.Profiles[Player.UserId] = nil
			Player:Kick(KICK_MESSAGE)
		end)
		Profile.Player = Player

		if Player:IsDescendantOf(Players) then
			self.Profiles[Player.UserId] = Profile
			self.ProfileLoaded:Fire(Profile)
		else
			Profile:Release()
			return
		end
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
