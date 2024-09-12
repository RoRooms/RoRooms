local RoRooms = script.Parent.Parent.Parent.Parent
local Knit = require(RoRooms.Packages.Knit)
local FilterString = require(RoRooms.Storage.ExtPackages.FilterString)
local PlayerDataService = require(RoRooms.Server.PlayerData.PlayerDataService)
local t = require(RoRooms.Packages.t)

local UserProfileService = {
	Name = "UserProfileService",
	Client = {},
}

function UserProfileService.Client:SetNickname(Player: Player, Nickname: string)
	assert(t.tuple(t.instanceOf("Player")(Player), t.string(Nickname)))
	assert(
		utf8.len(Nickname) <= RoRooms.Config.Systems.Profiles.NicknameCharacterLimit,
		"Nickname exceeds character limit"
	)

	self.Server:SetPlayerNickname(Player, FilterString(Nickname, Player))
end

function UserProfileService.Client:SetStatus(Player: Player, Status: string)
	assert(t.tuple(t.instanceOf("Player")(Player), t.string(Status)))
	assert(utf8.len(Status) <= RoRooms.Config.Systems.Profiles.BioCharacterLimit, "Status exceeds character limit")

	self.Server:SetPlayerStatus(Player, FilterString(Status, Player))
end

function UserProfileService:SetPlayerNickname(Player: Player, Nickname: string)
	Player:SetAttribute("RR_Nickname", Nickname)
	PlayerDataService:ChangeProfile(Player, {
		Nickname = Nickname,
	})
end

function UserProfileService:SetPlayerStatus(Player: Player, Status: string)
	Player:SetAttribute("RR_Status", Status)
	PlayerDataService:ChangeProfile(Player, {
		Status = Status,
	})
end

function UserProfileService:LoadProfileFromData(Player: Player, Profile: { [any]: any })
	self:SetPlayerNickname(Player, Profile.Data.UserProfile.Nickname)
	self:SetPlayerStatus(Player, Profile.Data.UserProfile.Status)
end

function UserProfileService:KnitStart()
	PlayerDataService = Knit.GetService("PlayerDataService")

	PlayerDataService.ProfileLoaded:Connect(function(Player: Player, Profile: { [any]: any })
		self:LoadProfileFromData(Player, Profile)
	end)
	for Player, Profile in pairs(PlayerDataService.Profiles) do
		self:LoadProfileFromData(Player, Profile)
	end
end

return UserProfileService
