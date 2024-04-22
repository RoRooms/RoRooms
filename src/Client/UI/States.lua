local GuiService = game:GetService("GuiService")
local RoRooms = require(script.Parent.Parent.Parent.Parent)

local Shared = RoRooms.Shared
local Packages = RoRooms.Packages

local Knit = require(Packages.Knit)
local Fusion = require(Shared.ExtPackages.OnyxUI.Packages.Fusion)
local ReconcileTable = require(Shared.ExtPackages.ReconcileTable)

local Hydrate = Fusion.Hydrate
local Out = Fusion.Out
local Value = Fusion.Value
local Computed = Fusion.Computed
local Observer = Fusion.Observer

local CONTROLLERS = { "UIController", "EmotesController", "ItemsController", "FriendsController" }
local SERVICES = { "UserProfileService", "WorldsService", "ItemsService", "PlayerDataService", "EmotesService" }

local States = {
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
		PlaceId = Value(8310127828),
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
}

function States:AddTopbarButton(Name: string, Button: table)
	local TopbarButtons = States.TopbarButtons:get()

	TopbarButtons[Name] = Button

	States.TopbarButtons:set(TopbarButtons)
end

function States:RemoveTopbarButton(Name: string)
	local TopbarButtons = States.TopbarButtons:get()

	TopbarButtons[Name] = nil

	States.TopbarButtons:set(TopbarButtons)
end

function States:PushPrompt(Prompt: table)
	local PromptTemplate = {
		Title = "",
		Text = "",
		Buttons = {
			{
				Primary = true,
				Content = { "Confirm" },
				Callback = function() end,
			},
			{
				Primary = false,
				Content = { "Cancel" },
				Callback = function() end,
			},
		},
	}
	local NewPrompts = States.Prompts:get()
	ReconcileTable(Prompt, PromptTemplate)
	for _, ExistingPrompt in ipairs(NewPrompts) do
		if ExistingPrompt.Text == Prompt.Text then
			return
		end
	end
	table.insert(NewPrompts, Prompt)
	States.Prompts:set(NewPrompts)
end

function States:Start()
	for _, ControllerName in ipairs(CONTROLLERS) do
		self[ControllerName] = Knit.GetController(ControllerName)
	end
	for _, ServiceName in ipairs(SERVICES) do
		task.spawn(function()
			self[ServiceName] = Knit.GetService(ServiceName)
		end)
	end

	Hydrate(workspace.CurrentCamera) {
		[Out "ViewportSize"] = States.ScreenSize,
	}

	States.TopbarInset:set(GuiService.TopbarInset)
	GuiService:GetPropertyChangedSignal("TopbarInset"):Connect(function()
		States.TopbarInset:set(GuiService.TopbarInset)
	end)
	self.IsUnibarOpen = Computed(function()
		return States.TopbarInset:get().Min.X > 250
	end)

	GuiService:GetPropertyChangedSignal("MenuIsOpen"):Connect(function()
		States.RobloxMenuOpen:set(GuiService.MenuIsOpen)
	end)

	Observer(States.IsUnibarOpen):onChange(function()
		States.TopbarVisible:set(not States.IsUnibarOpen:get())
		if States.IsUnibarOpen:get() then
			States.CurrentMenu:set(nil)
		end
	end)
	Observer(States.RobloxMenuOpen):onChange(function()
		States.TopbarVisible:set(not States.RobloxMenuOpen:get())
		if States.RobloxMenuOpen:get() then
			States.CurrentMenu:set(nil)
			States.ItemsMenu.Open:set(false)
		end
	end)

	Knit.OnStart():andThen(function()
		States.ItemsController.EquippedItemsUpdated:Connect(function(EquippedItems)
			States.EquippedItems:set(EquippedItems)
		end)

		States.PlayerDataService.Level:Observe(function(Level)
			local LocalPlayerData = States.LocalPlayerData:get()
			LocalPlayerData.Level = Level
			States.LocalPlayerData:set(LocalPlayerData)
		end)
	end)
end

return States
