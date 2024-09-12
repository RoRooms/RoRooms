local RoRooms = require(script.Parent.Parent.Parent.Parent)
local Component = require(RoRooms.Packages.Component)
local Zone = require(RoRooms.Shared.ExtPackages.Zone)
local Knit = require(RoRooms.Packages.Knit)
local AttributeValue = require(RoRooms.Shared.ExtPackages.AttributeValue)

local PlayerDataService = Knit.GetService("PlayerDataService")

local LevelZoneComponent = Component.new {
	Tag = "RR_LevelZone",
}

function LevelZoneComponent:Start()
	self.Zone.playerEntered:Connect(function(Player: Player)
		local Profile = PlayerDataService:GetProfile(Player)
		if Profile then
			if Profile.Data.Level < Use(self.LevelRequirement) then
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
