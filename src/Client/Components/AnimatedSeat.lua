local RoRooms = require(script.Parent.Parent.Parent.Parent)
local Players = game:GetService("Players")

local Shared = RoRooms.Shared
local Packages = RoRooms.Packages

local Component = require(Packages.Component)
local Fusion = require(Shared.ExtPackages.NekaUI.Packages.Fusion)
local AttributeValue = require(Shared.ExtPackages.AttributeValue)

local Value = Fusion.Value
local New = Fusion.New
local Computed = Fusion.Computed
local Hydrate = Fusion.Hydrate

local AnimatedSeat = Component.new {
	Tag = "RR_AnimatedSeat",
}

function AnimatedSeat:UpdateOccupant()
	if self.LastAnimationTrack then
		self.LastAnimationTrack:Stop()
		self.LastAnimationTrack = nil
	end

	if self.Instance.Occupant then
		local Humanoid = self.Instance.Occupant
		local Character = Humanoid:FindFirstAncestorOfClass("Model")

		if Character then
			self.Occupant:set(Players:GetPlayerFromCharacter(Character))
		end

		if self.Occupant:get() == Players.LocalPlayer then
			local Animator = Humanoid:FindFirstChild("Animator")
			if Animator then
				local AnimationTrack = Animator:LoadAnimation(self.Animation)
				AnimationTrack:Play()
				self.LastAnimationTrack = AnimationTrack
			end
		end
	else
		self.Occupant:set(nil)
	end
end

function AnimatedSeat:OnPromptTriggered(Player: Player)
	if Player == Players.LocalPlayer then
		local Char = Players.LocalPlayer.Character
		if Char then
			local Humanoid = Char:FindFirstChildOfClass("Humanoid")
			if Humanoid then
				self.Instance:Sit(Humanoid)
			end
		end
	end
end

function AnimatedSeat:GetProximityPrompt()
	local ProximityPrompt = self.Instance:FindFirstChild("RR_SitPrompt")
	if not ProximityPrompt then
		ProximityPrompt = New "ProximityPrompt" {
			Name = "RR_SitPrompt",
			Parent = self.Instance,
			ActionText = "",
			RequiresLineOfSight = false,
			MaxActivationDistance = 7.5,
		}
	end

	Hydrate(ProximityPrompt) {
		Enabled = Computed(function()
			return self.Occupant:get() == nil
		end),
	}

	return ProximityPrompt
end

function AnimatedSeat:Start()
	self.Instance.Disabled = not self.SitOnTouch:get()

	if self.PromptToSit:get() then
		self.ProximityPrompt = self:GetProximityPrompt()

		self.ProximityPrompt.Triggered:Connect(function(Player: Player)
			self:OnPromptTriggered(Player)
		end)
	end

	self.Instance:GetPropertyChangedSignal("Occupant"):Connect(function()
		self:UpdateOccupant()
	end)
end

function AnimatedSeat:Construct()
	self.PromptToSit = AttributeValue(self.Instance, "RR_PromptToSit", true)
	self.SitOnTouch = AttributeValue(self.Instance, "RR_SitOnTouch", false)
	self.Occupant = Value(nil)

	if not self.Instance:IsA("Seat") then
		warn("AnimatedSeat must be a Seat object", self.Instance)
		return
	end

	local Animation = self.Instance:WaitForChild("Animation")
	if Animation then
		self.Animation = Animation
	else
		warn("No Animation inside AnimatedSeat", self.Instance)
		return
	end
end

return AnimatedSeat
