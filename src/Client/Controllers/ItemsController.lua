local RoRooms = require(script.Parent.Parent.Parent.Parent)

local Shared = RoRooms.Shared
local Client = RoRooms.Client
local Config = RoRooms.Config
local Packages = RoRooms.Packages

local Knit = require(Packages.Knit)
local Fusion = require(Shared.ExtPackages.NekaUI.Packages.Fusion)
local Signal = require(Packages.Signal)
local NeoHotbar = require(Packages.NeoHotbar)
local States = require(Client.UI.States)
local SharedData = require(Shared.SharedData)

local ItemsService
local UIController = require(Client.Controllers.UIController)

local ItemsMenu = require(Client.UI.ScreenGuis.ItemsMenu)

local ItemsController = {
  Name = "ItemsController"
}

function ItemsController:PromptItemPurchase(ItemId: string)
  local Item = Config.ItemsSystem.Items[ItemId]
  if Item then
    if not Item.PriceInCoins then
      warn("Item "..ItemId.." has no price set and can not be purchased.")
    end
    States:PushPrompt({
      Title = "Buy item",
      Text = "Do you want to buy "..Item.Name.." item for "..Item.PriceInCoins.." coins?",
      Buttons = {
        {
          Primary = false,
          Contents = {"Cancel"},
        },
        {
          Primary = true,
          Contents = {"Buy"},
          Callback = function()
            ItemsService:PurchaseItem(ItemId):andThen(function(Purchased: boolean)
              if Purchased then
                self:ToggleEquipItem(ItemId)
              else
                States:PushPrompt({
                  Title = "Failure",
                  Text = "Failed to purchase "..Item.Name.." item. Do you have enough coins?",
                  Buttons = {
                    {
                      Primary = false,
                      Contents = {"Close"},
                    },
                  }
                })
              end
            end)
          end
        },
      }
    })
  end
end

function ItemsController:ToggleEquipItem(ItemId: string)
  ItemsService:ToggleEquipItem(ItemId):andThen(function(Equipped: boolean, FailureReason: string, ResponseCode: number)
    if not Equipped then
      if ResponseCode == SharedData.ItemEquipResponseCodes.Unpurchased then
        self:PromptItemPurchase(ItemId)
      elseif FailureReason then
        States:PushPrompt({
          Title = "Failure",
          Text = FailureReason,
          Buttons = {
            {
              Primary = false,
              Contents = {"Close"},
            },
          }
        })
      end
    end
  end)
end

function ItemsController:UpdateEquippedItems()
  local Char = Knit.Player.Character
  local Backpack = Knit.Player:FindFirstChild("Backpack")
  local function ScanDirectory(Directory: Instance)
    if not Directory then return end
    for _, Child in ipairs(Directory:GetChildren()) do
      local ItemId = Child:GetAttribute("RR_ItemId")
      if Child:IsA("Tool") and Config.ItemsSystem.Items[ItemId] then
        table.insert(self.EquippedItems, ItemId)
      end
    end
  end
  self.EquippedItems = {}
  ScanDirectory(Char)
  ScanDirectory(Backpack)
  self.EquippedItemsUpdated:Fire(self.EquippedItems)
end

function ItemsController:_AddItemsMenuButton()
  NeoHotbar:AddCustomButton("ItemsMenuButton", "rbxassetid://6966623635", function()
    if not States.ItemsMenu.Open:get() then
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

  if NeoHotbar._Started then
    self:_AddItemsMenuButton()
  else
    UIController.NeoHotbarOnStart:Connect(function()
      self:_AddItemsMenuButton()
    end)
  end
end

function ItemsController:KnitInit()
  self.EquippedItems = Fusion.Value({})
  self.EquippedItemsUpdated = Signal.new()
end

return ItemsController