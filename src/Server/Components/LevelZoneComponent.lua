local RoRooms = script.Parent.Parent.Parent.Parent
local Component = require(RoRooms.Parent.Component)
local Zone = require(RoRooms.SourceCode.Shared.ExtPackages.Zone)
local Knit = require(RoRooms.Parent.Knit)
local AttributeValue = require(RoRooms.SourceCode.Shared.ExtPackages.AttributeValue)
local Fusion = require(RoRooms.Parent.Fusion)

local Peek = Fusion.peek

local PlayerDataService = Knit.GetService("PlayerDataService")

local LevelZoneComponent = Component.new {
	Tag = "RR_LevelZone",
}

function LevelZoneComponent:Start()
	self.Zone.playerEntered:Connect(function(Player: Player)
		local Profile = PlayerDataService:GetProfile(Player)
		if Profile then
			if Profile.Data.Level < Peek(self.LevelRequirement) then
				Player:LoadCharacter()
			end
		end
	end)
end

function LevelZoneComponent:Construct()
	self.LevelRequirement = AttributeValue(self.Instance, "RR_LevelRequirement", 0)

	self.Zone = Zone.new(self.Instance)
	self.Zone:setAccuracy("Low")
end

return LevelZoneComponent
