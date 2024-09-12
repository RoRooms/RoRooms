local Players = game:GetService("Players")

local RoRooms = script.Parent.Parent.Parent.Parent
local Component = require(RoRooms.Packages.Component)
local OnyxUI = require(RoRooms.Packages.OnyxUI)
local Fusion = require(RoRooms.Packages.Fusion)
local Nametag = require(RoRooms.Client.UI.Components.Nametag)

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

	self.Nametag = Scope:Nametag {
		Parent = self.Instance,
		Adornee = self.Head,
		Nickname = self.Nickname,
		Status = self.Status,
	}
end

function NametaggedCharacterComponent:Construct()
	self.Nickname = Scope:Value("")
	self.Status = Scope:Value("")

	self.Player = Players:GetPlayerFromCharacter(self.Instance)
	self.Humanoid = self.Instance:WaitForChild("Humanoid")
	self.Head = Scope:Value(self.Instance:WaitForChild("Head"))
end

return NametaggedCharacterComponent
