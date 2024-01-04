local RoRooms = require(script.Parent.Parent.Parent.Parent)

local Shared = RoRooms.Shared
local Storage = RoRooms.Storage
local Config = RoRooms.Config
local Packages = RoRooms.Packages

local Players = game:GetService("Players")

local Knit = require(Packages.Knit)
local ProfileService = require(Storage.ExtPackages.ProfileService)
local LeaderStats = require(Storage.ExtPackages.LeaderStats)
local XPToLevelUp = require(Shared.SharedData.XPToLevelUp)
local Trove = require(Packages.Trove)
local SharedData = require(Shared.SharedData)
local Signal = require(Packages.Signal)

local PROFILE_TEMPLATE = {
  Level = 1,
  XP = 0,
  Coins = 0,
  MinutesSpent = 0,
  UserProfile = {
    Nickname = "",
    Status = "",
  },
  PurchasedItems = {}
}
local KICK_MESSAGE = "Data failure. Please rejoin."
local LEADERBOARD_LABELS = {
  Level = "Level"
}

local PlayerDataService = {
  Name = "PlayerDataService",
  Client = {
    XPMultipliers = Knit.CreateProperty({}),
    Level = Knit.CreateProperty(0),
    Coins = Knit.CreateProperty(0),
    UserProfile = Knit.CreateProperty({ Nickname = "", Status = "" }),
  }
}

function PlayerDataService:PurchaseItem(Player: Player, ItemId: string)
  local Profile = self:GetProfile(Player)
  if Profile then
    local Item = Config.ItemsSystem.Items[ItemId]
    if Item and Item.PriceInCoins then
      if Profile.Data.Coins >= Item.PriceInCoins and table.find(Profile.Data.PurchasedItems, ItemId) == nil then
        self:ChangeCoins(Player, -Item.PriceInCoins)
        table.insert(Profile.Data.PurchasedItems, ItemId)
        return true
      end
    end
  end
end

function PlayerDataService:ChangeProfile(Player: Player, ProfileChanges: table)
  local Profile = self:GetProfile(Player)
  if Profile then
    for ChangeKey, ChangeValue in pairs(ProfileChanges) do
      local TemplateValue = PROFILE_TEMPLATE.UserProfile[ChangeKey]
      if TemplateValue and typeof(ChangeValue) == typeof(TemplateValue) then
        Profile.Data.UserProfile[ChangeKey] = ChangeValue
      end
    end
  end
  self.Client.UserProfile:SetFor(Player, Profile.Data.UserProfile)
end

function PlayerDataService:ChangeCoins(Player: Player, Amount: number)
  local Profile = self:GetProfile(Player)
  if Profile then
    Profile.Data.Coins += math.floor(Amount)
    self.Client.Coins:SetFor(Player, Profile.Data.Coins)
  end
end

function PlayerDataService:ChangeXP(Player: Player, Amount: number)
  Amount = math.floor(Amount)
  local Profile = self:GetProfile(Player)
  if Profile then
    local MaxAllowedXP = (XPToLevelUp(Profile.Data.Level) + XPToLevelUp(Profile.Data.Level+1) + XPToLevelUp(Profile.Data.Level+2))
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
end

function PlayerDataService:SetCoinMultiplier(Player: Player, Name: string, MultiplierAddon: number|nil)
  local Profile = self:GetProfile(Player)
  if Profile then
    Profile.CoinMultipliers[Name] = MultiplierAddon
  end
end

function PlayerDataService:SetXPMultiplier(Player: Player, Name: string, MultiplierAddon: number|nil)
  local Profile = self:GetProfile(Player)
  if Profile then
    Profile.XPMultipliers[Name] = MultiplierAddon
    self.Client.XPMultipliers:SetFor(Player, Profile.XPMultipliers)
  end
end

function PlayerDataService:_UpdateAllFriendMultipliers()
  if not Config.ProgressionSystem.FriendsXPMultiplier.Enabled then return end
  for _, Player in ipairs(Players:GetPlayers()) do
    task.spawn(function()
      local FriendsInGame = false
      for _, OtherPlayer in ipairs(Players:GetPlayers()) do
        if OtherPlayer ~= Player and OtherPlayer:IsFriendsWith(Player.UserId) then
          FriendsInGame = true
          break
        end
      end
      local BaseMultiplier = Config.ProgressionSystem.FriendsXPMultiplier.MultiplierAddon
      self:SetXPMultiplier(Player, "Friends", (FriendsInGame and BaseMultiplier) or 0)
    end)
  end
end

function PlayerDataService:GetProfile(Player: Player)
  return self.Profiles[Player]
end

function PlayerDataService:_PlayerAdded(Player: Player)
  if Player.UserId < 1 then return end

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
    Profile.CoinMultipliers = {}

    self.Client.XPMultipliers:SetFor(Player, Profile.XPMultipliers)
    self.Client.Coins:SetFor(Player, Profile.Data.Coins)
    self.Client.Level:SetFor(Player, Profile.Data.Level)
    self.Client.UserProfile:SetFor(Player, Profile.Data.UserProfile)

    local PlayerLeaderStats = LeaderStats.New(Player)
    PlayerLeaderStats:SetStat(LEADERBOARD_LABELS.Level, Profile.Data.Level)

    Profile.Processes = Trove.new()
    Profile.Processes:Add(task.spawn(function()
      while task.wait(1 * 60) do
        local function CalculateTotal(BaseNum: number, MultiplierAddons: table)
          local Total = BaseNum
          local TotalMultiplier = 1
          for _, MultiplierAddon in pairs(MultiplierAddons) do
            TotalMultiplier += MultiplierAddon
          end
          Total *= TotalMultiplier
          return Total
        end
        local XPTotal = CalculateTotal(SharedData.TimeRewards.XPPerMinute, Profile.XPMultipliers)
        local CoinsTotal = CalculateTotal(SharedData.TimeRewards.CoinsPerMinute, Profile.CoinMultipliers)
        self:ChangeXP(Player, XPTotal)
        self:ChangeCoins(Player, CoinsTotal)
      end
    end))

    self:_UpdateAllFriendMultipliers()
  else
    Player:Kick(KICK_MESSAGE)
  end
end

function PlayerDataService:_PlayerRemoving(Player: Player)
  local Profile = self:GetProfile(Player)
  if Profile ~= nil then
    Profile:Release()
    self:_UpdateAllFriendMultipliers()
  end
end

function PlayerDataService:KnitStart()
  self.ProfileStore = ProfileService.GetProfileStore("RoRoomsPlayerData", PROFILE_TEMPLATE)

  for _, Player in ipairs(Players:GetPlayers()) do
    task.spawn(function()
      self:_PlayerAdded(Player)
    end)
  end
  Players.PlayerAdded:Connect(function(Player)
    self:_PlayerAdded(Player)
  end)
  Players.PlayerRemoving:Connect(function(Player)
    self:_PlayerRemoving(Player)
  end)
end

function PlayerDataService:KnitInit()
  self.Profiles = {}
  self.ProfileLoaded = Signal.new()
end

return PlayerDataService