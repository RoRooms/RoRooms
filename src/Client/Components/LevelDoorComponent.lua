local RoRooms = script.Parent.Parent.Parent.Parent
local Component = require(RoRooms.Parent.Component)
local Fusion = require(RoRooms.Parent.Fusion)
local AttributeValue = require(RoRooms.SourceCode.Shared.ExtPackages.AttributeValue)
local States = require(RoRooms.SourceCode.Client.UI.States)

local Peek = Fusion.peek

local LevelDoorComponent = Component.new {
	Tag = "RR_LevelDoor",
}

function LevelDoorComponent:Start()
	self.DisconnectLevelMetObserver = Scope:Observer(self.LevelMet):onChange(function()
		self.Instance.CanCollide = Peek(self.LevelMet) == false
	end)
end

function LevelDoorComponent:Construct()
	self.LevelRequirement = AttributeValue(self.Instance, "RR_LevelRequirement", 0)
	self.LevelMet = Scope:Computed(function(Use)
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
