local function DeepCopy(Table: { [any]: any })
	local NewTable = {}

	for Key, Value in pairs(Table) do
		if typeof(Value) == "table" then
			NewTable[Key] = DeepCopy(Value)
		else
			NewTable[Key] = Value
		end
	end

	return NewTable
end

return DeepCopy
