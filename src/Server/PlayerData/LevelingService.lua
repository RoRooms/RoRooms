local PlayerDataStoreService = require(script.Parent.PlayerDataStoreService)
local XPToLevelUp = require()

local LevelingService = {
	Name = script.Name,
}

function LevelingService:ChangeXP(Player: Player, Amount: number)
	Amount = math.floor(Amount)
	local Profile = self:GetProfile(Player)
	if Profile then
		local MaxAllowedXP = (
			XPToLevelUp(Profile.Data.Level)
			+ XPToLevelUp(Profile.Data.Level + 1)
			+ XPToLevelUp(Profile.Data.Level + 2)
		)
		if Amount > MaxAllowedXP then
			return MaxAllowedXP
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

		self.Client.Level:SetFor(Player, Profile.Data.Level)

		local PlayerLeaderStats = LeaderStats:Get(Player)
		if PlayerLeaderStats then
			PlayerLeaderStats:SetStat(LEADERBOARD_LABELS.Level, Profile.Data.Level)
		end
	end

	return nil
end

function LevelingService:SetXPMultiplier(Player: Player, Name: string, MultiplierAddon: number | nil)
	local Profile = self:GetProfile(Player)
	if Profile then
		Profile.XPMultipliers[Name] = MultiplierAddon
		self.Client.XPMultipliers:SetFor(Player, Profile.XPMultipliers)
	end
end

return LevelingService
