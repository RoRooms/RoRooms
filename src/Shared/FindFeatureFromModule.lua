local FEATURE_MODULES_MAP = {
	Profiles = { "UserProfileService", "UserProfileController" },
	Items = { "ItemsService", "ItemsController" },
	Emotes = { "EmotesService", "EmotesController" },
	Worlds = {
		"WorldsService",
		"WorldRegistryService",
		"TopWorldsService",
		"RandomWorldsService",
		"WorldsController",
	},
	Music = { "MusicService", "MusicController" },
	Settings = { "SettingsController" },
	Friends = { "FriendsController" },
	VR = { "NexusVRService" },
}

return function(Module)
	for Feature, ModuleNames in pairs(FEATURE_MODULES_MAP) do
		if table.find(ModuleNames, Module.Name) then
			return Feature
		end
	end

	return nil
end
