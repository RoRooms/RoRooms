return {
	TimeRewards = {
		XPPerMinute = 30,
	},
	BaseLevelUpXP = 35,
	NicknameCharLimit = 20,
	StatusCharLimit = 25,
	FeatureModulesMap = {
		ProfilesSystem = { "UserProfileService", "UserProfileController" },
		ItemsSystem = { "ItemsService", "ItemsController" },
		EmotesSystem = { "EmotesService", "EmotesController" },
		WorldsSystem = { "WorldsService", "WorldRegistryService", "TopWorldsService", "WorldsController" },
		MusicSystem = { "MusicService", "MusicController" },
		SettingsSystem = { "SettingsController" },
		FriendsSystem = { "FriendsController" },
		VRSystem = { "NexusVRService" },
	},
	ItemEquipResponseCodes = {
		RequirementFailure = 1,
		LevelRequirementFailure = 2,
	},
	WorldRegistryAssetId = 16007140043,
}
