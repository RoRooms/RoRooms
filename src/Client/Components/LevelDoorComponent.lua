local RoRooms = script.Parent.Parent.Parent.Parent
local Component = require(RoRooms.Parent.Component)
local Fusion = require(RoRooms.Parent.Fusion)
local States = require(RoRooms.SourceCode.Client.UI.States)
local AttributeBind = require(RoRooms.SourceCode.Shared.ExtPackages.AttributeBind)
local Trove = require(RoRooms.Parent.Trove)

local Peek = Fusion.peek

local LevelDoorComponent = Component.new {
	Tag = "RR_LevelDoor",
}

function LevelDoorComponent:Start()
	self.DisconnectLevelMetObserver = self.Scope:Observer(self.LevelMet):onChange(function()
		self.Instance.CanCollide = Peek(self.LevelMet) == false
	end)
end

function LevelDoorComponent:Construct()
	self.Scope = Fusion.scoped(Fusion)
	self.Trove = Trove.new()

	self.LevelRequirement = self.Scope:Value()
	self.Trove:Add(AttributeBind.Bind(self.Instance, "RR_LevelRequirement", 0)):Observe(function(Value)
		self.LevelRequirement:set(Value)
	end)

	self.LevelMet = self.Scope:Computed(function(Use)
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

function LevelDoorComponent:Stop()
	self.Trove:Destroy()
end

return LevelDoorComponent
