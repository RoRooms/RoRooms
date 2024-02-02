local RoRooms = require(script.Parent.Parent.Parent.Parent)

local Shared = RoRooms.Shared
local Packages = RoRooms.Packages

local Component = require(Packages.Component)
local Zone = require(Shared.ExtPackages.Zone)
local Knit = require(Packages.Knit)
local AttributeValue = require(Shared.ExtPackages.AttributeValue)

local PlayerDataService = Knit.GetService("PlayerDataService")

local LevelZone = Component.new {
	Tag = "RR_LevelZone",
}

function LevelZone:Start()
	self.Zone.playerEntered:Connect(function(Player: Player)
		local Profile = PlayerDataService:GetProfile(Player)
		if Profile then
			if Profile.Data.Level < self.LevelRequirement:get() then
				Player:LoadCharacter()
			end
		end
	end)
end

function LevelZone:Construct()
	self.LevelRequirement = AttributeValue(self.Instance, "RR_LevelRequirement", 0)

	self.Zone = Zone.new(self.Instance)
	self.Zone:setAccuracy("Low")
end

return LevelZone
