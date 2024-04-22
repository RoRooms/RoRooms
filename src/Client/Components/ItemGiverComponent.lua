local RoRooms = require(script.Parent.Parent.Parent.Parent)
local Players = game:GetService("Players")

local Shared = RoRooms.Shared
local Client = RoRooms.Client
local Config = RoRooms.Config
local Packages = RoRooms.Packages

local Component = require(Packages.Component)
local Fusion = require(Shared.ExtPackages.OnyxUI.Packages.Fusion)
local States = require(Client.UI.States)
local ItemsController = require(Client.Items.ItemsController)
local AttributeValue = require(Shared.ExtPackages.AttributeValue)

local New = Fusion.New
local Computed = Fusion.Computed
local Hydrate = Fusion.Hydrate

local ItemGiver = Component.new {
	Tag = "RR_ItemGiver",
}

function ItemGiver:GiveItem(Player: Player)
	if Player == Players.LocalPlayer then
		if self.Item:get() then
			ItemsController:ToggleEquipItem(self.ItemId:get())
		end
	end
end

function ItemGiver:GetProximityPrompt()
	local ProximityPrompt = self.Instance:FindFirstChild("RR_ItemPrompt")
	if not ProximityPrompt then
		ProximityPrompt = New "ProximityPrompt" {
			Name = "RR_ItemPrompt",
			Parent = self.Instance,
			ActionText = "",
			RequiresLineOfSight = false,
			MaxActivationDistance = 7.5,
		}
	end

	Hydrate(ProximityPrompt) {
		Enabled = Computed(function()
			return self.Item:get() ~= nil
		end),
		ActionText = Computed(function()
			if self.Equipped:get() then
				return "Unequip"
			else
				return "Equip"
			end
		end),
		ObjectText = Computed(function()
			if self.Item:get() then
				return self.Item:get().Name
			else
				return "Item"
			end
		end),
	}

	return ProximityPrompt
end

function ItemGiver:Start()
	self.ProximityPrompt = self:GetProximityPrompt()

	self.ProximityPrompt.Triggered:Connect(function(Player: Player)
		self:GiveItem(Player)
	end)
end

function ItemGiver:Construct()
	self.ItemId = AttributeValue(self.Instance, "RR_ItemId")
	self.Item = Computed(function()
		return Config.ItemsSystem.Items[self.ItemId:get()]
	end)
	self.Equipped = Computed(function()
		return table.find(States.EquippedItems:get(), self.ItemId:get()) ~= nil
	end)

	if not self.ItemId:get() then
		warn("No RR_ItemId attribute defined for ItemGiver", self.Instance)
	end
	if not ItemGiver.Item:get() then
		warn("Could not find item from ItemId", self.ItemId:get(), self.Instance)
	end
end

function ItemGiver:Stop()
	self.DisconnectLevelMetObserver()
end

return ItemGiver
