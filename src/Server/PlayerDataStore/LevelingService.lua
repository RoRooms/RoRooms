local Players = game:GetService("Players")
local RoRooms = script.Parent.Parent.Parent.Parent
local PlayerDataStoreService = require(script.Parent.PlayerDataStoreService)
local XPToLevelUp = require(RoRooms.SourceCode.Shared.XPToLevelUp)
local Knit = require(RoRooms.Parent.Knit)
local DataTemplate = require(RoRooms.SourceCode.Server.PlayerDataStore.DataTemplate)
local Config = require(RoRooms.Config).Config
local SessionStore = require(RoRooms.SourceCode.Shared.ExtPackages.SessionStore)

local LevelingService = {
	Name = script.Name,
	Client = {
		Level = Knit.CreateProperty(DataTemplate.Level),
		XPMultipliers = Knit.CreateProperty({}),
	},
}

function LevelingService:_SetLevel(Player: Player, Level: number)
	local Profile = PlayerDataStoreService:GetProfile(Player.UserId)
	if Profile then
		Profile.Data.Level = Level

		Player:SetAttribute("RR_Level", Level)
		self.Client.Level:SetFor(Player, Level)
	end
end

function LevelingService:ChangeXP(Player: Player, Amount: number): (boolean, number?)
	Amount = math.floor(Amount)

	local Profile = PlayerDataStoreService:GetProfile(Player.UserId)
	if Profile then
		local MaxAllowedXP = (
			XPToLevelUp(Profile.Data.Level)
			+ XPToLevelUp(Profile.Data.Level + 1)
			+ XPToLevelUp(Profile.Data.Level + 2)
		)

		if Amount > MaxAllowedXP then
			return false, MaxAllowedXP
		end

		local RequiredXPToLevel = XPToLevelUp(Profile.Data.Level)
		if (Profile.Data.XP + Amount) > RequiredXPToLevel then
			local RemainingXP = (Profile.Data.XP + Amount) - RequiredXPToLevel
			Profile.Data.Level += 1
			Profile.Data.XP = 0
			self:ChangeXP(Player, RemainingXP)
		elseif (Profile.Data.XP + Amount) == RequiredXPToLevel then
			Profile.Data.Level += 1
			Profile.Data.XP = 0
		else
			Profile.Data.XP += Amount
		end

		self:_SetLevel(Player, Profile.Data.Level)

		return true
	end

	return false
end

function LevelingService:SetXPMultiplier(Player: Player, Name: string, MultiplierAddon: number | nil)
	local Profile = PlayerDataStoreService:GetProfile(Player.UserId)
	local SessionProfile = SessionStore:GetProfileSafe(Player)
	if Profile then
		SessionProfile.Data.XPMultipliers[Name] = MultiplierAddon
		self.Client.XPMultipliers:SetFor(Player, SessionProfile.XPMultipliers)
	end
end

function LevelingService:_UpdateAllFriendMultipliers()
	for _, Player in ipairs(Players:GetPlayers()) do
		task.spawn(function()
			local FriendsInGame = false
			for _, OtherPlayer in ipairs(Players:GetPlayers()) do
				if OtherPlayer ~= Player and OtherPlayer:IsFriendsWith(Player.UserId) then
					FriendsInGame = true
					break
				end
			end
			local BaseMultiplier = 0.5
			self:SetXPMultiplier(Player, "Friends", (FriendsInGame and BaseMultiplier) or 0)
		end)
	end
end

function LevelingService:KnitStart()
	PlayerDataStoreService.ProfileLoaded:Connect(function(Profile: PlayerDataStoreService.Profile)
		self:_UpdateAllFriendMultipliers()

		self:_SetLevel(Profile.Player, Profile.Data.Level)
	end)

	task.spawn(function()
		while task.wait(1) do
			for _, Profile in pairs(PlayerDataStoreService:GetProfiles()) do
				local function CalculateTotal(BaseNum: number, MultiplierAddons: { [any]: any })
					local Total = BaseNum
					local TotalMultiplier = 1
					for _, MultiplierAddon in pairs(MultiplierAddons) do
						TotalMultiplier += MultiplierAddon
					end
					Total *= TotalMultiplier
					return Total
				end

				local SessionProfile = SessionStore:GetProfileSafe(Profile.Player)
				local XPTotal = CalculateTotal(Config.Systems.Leveling.XPPerMinute, SessionProfile.Data.XPMultipliers)
				self:ChangeXP(Profile.Player, XPTotal)
			end
		end
	end)
end

return LevelingService
