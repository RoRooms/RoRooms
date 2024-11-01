local Players = game:GetService("Players")

local RoRooms = script.Parent.Parent.Parent.Parent
local Signal = require(RoRooms.Parent.Signal)

local AvatarSelector = {
	AvatarSelected = Signal.new(),
	AvatarDeselected = Signal.new(),
	AvatarHovered = Signal.new(),
	_AvatarSelecting = nil,
	_AvatarHovering = nil,
	_AvatarSelectionHighlight = Instance.new("Highlight"),
	_AvatarSelectionConnection = nil,
}

AvatarSelector._AvatarSelectionHighlight.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
AvatarSelector._AvatarSelectionHighlight.FillTransparency = 1
AvatarSelector._AvatarSelectionHighlight.OutlineTransparency = 0.25

function AvatarSelector:Start()
	self:Stop()

	local Mouse = Players.LocalPlayer:GetMouse()

	self._AvatarSelectionConnection = Mouse.Move:Connect(function()
		self._AvatarHovering = nil
		self._AvatarSelectionHighlight.Adornee = nil

		local Target = Mouse.Target
		if Target then
			local Character = Target:FindFirstAncestorOfClass("Model")
			if Character then
				local Player = Players:GetPlayerFromCharacter(Character)
				if Player then
					self._AvatarHovering = Character
					self._AvatarSelectionHighlight.Adornee = Character
					self.AvatarHovered:Fire(Character)
				end
			end
		end
	end)

	Mouse.Button1Down:Connect(function()
		local Character = self._AvatarHovering
		if Character then
			self._AvatarSelecting = Character
			self.AvatarSelected:Fire(Character)
		else
			if self._AvatarSelecting then
				self.AvatarDeselected:Fire(self._AvatarSelecting)
			end
			self._AvatarSelecting = nil
		end
	end)
end

function AvatarSelector:Stop()
	if self._AvatarSelectionConnection then
		self._AvatarSelectionConnection:Disconnect()
		self._AvatarSelectionConnection = nil
	end

	self._AvatarSelectionHighlight.Adornee = nil
end

return AvatarSelector
