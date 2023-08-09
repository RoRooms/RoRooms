return {
  TimeRewards = {
    XPPerMinute = 30,
    CoinsPerMinute = 5,
  },
  BaseLevelUpXP = 35,
  NicknameCharLimit = 20,
  StatusCharLimit = 25,
  FeatureModulesMap = {
    ProfilesSystem = { "UserProfileService", "UserProfileController" },
    ItemsSystem = { "ItemsService", "ItemsController" },
    EmotesSystem = { "EmotesService", "EmotesController" },
    WorldsSystem = { "WorldsService", "WorldsController" },
    MusicSystem = { "MusicService", "MusicController" },
  },
  ItemEquipResponseCodes = {
    Unpurchased = 1,
    RequirementFailure = 2,
    LevelRequirementFailure = 3
  }
}