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
		Bio = Knit.CreateProperty(""),
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

function ProfilesService.Client:SetBio(Player: Player, Bio: string)
	assert(t.tuple(t.instanceOf("Player")(Player), t.string(Bio)))
	assert(utf8.len(Bio) <= Config.Systems.Profiles.BioCharacterLimit, "Bio exceeds character limit")

	ProfilesService:SetBio(Player, FilterString(Bio, Player))
end

function ProfilesService:SetRole(Player: Player, RoleId: string): boolean
	if (RoleId == nil) and (Config.Systems.Profiles.DefaultRoleId ~= nil) then
		RoleId = Config.Systems.Profiles.DefaultRoleId
	end

	local RoleToSet = nil
	local Role = Config.Systems.Profiles.Roles[RoleId]
	local Profile = PlayerDataStoreService:GetProfile(Player.UserId)

	if Role ~= nil then
		RoleToSet = RoleId
	end

	if Profile then
		Player:SetAttribute("RR_RoleId", RoleToSet)
		Profile.Data.Profile.Role = RoleToSet
		self.Client.Role:SetFor(Player, RoleToSet)

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

function ProfilesService:SetBio(Player: Player, Bio: string)
	Player:SetAttribute("RR_Bio", Bio)

	local Profile = PlayerDataStoreService:GetProfile(Player.UserId)
	if Profile then
		Profile.Data.Profile.Bio = Bio
		self.Client.Bio:SetFor(Player, Bio)
	end
end

function ProfilesService:_UpdateFromDataStoreProfile(Player: Player)
	if not Player then
		return
	end

	local Profile = PlayerDataStoreService:GetProfile(Player.UserId)
	if Profile then
		self:SetNickname(Player, Profile.Data.Profile.Nickname)
		self:SetBio(Player, Profile.Data.Profile.Bio)
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
