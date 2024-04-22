local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent.Parent)

local Shared = RoRooms.Shared

local OnyxUI = require(Shared.ExtPackages.OnyxUI)
local Fusion = require(OnyxUI._Packages.Fusion)

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
