local RoRooms = require(script.Parent.Parent.Parent.Parent)
local Component = require(RoRooms.Packages.Component)
local OnyxUI = require(RoRooms.Packages.OnyxUI)
local Fusion = require(RoRooms.Packages.Fusion)
local AttributeValue = require(RoRooms.Shared.ExtPackages.AttributeValue)
local States = require(RoRooms.Client.UI.States)

local Computed = Fusion.Computed
local Observer = Fusion.Observer

local LevelDoorComponent = Component.new {
	Tag = "RR_LevelDoor",
}

function LevelDoorComponent:Start()
	self.DisconnectLevelMetObserver = Observer(self.LevelMet):onChange(function()
		self.Instance.CanCollide = Use(self.LevelMet) == false
	end)
end

function LevelDoorComponent:Construct()
	self.LevelRequirement = AttributeValue(self.Instance, "RR_LevelRequirement", 0)
	self.LevelMet = Computed(function(Use)
		if Use(States.LocalPlayerData) and Use(States.LocalPlayerData).Level then
			return Use(States.LocalPlayerData).Level >= Use(self.LevelRequirement)
		else
			return false
		end
	end)

	if not self.Instance:IsA("BasePart") then
		warn("LevelDoor must be a BasePart object", self.Instance)
		return
	end
end

return LevelDoorComponent
