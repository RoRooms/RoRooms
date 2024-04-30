local RoRooms = require(script.Parent.Parent.Parent.Parent)
local Players = game:GetService("Players")

local Shared = RoRooms.Shared
local Client = RoRooms.Client
local Config = RoRooms.Config
local Packages = RoRooms.Packages

local Component = require(Packages.Component)
local OnyxUI = require(RoRooms.Packages.OnyxUI)
local Fusion = require(OnyxUI.Packages.Fusion)
local States = require(Client.UI.States)
local ItemsController = require(Client.Items.ItemsController)
local AttributeValue = require(Shared.ExtPackages.AttributeValue)

local New = Fusion.New
local Computed = Fusion.Computed
local Hydrate = Fusion.Hydrate

local ItemGiverComponent = Component.new {
	Tag = "RR_ItemGiver",
}

function ItemGiverComponent:GiveItem(Player: Player)
	if Player == Players.LocalPlayer then
		ItemsController:ToggleEquipItem(self.ItemId:get())
	end
end

function ItemGiverComponent:GetProximityPrompt()
	local ProximityPrompt = self.Instance:FindFirstChild("RR_ItemGiverPrompt")
	if not ProximityPrompt then
		ProximityPrompt = New "ProximityPrompt" {
			Name = "RR_ItemGiverPrompt",
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
			if self.Item:get() then
				if self.Equipped:get() then
					return "Unequip"
				else
					return "Equip"
				end
			else
				return self.ItemId:get()
			end
		end),
		ObjectText = Computed(function()
			if self.Item:get() then
				return self.Item:get().Name
			else
				return "Invalid item"
			end
		end),
	}

	return ProximityPrompt
end

function ItemGiverComponent:Start()
	self.ProximityPrompt = self:GetProximityPrompt()

	self.ProximityPrompt.Triggered:Connect(function(Player: Player)
		self:GiveItem(Player)
	end)
end

function ItemGiverComponent:Construct()
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
	if not self.Item:get() then
		warn("Could not find item from RR_ItemId", self.ItemId:get(), self.Instance)
	end
end

function ItemGiverComponent:Stop()
	self.DisconnectLevelMetObserver()
end

return ItemGiverComponent
