local Players = game:GetService("Players")

local RoRooms = script.Parent.Parent.Parent.Parent
local AttributeBind = require(RoRooms.SourceCode.Shared.ExtPackages.AttributeBind)
local Component = require(RoRooms.Parent.Component)
local States = require(RoRooms.SourceCode.Client.UI.States)
local Fusion = require(RoRooms.Parent.Fusion)
local Trove = require(RoRooms.Parent.Trove)

local Peek = Fusion.peek

local DEBOUNCE_DURATION = 1

local WorldTeleporterComponent = Component.new {
	Tag = "RR_WorldTeleporter",
}

function WorldTeleporterComponent:_PromptTeleport()
	if (os.time() - self.DebounceTimestamp) >= DEBOUNCE_DURATION then
		self.DebounceTimestamp = os.time()
	else
		return
	end

	local PlaceId = Peek(self.PlaceId)

	if PlaceId then
		States.WorldPageMenu.PlaceId:set(PlaceId)
		States.Menus.CurrentMenu:set("WorldPageMenu")
	end
end

function WorldTeleporterComponent:Start()
	self.Instance.Touched:Connect(function(TouchedPart: BasePart)
		local Character = TouchedPart:FindFirstAncestorOfClass("Model")
		if Character then
			local Player = Players:GetPlayerFromCharacter(Character)
			if Player == Players.LocalPlayer then
				if #Peek(States.Prompts) == 0 then
					self:_PromptTeleport(Peek(self.PlaceId))
				end
			end
		end
	end)
end

function WorldTeleporterComponent:Construct()
	self.Scope = Fusion.scoped(Fusion)
	self.Trove = Trove.new()

	self.PlaceId = self.Scope:Value()
	self.Trove:Add(AttributeBind.Bind(self.Instance, "RR_PlaceId")):Observe(function(Value)
		self.PlaceId:set(Value)
	end)

	self.DebounceTimestamp = 0

	if not self.Instance:IsA("BasePart") then
		warn("WorldTeleporter must be a BasePart object", self.Instance)
		return
	end
	if not Peek(self.PlaceId) then
		warn("No RR_PlaceId attribute defined for WorldTeleporter", self.Instance)
		return
	end
end

function WorldTeleporterComponent:Stop()
	self.Trove:Destroy()
end

return WorldTeleporterComponent
