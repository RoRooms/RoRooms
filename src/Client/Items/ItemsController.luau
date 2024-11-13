local Players = game:GetService("Players")

local Rorooms = script.Parent.Parent.Parent.Parent
local Knit = require(Rorooms.Parent.Knit)
local Fusion = require(Rorooms.Parent.Fusion)
local Signal = require(Rorooms.Parent.Signal)
local NeoHotbar = require(Rorooms.Parent.NeoHotbar)
local States = require(Rorooms.SourceCode.Client.UI.States)
local Prompts = require(Rorooms.SourceCode.Client.UI.States.Prompts)
local UIController = require(Rorooms.SourceCode.Client.UI.UIController)
local Config = require(Rorooms.Config).Config
local Assets = require(Rorooms.SourceCode.Shared.Assets)

local Peek = Fusion.peek

local ItemsService

local ItemsController = {
	Name = "ItemsController",

	Scope = Fusion.scoped(Fusion),
	EquippedItemsUpdated = Signal.new(),
}

function ItemsController:ToggleEquipItem(ItemId: string, Hold: boolean?)
	ItemsService:ToggleEquipItem(ItemId, Hold):andThen(function(Equipped: boolean, FailureReason: string)
		if not Equipped and FailureReason then
			Prompts:PushPrompt({
				Title = "Failure",
				Text = FailureReason,
				Buttons = {
					{
						Content = { "Close" },
					},
				},
			})
		end
	end)
end

function ItemsController:_UpdateEquippedItems()
	local Backpack = Players.LocalPlayer:FindFirstChild("Backpack")
	local function ScanDirectory(Directory: Instance)
		if not Directory then
			return
		end
		for _, Child in ipairs(Directory:GetChildren()) do
			local ItemId = Child:GetAttribute("RR_ItemId")
			if Child:IsA("Tool") and Config.Systems.Items.Items[ItemId] then
				table.insert(self.EquippedItems, ItemId)
			end
		end
	end
	self.EquippedItems = {}
	ScanDirectory(Players.LocalPlayer.Character)
	ScanDirectory(Backpack)
	self.EquippedItemsUpdated:Fire(self.EquippedItems)
end

function ItemsController:_AddNeoHotbarButton()
	if NeoHotbar:FindCustomButton("ItemsMenuButton") then
		NeoHotbar:RemoveCustomButton("ItemsMenuButton")
	end

	NeoHotbar:AddCustomButton("ItemsMenuButton", Assets.Icons.General.Toolbox, function()
		if not Peek(States.Menus.ItemsMenu.Open) then
			States.Menus.ItemsMenu.Open:set(true)
		else
			States.Menus.ItemsMenu.Open:set(false)
		end
	end)
end

function ItemsController:_HandleCharacter(Character: Model)
	self:_UpdateEquippedItems()

	Character.ChildAdded:Connect(function()
		self:_UpdateEquippedItems()
	end)
	Character.ChildRemoved:Connect(function()
		self:_UpdateEquippedItems()
	end)

	local Backpack = Players.LocalPlayer:WaitForChild("Backpack")
	Backpack.ChildAdded:Connect(function()
		self:_UpdateEquippedItems()
	end)
	Backpack.ChildRemoved:Connect(function()
		self:_UpdateEquippedItems()
	end)
end

function ItemsController:KnitStart()
	ItemsService = Knit.GetService("ItemsService")
	UIController = Knit.GetController("UIController")

	Players.LocalPlayer.CharacterAdded:Connect(function(Character)
		self:_HandleCharacter(Character)
	end)
	local ExistingCharacter = Players.LocalPlayer.Character
	if ExistingCharacter ~= nil then
		self:_HandleCharacter(ExistingCharacter)
	end

	UIController:MountUI(require(Rorooms.SourceCode.Client.UI.ScreenGuis.ItemsMenu))

	self:_AddNeoHotbarButton()
end

ItemsController.EquippedItems = ItemsController.Scope:Value({})

return ItemsController
