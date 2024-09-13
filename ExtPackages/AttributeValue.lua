local RoRooms = script.Parent.Parent.Parent.Parent
local Fusion = require(RoRooms.Parent.Fusion)

local InnerScope = Fusion.innerScope

return function(Scope: Fusion.Scope<any>, Instance: Instance, AttributeName: string, DefaultValue: any?)
	local Scope = InnerScope(Scope, Fusion)

	if Instance:GetAttribute(AttributeName) == nil then
		Instance:SetAttribute(AttributeName, DefaultValue)
	end

	local AttributeValue = Scope:Value(Instance:GetAttribute(AttributeName))

	Instance:GetAttributeChangedSignal(AttributeName):Connect(function()
		AttributeValue:set(Instance:GetAttribute(AttributeName))
	end)

	return AttributeValue
end
