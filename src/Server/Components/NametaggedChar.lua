local Players = game:GetService("Players")
local RoRooms = require(game:GetService("ReplicatedStorage").RoRooms)

local Shared = RoRooms.Shared
local Client = RoRooms.Client

local Component = require(Shared.Packages.Component)
local Fusion = require(Shared.ExtPackages.NekaUI.Packages.Fusion)

local Value = Fusion.Value

local Nametag = require(Client.UI.Components.Nametag)

local NametaggedChar = Component.new {
  Tag = "RR_NametaggedChar"
}

function NametaggedChar:UpdateNickname()
  local Nickname = self.Player:GetAttribute("RR_Nickname") or ""
  local DisplayName = ""
  if self.Humanoid then
    DisplayName = self.Humanoid.DisplayName
  end
  if utf8.len(Nickname) > 0 then
    self.Nickname:set(Nickname)
  elseif utf8.len(DisplayName) > 0 then
    self.Nickname:set(DisplayName)
  else
    self.Nickname:set(self.Instance.Name)
  end
end

function NametaggedChar:UpdateStatus()
  self.Status:set(self.Player:GetAttribute("RR_Status") or "")
end

function NametaggedChar:Start()
  self.Instance.ChildAdded:Connect(function(Child: Instance)
    if Child.Name == "Head" then
      self.Head:set(Child)
    end
  end)

  self.Nickname = Value()
  self.Status = Value()
  
  self:UpdateNickname()
  self.Player:GetAttributeChangedSignal("RR_Nickname"):Connect(function()
    self:UpdateNickname()
  end)
  self:UpdateStatus()
  self.Player:GetAttributeChangedSignal("RR_Status"):Connect(function()
    self:UpdateStatus()
  end)

  self.Nametag = Nametag {
    Parent = self.Instance,
    Adornee = self.Head,
    Nickname = self.Nickname,
    Status = self.Status,
  }
  if self.Humanoid then
    self.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
  end
end

function NametaggedChar:Construct()
  self.Player = Players:GetPlayerFromCharacter(self.Instance)
  self.Humanoid = self.Instance:WaitForChild("Humanoid")
  self.Head = Value(self.Instance:WaitForChild("Head"))
end

return NametaggedChar