local RoRooms = require(script.Parent.Parent.Parent.Parent)

local Shared = RoRooms.Shared
local Client = RoRooms.Client
local Config = RoRooms.Config
local Packages = RoRooms.Packages

local Component = require(Packages.Component)
local Fusion = require(Shared.ExtPackages.NekaUI.Packages.Fusion)
local Knit = require(Packages.Knit)
local States = require(Client.UI.States)

local New = Fusion.New
local Computed = Fusion.Computed

local ItemsController = Knit.GetController("ItemsController")

local ItemGiver = Component.new {
	Tag = "RR_ItemGiver",
}

function ItemGiver:Start()
	self.ProximityPrompt.Triggered:Connect(function(Player: Player)
		if Player ~= Knit.Player then
			return
		end
		if self.Item:get() and ItemsController then
			ItemsController:ToggleEquipItem(self.ItemId)
		end
	end)
end

function ItemGiver:Construct()
	self.ItemId = self.Instance:GetAttribute("RR_ItemId")
	self.Item = Computed(function()
		return Config.ItemsSystem.Items[self.ItemId]
	end)
	self.Equipped = Computed(function()
		return table.find(States.EquippedItems:get(), self.ItemId) ~= nil
	end)

	if not self.ItemId then
		warn("No RR_ItemId attribute defined for ItemGiver", self.Instance)
	end
	if not self.Item then
		warn("Could not find item by ItemId " .. self.ItemId, self.Instance)
	end

	self.ProximityPrompt = New "ProximityPrompt" {
		Name = "ItemGiverPrompt",
		Parent = self.Instance,
		Enabled = Computed(function()
			return self.Item:get() ~= nil and ItemsController ~= nil
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
		MaxActivationDistance = self.Instance:GetAttribute("RR_MaxActivationDistance") or 7,
	}
end

return ItemGiver
