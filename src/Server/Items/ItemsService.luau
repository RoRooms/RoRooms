local MarketplaceService = game:GetService("MarketplaceService")
local Rorooms = script.Parent.Parent.Parent.Parent
local PlayerDataStoreService = require(Rorooms.SourceCode.Server.PlayerDataStore.PlayerDataStoreService)
local t = require(Rorooms.Parent.t)
local Config = require(Rorooms.Config).Config
local Future = require(Rorooms.Parent.Future)
local GamepassesHandler = require(Rorooms.SourceCode.Shared.ExtPackages.GamepassesHandler)

local ItemsService = {
	Name = "ItemsService",
	Client = {},
}

function ItemsService.Client:ToggleEquipItem(Player: Player, ItemId: string, Hold: boolean?)
	assert(t.tuple(t.instanceOf("Player")(Player), t.string(ItemId)))

	return self.Server:ToggleEquipItemForPlayer(Player, ItemId, Hold)
end

function ItemsService:ToggleEquipItemForPlayer(Player: Player, ItemId: string, Hold: boolean?)
	if self:_PlayerHasItem(Player, ItemId) then
		return self:TakeItemFromPlayer(Player, ItemId)
	else
		if #self:_FindItemsInPlayer(Player) < Config.Systems.Items.MaxItemsEquippable then
			return self:GiveItemToPlayer(Player, ItemId, false, Hold)
		end
	end

	return false
end

function ItemsService:GiveItemToPlayer(Player: Player, ItemId: string, BypassRequirement: boolean?, Hold: boolean?)
	local Backpack = Player:FindFirstChild("Backpack")
	local Character = Player.Character
	if not Backpack then
		return
	end
	if not Character then
		return
	end

	local Item = Config.Systems.Items.Items[ItemId]
	if Item and Item.Tool then
		local AbleToEquip, FailureReason = self:CanPlayerAccessItem(Player, ItemId, BypassRequirement)

		if AbleToEquip then
			local ItemTool = Item.Tool:Clone()
			ItemTool.Parent = Backpack

			if Hold then
				local Humanoid = Character:FindFirstChildOfClass("Humanoid")
				if Humanoid then
					Humanoid:EquipTool(ItemTool)
				end
			end
		end
		return AbleToEquip, FailureReason
	end

	return false
end

function ItemsService:CanPlayerAccessItem(Player: Player, ItemId: string, Bypass: boolean?)
	if Bypass then
		return true
	end

	local Item = Config.Systems.Items.Items[ItemId]
	if Item ~= nil then
		if Item.CallbackRequirement then
			local AbleToEquip, FailureReason = Item.CallbackRequirement(Player, ItemId, Item)

			if (not AbleToEquip) and (FailureReason == nil) then
				FailureReason = "Insuffient requirements to equip " .. Item.DisplayName .. "."
			end

			return AbleToEquip, FailureReason
		end

		if Item.GamepassRequirement ~= nil then
			local OwnsGamepass = GamepassesHandler:PlayerOwnsGamepass(Player, Item.GamepassRequirement)

			if OwnsGamepass then
				return true
			else
				Future.Try(function()
					MarketplaceService:PromptGamePassPurchase(Player, Item.GamepassRequirement)
				end)

				return false
			end
		end

		if Item.LevelRequirement ~= nil then
			local Profile = PlayerDataStoreService:GetProfile(Player.UserId)
			if Profile then
				if Profile.Data.Level < Item.LevelRequirement then
					return false, Item.DisplayName .. " item requires level " .. Item.LevelRequirement .. "."
				end
			end
		end
	end

	return true
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
