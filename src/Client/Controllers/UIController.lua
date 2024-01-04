local RoRooms = require(game:GetService("ReplicatedStorage").RoRooms)
local StarterGui = game:GetService("StarterGui")

local Shared = RoRooms.Shared
local Client = RoRooms.Client
local Config = RoRooms.Config
local Packages = RoRooms.Packages

local Knit = require(Packages.Knit)
local Fusion = require(Shared.ExtPackages.NekaUI.Packages.Fusion)
local States = require(Client.UI.States)
local IconController = require(Shared.ExtPackages.Icon.IconController)
local NeoHotbar = require(Packages.NeoHotbar)
local Signal = require(Packages.Signal)
local Icon = require(Shared.ExtPackages.Icon)

local New = Fusion.New

local DEFAULT_UIS = {"Topbar", "PromptPopup"}

local UIController = {
  Name = "UIController",
}

function UIController:MountUI(UI: Instance)
  UI.Parent = self.RoRoomsUI
end

function UIController:_StartACM()
  local SelectionIndicator = New "Part" {
    Name = "Indicator",
    Locked = true,
    CanCollide = false,
    Anchored = true,
    Color = Color3.fromRGB(170, 170, 170),
    Material = Enum.Material.Neon,
    Size = Vector3.new(0.45, 0.45, 0.45),
  }
  StarterGui:SetCore("AvatarContextMenuEnabled", true)
  StarterGui:SetCore("AvatarContextMenuTheme", {
    BackgroundTransparency = 0.015,
    BackgroundColor = Color3.fromRGB(26, 26, 26),
    NameTagColor = Color3.fromRGB(26, 26, 26),
    ButtonFrameColor = Color3.fromRGB(26, 26, 26),
    ButtonColor = Color3.fromRGB(26, 26, 26),
    ButtonHoverColor = Color3.fromRGB(61, 61, 61),
    SelectedCharacterIndicator = SelectionIndicator
  })
end

function UIController:_StartTopbarIcons()
  -- self.XPMultiplierDropdownIcons = ForPairs()
  States.PlayerDataService.XPMultipliers:Observe(function(XPMultipliers: table)
    local TotalMultiplier = 1
    for OldKey, OldDropdownIcon in ipairs(self.XPMultiplierDropdownIcons) do
      OldDropdownIcon:leave()
      OldDropdownIcon:destroy()
      self.XPMultiplierDropdownIcons[OldKey] = nil
    end
    for Name, MultiplierAddon in pairs(XPMultipliers) do
      TotalMultiplier += MultiplierAddon
      table.insert(self.XPMultiplierDropdownIcons, Icon.new()
        :setLabel(Name.." +"..MultiplierAddon.."x")
        :lock()
      )
    end
    States.TopbarIcons.Multipliers:setLabel(TotalMultiplier.."x XP")
    States.TopbarIcons.Multipliers:setDropdown(self.XPMultiplierDropdownIcons)
  end)

  States.TopbarIcons.Coins.selected:Connect(function()
    States.TopbarIcons.Coins:deselect()
    Config.Interface.TopbarIcons.Coins.ActivationCallback()
  end)
  States.PlayerDataService.Coins:Observe(function(Coins: number)
    States.TopbarIcons.Coins:setLabel(Coins)
  end)

  States.TopbarIcons.Multipliers:setEnabled(false)
  States.TopbarIcons.Music:setEnabled(false)
end

function UIController:_CreateTopbarIcons()
  States.TopbarIcons.Music = Icon.new()
    :setImage(7059338404)
    :setRight()
  States.TopbarIcons.Music.deselectWhenOtherIconSelected = false

  States.TopbarIcons.Multipliers = Icon.new()
    :setEnabled(Config.Interface.TopbarIcons.Multipliers.Enabled)
    :setRight()
  
  States.TopbarIcons.Coins = Icon.new()
    :setEnabled(Config.Interface.TopbarIcons.Coins.Enabled)
    :setImage(Config.Interface.TopbarIcons.Coins.IconImage)
    :setRight()
end

function UIController:KnitStart()
  States:Start()

  for _, GuiName in ipairs(DEFAULT_UIS) do
    local GuiModule = Client.UI.ScreenGuis:FindFirstChild(GuiName)
    if GuiModule then
      local Gui = require(GuiModule)
      self:MountUI(Gui{})
    end
  end
  
  NeoHotbar:Start()
  NeoHotbar:OverrideGui(Client.UI.NeoHotbarGui, true)
  self.NeoHotbarOnStart:Fire()

  self:_StartACM()
  self:_StartTopbarIcons()
end

function UIController:KnitInit()
  self.RoRoomsUI = New "ScreenGui" {
    Name = "RoRoomsUI",
    Parent = Knit.Player:WaitForChild("PlayerGui"),
    ResetOnSpawn = false,
  }

  self.NeoHotbarOnStart = Signal.new()

  IconController.voiceChatEnabled = true
  self.XPMultiplierDropdownIcons = {}

  self:_CreateTopbarIcons()
end

return UIController