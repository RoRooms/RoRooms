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
		Role = Knit.CreateProperty(),
	},
}

function ProfilesService.Client:SetRole(Player: Player, RoleId: string): boolean
	assert(t.tuple(t.instanceOf("Player")(Player), t.string(RoleId)))

	return ProfilesService:SetRole(Player, RoleId)
end

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

function ProfilesService:SetRole(Player: Player, RoleId: string): boolean
	if (RoleId == nil) and (Config.Systems.Profiles.DefaultRoleId ~= nil) then
		RoleId = Config.Systems.Profiles.DefaultRoleId
	end

	local Role = Config.Systems.Profiles.Roles[RoleId]
	local Profile = PlayerDataStoreService:GetProfile(Player.UserId)

	if Role and Profile then
		Player:SetAttribute("RR_RoleId", RoleId)
		Profile.Data.Profile.Role = RoleId
		self.Client.Role:SetFor(Player, RoleId)

		return true
	end

	return false
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
	if not Player then
		return
	end

	local Profile = PlayerDataStoreService:GetProfile(Player.UserId)
	if Profile then
		self:SetNickname(Player, Profile.Data.Profile.Nickname)
		self:SetStatus(Player, Profile.Data.Profile.Status)
		self:SetRole(Player, Profile.Data.Profile.Role)
	end
end

function ProfilesService:_CheckDefaultRole()
	local DefaultRoleId = Config.Systems.Profiles.DefaultRoleId
	local DefaultRole = Config.Systems.Profiles.Roles[DefaultRoleId]

	if (DefaultRoleId ~= nil) and (DefaultRole == nil) then
		assert(false, "DefaultRoleId is set to a nonexistent role.")
	else
		assert(DefaultRole.CallbackRequirement == nil, "The default role cannot have a CallbackRequirement.")
	end
end

function ProfilesService:KnitStart()
	PlayerDataStoreService.ProfileLoaded:Connect(function(Profile: PlayerDataStoreService.Profile)
		self:_UpdateFromDataStoreProfile(Profile.Player)
	end)
	for _, Profile in pairs(PlayerDataStoreService:GetProfiles()) do
		self:_UpdateFromDataStoreProfile(Profile.Player)
	end

	self:_CheckDefaultRole()
end

return ProfilesService
