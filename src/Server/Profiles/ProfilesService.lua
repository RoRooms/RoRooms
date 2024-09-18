local RoRooms = script.Parent.Parent.Parent.Parent
local Knit = require(RoRooms.Parent.Knit)
local FilterString = require(RoRooms.SourceCode.Storage.ExtPackages.FilterString)
local PlayerDataStoreService = require(RoRooms.SourceCode.Server.PlayerDataStore.PlayerDataStoreService)
local t = require(RoRooms.Parent.t)
local Config = require(RoRooms.Config).Config

local ProfilesService = {
	Name = "ProfilesService",
	Client = {
		Nickname = Knit.CreateProperty(""),
		Status = Knit.CreateProperty(""),
	},
}

function ProfilesService.Client:SetNickname(Player: Player, Nickname: string)
	assert(t.tuple(t.instanceOf("Player")(Player), t.string(Nickname)))
	assert(utf8.len(Nickname) <= Config.Systems.Profiles.NicknameCharacterLimit, "Nickname exceeds character limit")

	ProfilesService:SetNickname(Player, FilterString(Nickname, Player))
end

function ProfilesService.Client:SetStatus(Player: Player, Status: string)
	assert(t.tuple(t.instanceOf("Player")(Player), t.string(Status)))
	assert(utf8.len(Status) <= Config.Systems.Profiles.BioCharacterLimit, "Status exceeds character limit")

	ProfilesService:SetStatus(Player, FilterString(Status, Player))
end

function ProfilesService:SetNickname(Player: Player, Nickname: string)
	Player:SetAttribute("RR_Nickname", Nickname)

	local Profile = PlayerDataStoreService:GetProfile(Player.UserId)
	if Profile then
		Profile.Data.Profile.Nickname = Nickname
		self.Client.Nickname:SetFor(Player, Nickname)
	end
end

function ProfilesService:SetStatus(Player: Player, Status: string)
	Player:SetAttribute("RR_Status", Status)

	local Profile = PlayerDataStoreService:GetProfile(Player.UserId)
	if Profile then
		Profile.Data.Profile.Status = Status
		self.Client.Status:SetFor(Player, Status)
	end
end

function ProfilesService:_UpdateFromDataStoreProfile(Player: Player)
	print(Player)
	if not Player then
		return
	end

	local Profile = PlayerDataStoreService:GetProfile(Player.UserId)
	if Profile then
		self:SetNickname(Player, Profile.Data.Profile.Nickname)
		self:SetStatus(Player, Profile.Data.Profile.Status)
	end
end

function ProfilesService:KnitStart()
	PlayerDataStoreService.ProfileLoaded:Connect(function(Profile: PlayerDataStoreService.Profile)
		self:_UpdateFromDataStoreProfile(Profile.Player)
	end)
	for _, Profile in pairs(PlayerDataStoreService:GetProfiles()) do
		self:_UpdateFromDataStoreProfile(Profile.Player)
	end
end

return ProfilesService
