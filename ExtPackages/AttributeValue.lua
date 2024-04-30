local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent.Parent)

local OnyxUI = require(RoRooms.Packages.OnyxUI)
local Fusion = require(OnyxUI.Packages.Fusion)

local Value = Fusion.Value

return function(Instance: Instance, AttributeName: string, DefaultValue: any?)
	if Instance:GetAttribute(AttributeName) == nil then
		Instance:SetAttribute(AttributeName, DefaultValue)
	end

	local AttributeValue = Value(Instance:GetAttribute(AttributeName))

	Instance:GetAttributeChangedSignal(AttributeName):Connect(function()
		AttributeValue:set(Instance:GetAttribute(AttributeName))
	end)

	return AttributeValue
end
