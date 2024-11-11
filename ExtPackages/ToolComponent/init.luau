local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

export type Holder = {
	Character: Model | nil,
	Humanoid: Humanoid | nil,
	Animator: Animator | nil,
	Player: Player | nil,
}
export type ToolComponent = {
	Tag: string,
	Instance: Tool,

	Holder: Holder?,
	Handle: BasePart?,

	ToolActivate: (table, Holder) -> ()?,
	ToolDeactivate: (table, Holder) -> ()?,
	ToolEquip: (table, Holder) -> ()?,
	ToolUnequip: (table, Holder) -> ()?,
}

local ToolComponent = {}

function ToolComponent._HandleActivate(Component: ToolComponent)
	if RunService:IsServer() or (Component.Holder.Player == Players.LocalPlayer) then
		if Component.ToolActivate then
			Component:ToolActivate(Component.Holder)
		end
	end
end

function ToolComponent._HandleDeactivate(Component: ToolComponent)
	if RunService:IsServer() or (Component.Holder.Player == Players.LocalPlayer) then
		if Component.ToolDeactivate then
			Component:ToolDeactivate(Component.Holder)
		end
	end
end

function ToolComponent._HandleEquip(Component: ToolComponent)
	local Character = Component.Instance:FindFirstAncestorOfClass("Model")
	if Character then
		local Humanoid = Character:FindFirstChildOfClass("Humanoid")
		if Humanoid then
			Component.Holder = {
				Character = Character,
				Humanoid = Humanoid,
				Animator = Humanoid:FindFirstChildOfClass("Animator"),
				Player = Players:GetPlayerFromCharacter(Character),
			}

			if RunService:IsServer() or (Component.Holder.Player == Players.LocalPlayer) then
				if Component.ToolEquip then
					Component:ToolEquip(Component.Holder)
				end
			end
		end
	end
end

function ToolComponent._HandleUnequip(Component: ToolComponent)
	if Component.Holder then
		local OldHolder = table.clone(Component.Holder)
		Component.Holder = nil

		if Component.ToolUnequip then
			Component:ToolUnequip(OldHolder)
		end
	end
end

function ToolComponent.Constructing(Component: ToolComponent)
	Component.Handle = Component.Instance:FindFirstChild("Handle")

	Component.Instance.Activated:Connect(function()
		ToolComponent._HandleActivate(Component)
	end)
	Component.Instance.Deactivated:Connect(function()
		ToolComponent._HandleDeactivate(Component)
	end)

	Component.Instance.Equipped:Connect(function()
		ToolComponent._HandleEquip(Component)
	end)
	Component.Instance.Unequipped:Connect(function()
		ToolComponent._HandleUnequip(Component)
	end)
end

function ToolComponent.ShouldConstruct(Component: ToolComponent)
	if not Component.Instance:IsA("Tool") then
		warn(Component.Tag, "has the ToolComponent extension but is not a Tool.")
		return false
	end

	return true
end

return ToolComponent
