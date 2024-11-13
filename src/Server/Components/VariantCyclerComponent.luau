local Rorooms = script.Parent.Parent.Parent.Parent
local Component = require(Rorooms.Parent.Component)

local VariantCyclerComponent = Component.new {
	Tag = `RR_{string.gsub(script.Name, "Component$", "")}`,

	Variants = {},
}

function VariantCyclerComponent:CycleVariant()
	local ActiveVariant = self.Instance:GetAttribute("RR_ActiveVariant") or 0
	if ActiveVariant == #self.Variants then
		ActiveVariant = 0
	end
	ActiveVariant += 1

	self:SetVariant(ActiveVariant)
end

function VariantCyclerComponent:SetVariant(VariantId: number?)
	if VariantId ~= nil then
		local Variant = self.Variants[VariantId]
		if Variant then
			self:_HideVariants()
			Variant.Parent = self.Instance
		end
	end

	self.Instance:SetAttribute("RR_ActiveVariant", VariantId)
end

function VariantCyclerComponent:_HideVariants()
	for _, Variant in ipairs(self.Variants) do
		Variant.Parent = nil
	end
end

function VariantCyclerComponent:_RegisterVariants()
	local Variants: { Instance } = {}

	for Count = 1, #self.Instance:GetChildren() do
		local Variant = self.Instance:FindFirstChild(Count)
		if Variant then
			table.insert(Variants, Variant)
		end
	end

	table.sort(Variants, function(VariantA, VariantB)
		return tonumber(VariantA.Name) < tonumber(VariantB.Name)
	end)

	self.Variants = Variants
	return Variants
end

function VariantCyclerComponent:_GetProximityPrompt(): ProximityPrompt
	local ProximityPrompt = self.Instance:FindFirstChild("RR_VariantCyclePrompt")
	if not ProximityPrompt then
		local Properties = {
			Name = "RR_VariantCyclePrompt",
			Parent = self.Instance,
			ActionText = "",
			RequiresLineOfSight = false,
			MaxActivationDistance = 7.5,
		}
		ProximityPrompt = Instance.new("ProximityPrompt")

		for Name, Value in pairs(Properties) do
			ProximityPrompt[Name] = Value
		end
	end

	return ProximityPrompt
end

function VariantCyclerComponent:Start()
	self:SetVariant(1)

	local Prompt = self:_GetProximityPrompt()
	Prompt.Triggered:Connect(function()
		self:CycleVariant()
	end)
end

function VariantCyclerComponent:Construct()
	if not self.Instance:IsA("BasePart") then
		warn(`{self.Tag} must be a BasePart object`, self.Instance)
		return
	end

	local Variants = self:_RegisterVariants()
	if #Variants == 0 then
		warn(`Child variants are incorrectly set up for {self.Tag}`, self.Instance)
	end
end

function VariantCyclerComponent:Stop()
	for _, Variant in ipairs(self.Variants) do
		Variant:Destroy()
	end
end

return VariantCyclerComponent
