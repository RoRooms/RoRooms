local RoRooms = script.Parent.Parent.Parent.Parent
local Component = require(RoRooms.Parent.Component)
local Zone = require(RoRooms.Parent.Zone)
local Fusion = require(RoRooms.Parent.Fusion)
local AttributeBind = require(RoRooms.SourceCode.Shared.ExtPackages.AttributeBind)
local Trove = require(RoRooms.Parent.Trove)
local PlayerDataStoreService = require(RoRooms.SourceCode.Server.PlayerDataStore.PlayerDataStoreService)
local GamepassesHandler = require(RoRooms.SourceCode.Shared.ExtPackages.GamepassesHandler)

local Peek = Fusion.peek

local LockedZoneComponent = Component.new {
	Tag = "RR_LockedZone",
}

function LockedZoneComponent:Start()
	self.Zone.playerEntered:Connect(function(Player: Player)
		local CanPlayerAccess = self:_IsPlayerAccepted(Player)

		if not CanPlayerAccess then
			Player:LoadCharacter()
		end
	end)
end

function LockedZoneComponent:_IsPlayerAccepted(Player: Player)
	local LevelRequirementValue = Peek(self.LevelRequirement)
	local GamepassRequirementValue = Peek(self.GamepassRequirement)

	local Profile = PlayerDataStoreService:GetProfile(Player.UserId)
	if Profile then
		if Profile.Data.Level < LevelRequirementValue then
			return false
		end
	end

	if GamepassRequirementValue ~= nil then
		local OwnsGamepass = GamepassesHandler:PlayerOwnsGamepass(Player, GamepassRequirementValue)

		if not OwnsGamepass then
			return false
		end
	end

	return true
end

function LockedZoneComponent:Construct()
	self.Scope = Fusion.scoped(Fusion)
	self.Trove = Trove.new()

	self.LevelRequirement = self.Scope:Value()
	self.Trove:Add(AttributeBind.Bind(self.Instance, "RR_LevelRequirement", 0)):Observe(function(Value)
		self.LevelRequirement:set(Value)
	end)

	self.GamepassRequirement = self.Scope:Value()
	self.Trove:Add(AttributeBind.Bind(self.Instance, "RR_GamepassRequirement", nil)):Observe(function(Value)
		self.GamepassRequirement:set(Value)
	end)

	self.Zone = Zone.new(self.Instance)
	self.Zone:setAccuracy("Low")
end

function LockedZoneComponent:Stop()
	self.Trove:Destroy()
end

return LockedZoneComponent
