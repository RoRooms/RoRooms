local Rorooms = script.Parent.Parent.Parent.Parent
local Fusion = require(Rorooms.Parent.Fusion)
local Loader = require(Rorooms.Parent.Loader)

local function UnloadedService(): { [any]: any }
	return {}
end

local Scope = Fusion.scoped(Fusion)

local States = {
	Services = {
		ProfilesService = UnloadedService(),
		WorldsService = UnloadedService(),
		ItemsService = UnloadedService(),
		EmotesService = UnloadedService(),
		TopWorldsService = UnloadedService(),
		RandomWorldsService = UnloadedService(),
		UpdatesService = UnloadedService(),
		LevelingService = UnloadedService(),
		WorldRegistryService = UnloadedService(),
	},
	Controllers = {
		UIController = nil,
		EmotesController = nil,
		ItemsController = nil,
		FriendsController = nil,
	},
	Prompts = Scope:Value({}),
	Menus = {
		CurrentMenu = Scope:Value(),
		ItemsMenu = {
			Open = Scope:Value(false),
			FocusedCategory = Scope:Value(nil),
		},
		EmotesMenu = {
			FocusedCategory = Scope:Value(nil),
		},
		ProfileMenu = {
			UserId = Scope:Value(nil),
			EditMode = Scope:Value(false),
			Location = {
				Online = Scope:Value(false),
				InRorooms = Scope:Value(false),
				PlaceId = Scope:Value(nil),
				JobId = Scope:Value(nil),
			},
		},
	},
	Topbar = {
		YPosition = Scope:Value(0),
		Visible = Scope:Value(true),
		Buttons = Scope:Value({}),
	},
	Items = {
		Equipped = Scope:Value({}),
	},
	Profiles = {
		Loaded = Scope:Value({}),
	},
	WorldPageMenu = {
		PlaceId = Scope:Value(),
	},
	Leveling = {
		Level = Scope:Value(0),
	},
	UserSettings = {
		MuteMusic = Scope:Value(false),
		HideUI = Scope:Value(false),
	},
	Friends = {
		Online = Scope:Value({}),
		InRorooms = Scope:Value({}),
		NotInRorooms = Scope:Value({}),
	},
	CoreGui = {
		TopbarInset = Scope:Value(Rect.new(Vector2.new(), Vector2.new())),
		RobloxMenuOpen = Scope:Value(false),
		PreferredTransparency = Scope:Value(0.15),
		ScreenSize = Scope:Value(Vector2.new()),
	},
	Worlds = {
		AssortedWorlds = Scope:Value({}),
		TopWorlds = Scope:Value({}),
		RandomWorlds = Scope:Value({}),
		Registered = Scope:Value(false),
	},
	Rorooms = {
		UpToDate = Scope:Value(),
	},
}

function States:_StartExtensions()
	Loader.SpawnAll(Loader.LoadChildren(script), "Start")
end

function States:_InitializeExtensions()
	Loader.LoadChildren(script)
end

function States:Start()
	self:_InitializeExtensions()
	self:_StartExtensions()
end

return States
