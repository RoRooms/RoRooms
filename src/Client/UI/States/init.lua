local RoRooms = require(script.Parent.Parent.Parent.Parent)
local OnyxUI = require(RoRooms.Packages.OnyxUI)
local Fusion = require(OnyxUI.Packages.Fusion)
local Loader = require(RoRooms.Packages.Loader)

local Value = Fusion.Value

local States = {
	Services = {
		UserProfileService = nil,
		WorldsService = nil,
		ItemsService = nil,
		PlayerDataService = nil,
		EmotesService = nil,
		TopWorldsService = nil,
		RandomWorldsService = nil,
	},
	Controllers = {
		UIController = nil,
		EmotesController = nil,
		ItemsController = nil,
		FriendsController = nil,
	},
	Prompts = Value({}),
	CurrentMenu = Value(),
	TopbarBottomPos = Value(0),
	TopbarVisible = Value(true),
	TopbarButtons = Value({}),
	ScreenSize = Value(Vector2.new()),
	EquippedItems = Value({}),
	ItemsMenu = {
		Open = Value(false),
		FocusedCategory = Value(nil),
	},
	EmotesMenu = {
		FocusedCategory = Value(nil),
	},
	WorldPageMenu = {
		PlaceId = Value(),
	},
	ItemsMenuOpen = Value(false),
	LocalPlayerData = Value({}),
	UserSettings = {
		MuteMusic = Value(false),
		HideUI = Value(false),
	},
	Friends = {
		Online = Value({}),
		InRoRooms = Value({}),
		NotInRoRooms = Value({}),
	},
	TopbarInset = Value(Rect.new(Vector2.new(), Vector2.new())),
	RobloxMenuOpen = Value(false),
	PreferredTransparency = Value(0.25),
	Worlds = {
		TopWorlds = Value({}),
		RandomWorlds = Value({}),
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
