local Players = game:GetService("Players")

local DefaultSounds = require(script.DefaultSounds)

local BLACKLISTEED_MATERIALS = { Enum.Material.Air, Enum.Material.Water }

local Footstepper = {
	BaseVolume = 5,
}

function Footstepper:UpdateSounds(Sounds: table, SoundProperties: table)
	for _, Sound in ipairs(Sounds) do
		local SoundInfo = SoundProperties[Sound.Name]
		if SoundInfo then
			for Name, Value in SoundInfo do
				if Sound[Name] then
					Sound[Name] = Value
				end
			end
		end
	end
end

function Footstepper:_HandleCharacter(Character: Model)
	local HumanoidRootPart = Character:WaitForChild("HumanoidRootPart")
	local Humanoid = Character:FindFirstChildOfClass("Humanoid")

	if Humanoid and HumanoidRootPart then
		local Sounds = self:_SetUpSounds(HumanoidRootPart)

		local DefaultSound = HumanoidRootPart:WaitForChild("Running")
		if DefaultSound then
			DefaultSound:Destroy()
		end

		local FloorMaterial: Enum.Material = Enum.Material.Plastic
		local WalkSpeed: number = 0
		local LastFloorMaterial: Enum.Material = Enum.Material.Plastic
		local LastWalkSpeed: number = 0

		Humanoid.Running:Connect(function(Speed: number)
			WalkSpeed = Speed

			if WalkSpeed ~= LastWalkSpeed then
				self:_UpdatePlayingSound(Sounds, WalkSpeed, FloorMaterial)
			end
			LastWalkSpeed = WalkSpeed
		end)
		Humanoid:GetPropertyChangedSignal("FloorMaterial"):Connect(function()
			FloorMaterial = Humanoid.FloorMaterial

			if FloorMaterial ~= LastFloorMaterial then
				self:_UpdatePlayingSound(Sounds, WalkSpeed, FloorMaterial)
			end
			LastFloorMaterial = FloorMaterial
		end)
	end
end

function Footstepper:_UpdatePlayingSound(Sounds: Attachment, WalkSpeed: number, FloorMaterial: Enum.Material)
	for _, Sound in ipairs(Sounds:GetChildren()) do
		Sound.Playing = false
		Sound.Looped = false
	end

	if WalkSpeed >= WalkSpeed / 2 then
		local Sound = Sounds:FindFirstChild(string.split(tostring(FloorMaterial), "Enum.Material.")[2])
		if Sound == nil and table.find(BLACKLISTEED_MATERIALS, FloorMaterial) == nil then
			Sound = Sounds:FindFirstChild("Plastic")
		end

		if Sound then
			Sound.PlaybackSpeed = WalkSpeed / 13
			Sound.Playing = true
			Sound.Looped = true
		end
	end
end

function Footstepper:_SetUpSounds(HumanoidRootPart: BasePart)
	local SoundGroup = Instance.new("SoundGroup")
	SoundGroup.Name = "FootstepSounds"
	SoundGroup.Volume = self.BaseVolume

	local Sounds = Instance.new("Attachment")
	Sounds.Name = "Sounds"
	Sounds.Parent = HumanoidRootPart

	for Name, _ in pairs(DefaultSounds) do
		local Sound = Instance.new("Sound")
		Sound.Name = Name
		Sound.Looped = true
		Sound.RollOffMaxDistance = 50
		Sound.RollOffMinDistance = 5
		Sound.SoundGroup = SoundGroup
		Sound.Parent = Sounds
	end

	SoundGroup.Parent = HumanoidRootPart

	self:UpdateSounds(Sounds:GetChildren(), DefaultSounds)

	return Sounds
end

function Footstepper:_HandlePlayer(Player: Player)
	Player.CharacterAdded:Connect(function(Character)
		self:_HandleCharacter(Character)
	end)

	if Player.Character then
		self:_HandleCharacter(Player.Character)
	end
end

function Footstepper:Start()
	Players.PlayerAdded:Connect(function(Player)
		self:_HandlePlayer(Player)
	end)

	for _, Player in ipairs(Players:GetPlayers()) do
		self:_HandlePlayer(Player)
	end
end

return Footstepper
