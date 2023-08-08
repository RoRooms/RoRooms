local function DeepCopyTable(Table)
	local Copy = {}
	for Key, Value in pairs(Table) do
		if type(Value) == "table" then
			Copy[Key] = DeepCopyTable(Value)
		else
			Copy[Key] = Value
		end
	end
	return Copy
end

local function ReconcileTable(Target, Template)
	for Key, Value in pairs(Template) do
		if type(Key) == "string" then
			if Target[Key] == nil then
				if type(Value) == "table" then
					Target[Key] = DeepCopyTable(Value)
				else
					Target[Key] = Value
				end
			elseif type(Target[Key]) == "table" and type(Value) == "table" then
				ReconcileTable(Target[Key], Value)
			end
		end
	end
end

return ReconcileTable