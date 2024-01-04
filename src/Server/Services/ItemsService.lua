local RoRooms = require(script.Parent.Parent.Parent.Parent)

local Server = RoRooms.Server
local Shared = RoRooms.Shared
local Config = RoRooms.Config

local SharedData = require(Shared.SharedData)

local PlayerDataService = require(Server.Services.PlayerDataService)

local ItemsService = {
  Name = "ItemsService",
  Client = {}
}

function ItemsService.Client:ToggleEquipItem(Player: Player, ItemId: number)
  return self.Server:ToggleEquipItemForPlayer(Player, ItemId)
end

function ItemsService.Client:PurchaseItem(Player: Player, ItemId: number)
  return PlayerDataService:PurchaseItem(Player, ItemId)
end

function ItemsService:ToggleEquipItemForPlayer(Player: Player, ItemId: number)
  if self:_PlayerHasItem(Player, ItemId) then
    self:TakeItemFromPlayer(Player, ItemId)
  else
    if #self:_FindItemsInPlayer(Player) < Config.ItemsSystem.MaxItemsEquippable then
      return self:GiveItemToPlayer(Player, ItemId)
    end
  end
end

function ItemsService:GiveItemToPlayer(Player: Player, ItemId: number, BypassRequirement: boolean|nil)
  if not Player.Backpack then return end
  local Item = Config.ItemsSystem.Items[ItemId]
  if Item and Item.Tool then
    local AbleToEquip = false
    local FailureReason
    local ResponseCode
    if not BypassRequirement then
      if Item.RequirementCallback then
        AbleToEquip, FailureReason = Item.RequirementCallback(Player, ItemId, Item)
        if not AbleToEquip then
          ResponseCode = SharedData.ItemEquipResponseCodes.RequirementFailure
          if not FailureReason then
            FailureReason = "Insuffient requirements to equip "..Item.Name.." item."
          end
        end
      else
        AbleToEquip = true
      end
      if AbleToEquip then
        local Profile = PlayerDataService:GetProfile(Player)
        if Profile then
          if Item.LevelRequirement then
            AbleToEquip = Profile.Data.Level >= Item.LevelRequirement
            if not AbleToEquip then
              FailureReason = Item.Name.." item requires level "..Item.LevelRequirement.."."
              ResponseCode = SharedData.ItemEquipResponseCodes.LevelRequirementFailure
            end
          end
          if AbleToEquip and Item.PriceInCoins then
            AbleToEquip = table.find(Profile.Data.PurchasedItems, ItemId) ~= nil
            if not AbleToEquip then
              FailureReason = Item.Name.." item not purchased."
              ResponseCode = SharedData.ItemEquipResponseCodes.Unpurchased
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
end

function ItemsService:TakeItemFromPlayer(Player: Player, ItemId: number)
  for _, ItemTool in ipairs(self:_FindItemsInPlayer(Player)) do
    if ItemTool:GetAttribute("RR_ItemId") == ItemId then
      ItemTool:Destroy()
    end
  end
end

function ItemsService:_FindItemsInPlayer(Player: Player)
  if not Player.Backpack or not Player.Character then return end
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

function ItemsService:_PlayerHasItem(Player: Player, ItemId: number)
  local function ScanDirectory(Directory: Instance)
    for _, Child in ipairs(Directory:GetChildren()) do
      if Child:IsA("Tool") and Child:GetAttribute("RR_ItemId", ItemId) == ItemId then
        return true
      end
    end
  end
  return ScanDirectory(Player.Backpack) or ScanDirectory(Player.Character)
end

function ItemsService:KnitStart()
  
end

function ItemsService:KnitInit()
  for ItemId, Item in pairs(Config.ItemsSystem.Items) do
    if Item.Tool then
      Item.Tool:SetAttribute("RR_ItemId", ItemId)
      Item.Tool.CanBeDropped = false
    else
      warn("No tool defined for "..ItemId)
    end
  end
end

return ItemsService