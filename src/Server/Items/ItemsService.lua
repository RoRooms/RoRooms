local RoRooms = script.Parent.Parent.Parent.Parent
local PlayerDataStoreService = require(RoRooms.SourceCode.Server.PlayerDataStore.PlayerDataStoreService)
local t = require(RoRooms.Parent.t)
local Config = require(RoRooms.Config).Config

local ItemsService = {
	Name = "ItemsService",
	Client = {},
}

function ItemsService.Client:ToggleEquipItem(Player: Player, ItemId: string)
	assert(t.tuple(t.instanceOf("Player")(Player), t.string(ItemId)))

	return self.Server:ToggleEquipItemForPlayer(Player, ItemId)
end

function ItemsService:ToggleEquipItemForPlayer(Player: Player, ItemId: string)
	if self:_PlayerHasItem(Player, ItemId) then
		return self:TakeItemFromPlayer(Player, ItemId)
	else
		if #self:_FindItemsInPlayer(Player) < Config.Systems.Items.MaxItemsEquippable then
			return self:GiveItemToPlayer(Player, ItemId)
		end
	end

	return false
end

function ItemsService:GiveItemToPlayer(Player: Player, ItemId: string, BypassRequirement: boolean | nil)
	if not Player.Backpack then
		return
	end
	local Item = Config.Systems.Items.Items[ItemId]
	if Item and Item.Tool then
		local AbleToEquip = false
		local FailureReason
		local ResponseCode
		if not BypassRequirement then
			if Item.RequirementCallback then
				AbleToEquip, FailureReason = Item.RequirementCallback(Player, ItemId, Item)
				if not AbleToEquip then
					ResponseCode = false
					if not FailureReason then
						FailureReason = "Insuffient requirements to equip " .. Item.Name .. " item."
					end
				end
			else
				AbleToEquip = true
			end
			if AbleToEquip then
				local Profile = PlayerDataStoreService:GetProfile(Player.UserId)
				if Profile then
					if Item.LevelRequirement then
						AbleToEquip = Profile.Data.Level >= Item.LevelRequirement
						if not AbleToEquip then
							FailureReason = Item.Name .. " item requires level " .. Item.LevelRequirement .. "."
							ResponseCode = false
						end
					end
				end
			end
		else
			AbleToEquip = true
		end
		if AbleToEquip then
			local ItemTool = Item.Tool:Clone()
			ItemTool.Parent = Player.Backpack
		end
		return AbleToEquip, FailureReason, ResponseCode
	end

	return false
end

function ItemsService:TakeItemFromPlayer(Player: Player, ItemId: string)
	for _, ItemTool in ipairs(self:_FindItemsInPlayer(Player)) do
		if ItemTool:GetAttribute("RR_ItemId") == ItemId then
			ItemTool:Destroy()
		end
	end
end

function ItemsService:_FindItemsInPlayer(Player: Player)
	if not Player.Backpack or not Player.Character then
		return
	end
	local FoundItems = {}
	local function ScanDirectory(Directory: Instance)
		for _, Child in ipairs(Directory:GetChildren()) do
			if Child:IsA("Tool") and Child:GetAttribute("RR_ItemId") then
				table.insert(FoundItems, Child)
			end
		end
	end
	ScanDirectory(Player.Backpack)
	ScanDirectory(Player.Character)
	return FoundItems
end

function ItemsService:_PlayerHasItem(Player: Player, ItemId: string)
	local function ScanDirectory(Directory: Instance)
		for _, Child in ipairs(Directory:GetChildren()) do
			if Child:IsA("Tool") and Child:GetAttribute("RR_ItemId", ItemId) == ItemId then
				return true
			end
		end

		return false
	end

	if Player.Character ~= nil then
		return ScanDirectory(Player.Backpack) or ScanDirectory(Player.Character)
	end

	return false
end

for ItemId, Item in pairs(Config.Systems.Items.Items) do
	if Item.Tool then
		Item.Tool:SetAttribute("RR_ItemId", ItemId)
		Item.Tool.CanBeDropped = false
	else
		warn("No tool defined for " .. ItemId)
	end
end

return ItemsService
