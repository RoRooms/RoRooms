local Players = game:GetService("Players")

local RoRooms = script.Parent.Parent.Parent.Parent
local Knit = require(RoRooms.Parent.Knit)
local ProfileService = require(RoRooms.SourceCode.Storage.Packages.ProfileService)
local LeaderStats = require(RoRooms.SourceCode.Storage.ExtPackages.LeaderStats)
local XPToLevelUp = require(RoRooms.SourceCode.Shared.XPToLevelUp)
local Trove = require(RoRooms.Parent.Trove)
local Signal = require(RoRooms.Parent.Signal)
local Config = require(RoRooms.Config).Config
local DataTemplate = require(script.Parent.DataTemplate)

local KICK_MESSAGE = "Data failure. Please rejoin."
local LEADERBOARD_LABELS = {
	Level = "Level ⇵",
}

local PlayerDataService = {
	Name = "PlayerDataService",
	Client = {
		XPMultipliers = Knit.CreateProperty({}),
		Level = Knit.CreateProperty(0),
		UserProfile = Knit.CreateProperty({ Nickname = "", Status = "" }),
	},

	ProfileLoaded = Signal.new(),
	Profiles = {},
}

function PlayerDataService:ChangeProfile(Player: Player, ProfileChanges: { [any]: any })
	local Profile = self:GetProfile(Player)
	if Profile then
		for ChangeKey, ChangeValue in pairs(ProfileChanges) do
			local TemplateValue = DataTemplate.UserProfile[ChangeKey]
			if TemplateValue and typeof(ChangeValue) == typeof(TemplateValue) then
				Profile.Data.UserProfile[ChangeKey] = ChangeValue
			end
		end
	end
	self.Client.UserProfile:SetFor(Player, Profile.Data.UserProfile)
end

function PlayerDataService:_UpdateAllFriendMultipliers()
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

function PlayerDataService:GetProfile(Player: Player)
	return self.Profiles[Player]
end

function PlayerDataService:_AddPlayer(Player: Player)
	if Player.UserId < 1 then
		return
	end

	local Profile = self.ProfileStore:LoadProfileAsync(tostring(Player.UserId))
	if Profile ~= nil then
		Profile:AddUserId(Player.UserId)
		Profile:Reconcile()
		Profile:ListenToRelease(function()
			if Profile.Processes ~= nil then
				Profile.Processes:Destroy()
			end
			self.Profiles[Player] = nil
			Player:Kick(KICK_MESSAGE)
		end)
		if Player:IsDescendantOf(Players) then
			self.Profiles[Player] = Profile
			self.ProfileLoaded:Fire(Player, Profile)
		else
			Profile:Release()
			return
		end

		Profile.XPMultipliers = {}

		self.Client.XPMultipliers:SetFor(Player, Profile.XPMultipliers)
		self.Client.Level:SetFor(Player, Profile.Data.Level)
		self.Client.UserProfile:SetFor(Player, Profile.Data.UserProfile)

		local PlayerLeaderStats = LeaderStats.New(Player)
		PlayerLeaderStats:SetStat(LEADERBOARD_LABELS.Level, Profile.Data.Level)

		Profile.Processes = Trove.new()
		Profile.Processes:Add(task.spawn(function()
			while task.wait(1 * 60) do
				local function CalculateTotal(BaseNum: number, MultiplierAddons: { [any]: any })
					local Total = BaseNum
					local TotalMultiplier = 1
					for _, MultiplierAddon in pairs(MultiplierAddons) do
						TotalMultiplier += MultiplierAddon
					end
					Total *= TotalMultiplier
					return Total
				end
				local XPTotal = CalculateTotal(Config.Systems.Leveling.XPPerMinute, Profile.XPMultipliers)
				self:ChangeXP(Player, XPTotal)
			end
		end))

		self:_UpdateAllFriendMultipliers()
	else
		Player:Kick(KICK_MESSAGE)
	end
end

function PlayerDataService:_RemovePlayer(Player: Player)
	local Profile = self:GetProfile(Player)
	if Profile ~= nil then
		Profile:Release()
		self:_UpdateAllFriendMultipliers()
	end
end

function PlayerDataService:KnitStart()
	self.ProfileStore = ProfileService.GetProfileStore("RoRoomsPlayerData", DataTemplate)

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

return PlayerDataService
