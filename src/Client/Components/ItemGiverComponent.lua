local Players = game:GetService("Players")

local RoRooms = require(script.Parent.Parent.Parent.Parent)
local Component = require(RoRooms.Packages.Component)
local OnyxUI = require(RoRooms.Packages.OnyxUI)
local Fusion = require(RoRooms.Packages.Fusion)
local States = require(RoRooms.Client.UI.States)
local ItemsController = require(RoRooms.Client.Items.ItemsController)
local AttributeValue = require(RoRooms.Shared.ExtPackages.AttributeValue)

local Peek = Fusion.peek

local ItemGiverComponent = Component.new {
	Tag = "RR_ItemGiver",
}

function ItemGiverComponent:GiveItem(Player: Player)
	if Player == Players.LocalPlayer then
		ItemsController:ToggleEquipItem(Peek(self.ItemId))
	end
end

function ItemGiverComponent:GetProximityPrompt()
	local ProximityPrompt = self.Instance:FindFirstChild("RR_ItemGiverPrompt")
	if not ProximityPrompt then
		ProximityPrompt = Scope:New "ProximityPrompt" {
			Name = "RR_ItemGiverPrompt",
			Parent = self.Instance,
			ActionText = "",
			RequiresLineOfSight = false,
			MaxActivationDistance = 7.5,
		}
	end

	Scope:Hydrate(ProximityPrompt) {
		Enabled = Scope:Computed(function(Use)
			return Use(self.Item) ~= nil
		end),
		ActionText = Scope:Computed(function(Use)
			if Use(self.Item) then
				if Use(self.Equipped) then
					return "Unequip"
				else
					return "Equip"
				end
			else
				return Use(self.ItemId)
			end
		end),
		ObjectText = Scope:Computed(function(Use)
			if Use(self.Item) then
				return Use(self.Item).Name
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
	self.Item = Scope:Computed(function(Use)
		return RoRooms.Config.Systems.Items.Items[Use(self.ItemId)]
	end)
	self.Equipped = Scope:Computed(function(Use)
		return table.find(Use(States.EquippedItems), Use(self.ItemId)) ~= nil
	end)

	if not Peek(self.ItemId) then
		warn("No RR_ItemId attribute defined for ItemGiver", self.Instance)
	end
	if not Peek(self.Item) then
		warn("Could not find item from RR_ItemId", Peek(self.ItemId), self.Instance)
	end
end

function ItemGiverComponent:Stop()
	self.DisconnectLevelMetScope:Observer()
end

return ItemGiverComponent
