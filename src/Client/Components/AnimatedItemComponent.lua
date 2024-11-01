local RoRooms = script.Parent.Parent.Parent.Parent
local Component = require(RoRooms.Parent.Component)
local ToolComponent = require(RoRooms.SourceCode.Shared.ExtPackages.ToolComponent)
local AnimatedComponent = require(RoRooms.SourceCode.Shared.ExtPackages.AnimatedComponent)

local AnimatedItemComponent = Component.new {
	Tag = `RR_{string.gsub(script.Name, "Component$", "")}`,
	Extensions = { ToolComponent, AnimatedComponent },

	Animations = {},
}

function AnimatedItemComponent:SetAnimation(AnimationNumber: number?)
	if AnimationNumber ~= nil then
		local Animation = self.Animations[AnimationNumber]
		if Animation and Animation.AnimationId then
			self:StopAnimations()
			self:PlayAnimation(Animation.AnimationId)
		else
			self:StopAnimations()
		end
	else
		self:StopAnimations()
	end

	self.Instance:SetAttribute("RR_ActiveItemAnimation", AnimationNumber)
end

function AnimatedItemComponent:CycleAnimation()
	local ActiveAnimation = self.Instance:GetAttribute("RR_ActiveItemAnimation") or 0
	if ActiveAnimation == #self.Animations then
		ActiveAnimation = 0
	end
	ActiveAnimation += 1

	self:SetAnimation(ActiveAnimation)
end

function AnimatedItemComponent:ToolActivate()
	self:CycleAnimation()
end

function AnimatedItemComponent:ToolEquip(Holder: ToolComponent.Holder)
	self:SetAnimator(Holder.Animator)
	self:SetAnimation(1)
end

function AnimatedItemComponent:ToolUnequip()
	self:StopAnimations()
end

function AnimatedItemComponent:_RegisterAnimations()
	local Animations: { Animation } = {}

	local ItemAnimationsFolder = self.Instance:FindFirstChild("RR_ItemAnimations")
	if ItemAnimationsFolder ~= nil then
		for Count = 1, #ItemAnimationsFolder:GetChildren() do
			local Animation = ItemAnimationsFolder:FindFirstChild(Count)
			if Animation and Animation:IsA("Animation") then
				table.insert(Animations, Animation)
			end
		end
	end

	table.sort(Animations, function(AnimationA: Animation, AnimationB: Animation)
		return tonumber(AnimationA.Name) < tonumber(AnimationB.Name)
	end)

	self.Animations = Animations
	return Animations
end

function AnimatedItemComponent:Construct()
	local Animations = self:_RegisterAnimations()
	if #Animations == 0 then
		warn("RR_ItemAnimations are incorrectly set up for RR_AnimatedItem", self.Instance)
	end
end

return AnimatedItemComponent
