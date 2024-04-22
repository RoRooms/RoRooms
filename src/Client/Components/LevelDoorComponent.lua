local RoRooms = require(script.Parent.Parent.Parent.Parent)

local Packages = RoRooms.Packages
local Shared = RoRooms.Shared
local Client = RoRooms.Client

local Component = require(Packages.Component)
local OnyxUI = require(Shared.ExtPackages.OnyxUI)
local Fusion = require(OnyxUI._Packages.Fusion)
local AttributeValue = require(Shared.ExtPackages.AttributeValue)
local States = require(Client.UI.States)

local Computed = Fusion.Computed
local Observer = Fusion.Observer

local LevelDoorComponent = Component.new {
	Tag = "RR_LevelDoor",
}

function LevelDoorComponent:Start()
	self.DisconnectLevelMetObserver = Observer(self.LevelMet):onChange(function()
		self.Instance.CanCollide = self.LevelMet:get() == false
	end)
end

function LevelDoorComponent:Construct()
	self.LevelRequirement = AttributeValue(self.Instance, "RR_LevelRequirement", 0)
	self.LevelMet = Computed(function()
		if States.LocalPlayerData:get() and States.LocalPlayerData:get().Level then
			return States.LocalPlayerData:get().Level >= self.LevelRequirement:get()
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
