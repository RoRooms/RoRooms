local Players = game:GetService("Players")
local RoRooms = require(script.Parent.Parent.Parent.Parent)

local Shared = RoRooms.Shared
local Client = RoRooms.Client
local Packages = RoRooms.Packages

local Component = require(Packages.Component)
local Fusion = require(Shared.ExtPackages.OnyxUI.Packages.Fusion)
local Nametag = require(Client.UI.Components.Nametag)

local Value = Fusion.Value

local NametaggedCharacterComponent = Component.new {
	Tag = "RR_NametaggedCharacter",
}

function NametaggedCharacterComponent:UpdateNickname()
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

function NametaggedCharacterComponent:UpdateStatus()
	self.Status:set(self.Player:GetAttribute("RR_Status") or "")
end

function NametaggedCharacterComponent:Start()
	self.Instance.ChildAdded:Connect(function(Child: Instance)
		if Child.Name == "Head" then
			self.Head:set(Child)
		end
	end)

	if self.Humanoid then
		self.Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	end

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
end

function NametaggedCharacterComponent:Construct()
	self.Nickname = Value("")
	self.Status = Value("")

	self.Player = Players:GetPlayerFromCharacter(self.Instance)
	self.Humanoid = self.Instance:WaitForChild("Humanoid")
	self.Head = Value(self.Instance:WaitForChild("Head"))
end

return NametaggedCharacterComponent