local RoRooms = script.Parent.Parent.Parent.Parent
local OnyxUI = require(RoRooms.Parent.OnyxUI)
local Fusion = require(RoRooms.Parent.Fusion)
local Loader = require(RoRooms.Parent.Loader)

local States = {
	Services = {
		UserProfileService = nil,
		WorldsService = nil,
		ItemsService = nil,
		PlayerDataService = nil,
		EmotesService = nil,
		TopWorldsService = nil,
		RandomWorldsService = nil,
		UpdatesService = nil,
	},
	Controllers = {
		UIController = nil,
		EmotesController = nil,
		ItemsController = nil,
		FriendsController = nil,
	},
	Prompts = Scope:Value({}),
	CurrentMenu = Scope:Value(),
	TopbarBottomPos = Scope:Value(0),
	TopbarVisible = Scope:Value(true),
	TopbarButtons = Scope:Value({}),
	ScreenSize = Scope:Value(Vector2.new()),
	EquippedItems = Scope:Value({}),
	ItemsMenu = {
		Open = Scope:Value(false),
		FocusedCategory = Scope:Value(nil),
	},
	EmotesMenu = {
		FocusedCategory = Scope:Value(nil),
	},
	WorldPageMenu = {
		PlaceId = Scope:Value(),
	},
	ItemsMenuOpen = Scope:Value(false),
	LocalPlayerData = Scope:Value({}),
	UserSettings = {
		MuteMusic = Scope:Value(false),
		HideUI = Scope:Value(false),
	},
	Friends = {
		Online = Scope:Value({}),
		InRoRooms = Scope:Value({}),
		NotInRoRooms = Scope:Value({}),
	},
	TopbarInset = Scope:Value(Rect.new(Vector2.new(), Vector2.new())),
	RobloxMenuOpen = Scope:Value(false),
	PreferredTransparency = Scope:Value(0.25),
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
