local RoRooms = require(game:GetService("ReplicatedStorage").RoRooms)

local Shared = RoRooms.Shared
local Client = RoRooms.Client
local Server = RoRooms.Server

local Component = require(Shared.Packages.Component)
local Fusion = require(Shared.ExtPackages.NekaUI.Packages.Fusion)

local PlayerChar = require(Server.Components.PlayerChar)

local Value = Fusion.Value

local Nametag = require(Client.UI.Components.Nametag)

local NametaggedChar = Component.new {
  Tag = "RR_NametaggedChar"
}

function NametaggedChar:UpdateNickname()
  local RoRoomsNickname = self.Player:GetAttribute("RR_Nickname") or ""
  local DisplayName = ""
  if self.PlayerChar.Humanoid then
    DisplayName = self.PlayerChar.Humanoid.DisplayName
  end
  if utf8.len(RoRoomsNickname) > 0 then
    self.Nickname:set(RoRoomsNickname)
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
  self.PlayerChar = self:GetComponent(PlayerChar)

  self.Player = self.PlayerChar.Player
  self.Humanoid = self.Instance:WaitForChild("Humanoid")
  self.Head = Value(self.Instance:WaitForChild("Head"))

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
  
end

return NametaggedChar