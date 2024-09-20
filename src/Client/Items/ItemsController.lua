local RoRooms = script.Parent.Parent.Parent.Parent
local Knit = require(RoRooms.Parent.Knit)
local Fusion = require(RoRooms.Parent.Fusion)
local Signal = require(RoRooms.Parent.Signal)
local NeoHotbar = require(RoRooms.Parent.NeoHotbar)
local States = require(RoRooms.SourceCode.Client.UI.States)
local Prompts = require(RoRooms.SourceCode.Client.UI.States.Prompts)
local UIController = require(RoRooms.SourceCode.Client.UI.UIController)
local Config = require(RoRooms.Config).Config
local Assets = require(RoRooms.SourceCode.Shared.Assets)

local Peek = Fusion.peek

local ItemsService

local ItemsController = {
	Name = "ItemsController",

	Scope = Fusion.scoped(Fusion),
	EquippedItemsUpdated = Signal.new(),
}

function ItemsController:ToggleEquipItem(ItemId: string)
	ItemsService:ToggleEquipItem(ItemId):andThen(function(Equipped: boolean, FailureReason: string)
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

function ItemsController:UpdateEquippedItems()
	local Char = Knit.Player.Character
	local Backpack = Knit.Player:FindFirstChild("Backpack")
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
	ScanDirectory(Char)
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

function ItemsController:KnitStart()
	ItemsService = Knit.GetService("ItemsService")
	UIController = Knit.GetController("UIController")

	Knit.Player.CharacterAdded:Connect(function(Char)
		self:UpdateEquippedItems()

		Char.ChildAdded:Connect(function()
			self:UpdateEquippedItems()
		end)
		Char.ChildRemoved:Connect(function()
			self:UpdateEquippedItems()
		end)

		local Backpack = Knit.Player:WaitForChild("Backpack")
		Backpack.ChildAdded:Connect(function()
			self:UpdateEquippedItems()
		end)
		Backpack.ChildRemoved:Connect(function()
			self:UpdateEquippedItems()
		end)
	end)

	UIController:MountUI(require(RoRooms.SourceCode.Client.UI.ScreenGuis.ItemsMenu))

	self:_AddNeoHotbarButton()
end

ItemsController.EquippedItems = ItemsController.Scope:Value({})

return ItemsController
