local RoRooms = script.Parent.Parent.Parent.Parent
local Component = require(RoRooms.Parent.Component)
local Zone = require(RoRooms.Parent.Zone)
local Fusion = require(RoRooms.Parent.Fusion)
local AttributeBind = require(RoRooms.SourceCode.Shared.ExtPackages.AttributeBind)
local Trove = require(RoRooms.Parent.Trove)
local PlayerDataStoreService = require(RoRooms.SourceCode.Server.PlayerData.PlayerDataStoreService)

local Peek = Fusion.peek

local LevelZoneComponent = Component.new {
	Tag = "RR_LevelZone",
}

function LevelZoneComponent:Start()
	self.Zone.playerEntered:Connect(function(Player: Player)
		local Profile = PlayerDataStoreService:GetProfile(Player.UserId)
		if Profile then
			if Profile.Data.Level < Peek(self.LevelRequirement) then
				Player:LoadCharacter()
			end
		end
	end)
end

function LevelZoneComponent:Construct()
	self.Scope = Fusion.scoped(Fusion)
	self.Trove = Trove.new()

	self.LevelRequirement = self.Scope:Value()
	self.Trove:Add(AttributeBind.Bind(self.Instance, "RR_LevelRequirement", 0)):Observe(function(Value)
		self.LevelRequirement:set(Value)
	end)

	self.Zone = Zone.new(self.Instance)
	self.Zone:setAccuracy("Low")
end

function LevelZoneComponent:Stop()
	self.Trove:Destroy()
end

return LevelZoneComponent
