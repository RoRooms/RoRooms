local RoRooms = script.Parent.Parent.Parent.Parent
local Knit = require(RoRooms.Parent.Knit)
local OnyxUI = require(RoRooms.Parent.OnyxUI)
local Fusion = require(RoRooms.Parent.Fusion)
local Signal = require(RoRooms.Parent.Signal)
local NeoHotbar = require(RoRooms.Parent.NeoHotbar)
local States = require(RoRooms.SourceCode.Client.UI.States)
local Prompts = require(RoRooms.SourceCode.Client.UI.States.Prompts)
local UIController = require(RoRooms.SourceCode.Client.UI.UIController)

local Peek = Fusion.peek

local ItemsMenu = require(RoRooms.SourceCode.Client.UI.ScreenGuis.ItemsMenu)

local ItemsService

local ItemsController = {
	Name = "ItemsController",
}

function ItemsController:ToggleEquipItem(ItemId: string)
	ItemsService:ToggleEquipItem(ItemId):andThen(function(Equipped: boolean, FailureReason: string)
		if not Equipped and FailureReason then
			Prompts:PushPrompt({
				Title = "Failure",
				Text = FailureReason,
				Buttons = {
					{
						Contents = { "Close" },
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
			if Child:IsA("Tool") and RoRooms.Config.Systems.Items.Items[ItemId] then
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

	NeoHotbar:AddCustomButton("ItemsMenuButton", "rbxassetid://6966623635", function()
		if not Peek(States.ItemsMenu.Open) then
			States.ItemsMenu.Open:set(true)
		else
			States.ItemsMenu.Open:set(false)
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

	UIController:MountUI(ItemsMenu {})

	self:_AddNeoHotbarButton()
end

function ItemsController:KnitInit()
	self.EquippedItems = Fusion.Value({})
	self.EquippedItemsUpdated = Signal.new()
end

return ItemsController
