local RoRooms = script.Parent.Parent.Parent.Parent
local Fusion = require(RoRooms.Parent.Fusion)
local Loader = require(RoRooms.Parent.Loader)

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
	Profile = {
		Nickname = Scope:Value(""),
		Status = Scope:Value(""),
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
		InRoRooms = Scope:Value({}),
		NotInRoRooms = Scope:Value({}),
	},
	CoreGui = {
		TopbarInset = Scope:Value(Rect.new(Vector2.new(), Vector2.new())),
		RobloxMenuOpen = Scope:Value(false),
		PreferredTransparency = Scope:Value(0.15),
		ScreenSize = Scope:Value(Vector2.new()),
	},
	Worlds = {
		TopWorlds = Scope:Value({}),
		RandomWorlds = Scope:Value({}),
	},
	RoRooms = {
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
