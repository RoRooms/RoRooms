local Players = game:GetService("Players")
local Rorooms = script.Parent.Parent.Parent.Parent
local Component = require(Rorooms.Parent.Component)
local Fusion = require(Rorooms.Parent.Fusion)
local States = require(Rorooms.SourceCode.Client.UI.States)
local AttributeBind = require(Rorooms.SourceCode.Shared.ExtPackages.AttributeBind)
local Trove = require(Rorooms.Parent.Trove)
local GamepassesHandler = require(Rorooms.SourceCode.Shared.ExtPackages.GamepassesHandler)

local Peek = Fusion.peek

local LockedDoorComponent = Component.new {
	Tag = "RR_LockedDoor",
}

function LockedDoorComponent:Start()
	self.Scope:Observer(States.Leveling.Level):onChange(function()
		self:UpdateLock()
	end)
	self.Scope:Observer(self.LevelRequirement):onChange(function()
		self:UpdateLock()
	end)
	self.Scope:Observer(self.GamepassRequirement):onChange(function()
		self:UpdateLock()
	end)

	GamepassesHandler.PlayerPurchasedGamepass:Connect(function(Player: Player, GamepassId: number)
		if (Player == Players.LocalPlayer) and (GamepassId == Peek(self.GamepassRequirement)) then
			self:UpdateLock()
		end
	end)

	self:UpdateLock()
end

function LockedDoorComponent:UpdateLock()
	self.Instance.CanCollide = not self:_IsPlayerAccepted(Players.LocalPlayer)
end

function LockedDoorComponent:_IsPlayerAccepted(Player: Player)
	local LevelRequirementValue = Peek(self.LevelRequirement)
	local GamepassRequirementValue = Peek(self.GamepassRequirement)
	local PlayerLevelValue = Peek(States.Leveling.Level)

	if PlayerLevelValue < LevelRequirementValue then
		return false
	end

	if GamepassRequirementValue ~= nil then
		local OwnsGamepass = GamepassesHandler:PlayerOwnsGamepass(Player, GamepassRequirementValue)

		if not OwnsGamepass then
			return false
		end
	end

	return true
end

function LockedDoorComponent:Construct()
	self.Scope = Fusion.scoped(Fusion)
	self.Trove = Trove.new()

	if not self.Instance:IsA("BasePart") then
		warn("LevelDoor must be a BasePart object", self.Instance)
		return
	end

	self.LevelRequirement = self.Scope:Value()
	self.Trove:Add(AttributeBind.Bind(self.Instance, "RR_LevelRequirement", 0)):Observe(function(Value)
		self.LevelRequirement:set(Value)
	end)

	self.GamepassRequirement = self.Scope:Value()
	self.Trove:Add(AttributeBind.Bind(self.Instance, "RR_GamepassRequirement", nil)):Observe(function(Value)
		self.GamepassRequirement:set(Value)
	end)
end

function LockedDoorComponent:Stop()
	self.Trove:Destroy()
	self.Scope:doCleanup()
end

return LockedDoorComponent
