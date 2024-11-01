export type AnimatedComponent = {
	_Animator: Animator,
	_AnimationTracks: { [Animation]: AnimationTrack },
	_Animations: { [string]: Animation },

	PlayAnimation: (self: any, AnimationId: string) -> Animation,
	StopAnimation: (self: any, AnimationId: string) -> (),
	StopAnimations: (self: any) -> (),
	GetAnimationTrack: (self: any, AnimationId: string, Strict: boolean?) -> AnimationTrack,
	SetAnimator: (self: any, Animator: Animator) -> (),
}

local AnimatedComponent = {}

function AnimatedComponent.Stopping(Component: AnimatedComponent)
	Component:StopAnimations()
end

function AnimatedComponent.Constructing(Component: AnimatedComponent)
	Component._AnimationTracks = {}
	Component._Animations = {}

	local function AnimationFromId(AnimationId: string): Animation
		local Animation = Component._Animations[AnimationId]

		if Animation == nil then
			Animation = Instance.new("Animation")
			Animation.AnimationId = AnimationId
			Component._Animations[AnimationId] = Animation
		end

		return Animation
	end

	function Component:PlayAnimation(AnimationId: string)
		local AnimationTrack = self:GetAnimationTrack(AnimationId)
		if AnimationTrack then
			AnimationTrack:Play()

			return AnimationTrack
		end
	end

	function Component:StopAnimation(AnimationId: string)
		local AnimationTrack = self:GetAnimationTrack(AnimationId, true)
		if AnimationTrack then
			AnimationTrack:Stop()
		end
	end

	function Component:StopAnimations()
		for _, AnimationTrack in pairs(self._AnimationTracks) do
			AnimationTrack:Stop()
		end
	end

	function Component:CleanAnimations()
		self:StopAnimations()

		for _, AnimationTrack in pairs(self._AnimationTracks) do
			AnimationTrack:Destroy()
		end

		for _, Animation in pairs(self._Animations) do
			Animation:Destroy()
		end
	end

	function Component:GetAnimationTrack(AnimationId: string, Strict: boolean?): AnimationTrack
		local Animator = self._Animator
		if Animator then
			local AnimationTrack = self._AnimationTracks[AnimationId]

			if not Strict then
				if AnimationTrack == nil then
					AnimationTrack = Animator:LoadAnimation(AnimationFromId(AnimationId))
					self._AnimationTracks[AnimationId] = AnimationTrack
				end
			end

			return AnimationTrack
		end
	end

	function Component:SetAnimator(Animator: Animator | nil)
		self:CleanAnimations()

		self._Animator = Animator
	end
end

return AnimatedComponent
