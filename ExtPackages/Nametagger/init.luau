local Players = game:GetService("Players")

local RoRooms = script.Parent.Parent.Parent.Parent
local Nametag = require(script.Nametag)
local Fusion = require(RoRooms.Parent.Fusion)

export type Property = {
	Value: any,
	Image: string?,
}
export type Properties = { Property? }
export type Config = {
	DisplayName: string?,
	Properties: Properties?,
	Color: Color3?,
}

local Nametagger = {
	_CharacterScopes = {},
}

function Nametagger:TagCharacter(Character: Model, Config: Config?)
	local SafeConfig: Config
	if Config ~= nil then
		SafeConfig = Config
	else
		SafeConfig = {}
	end

	if self._CharacterScopes[Character] then
		self._CharacterScopes[Character]:doCleanup()
	end

	local Scope = Fusion.scoped(Fusion, {
		Nametag = Nametag,
	})

	self._CharacterScopes[Character] = Scope

	local Head = Scope:Value()
	local Humanoid = Scope:Value()
	local Player = Players:GetPlayerFromCharacter(Character)

	local function UpdateHead()
		Head:set(Character:FindFirstChild("Head"))
	end
	local function UpdateHumanoid()
		local HumanoidObject = Character:FindFirstChildOfClass("Humanoid")

		if HumanoidObject ~= nil then
			HumanoidObject.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
		end

		Humanoid:set(HumanoidObject)

		if HumanoidObject == nil then
			Scope:doCleanup()
		end
	end

	UpdateHead()
	UpdateHumanoid()

	Character.ChildAdded:Connect(function()
		UpdateHead()
		UpdateHumanoid()
	end)

	Scope:Nametag {
		Character = Character,
		Humanoid = Humanoid,
		Head = Head,
		Player = Player,
		Properties = SafeConfig.Properties,
		DisplayName = SafeConfig.DisplayName,
		Color = SafeConfig.Color,
	}
end

return Nametagger
