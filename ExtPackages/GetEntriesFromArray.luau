local function GetEntriesFromArray(Array: { [number]: any }, Start: number, End: number)
	local Entries = {}

	for Index = Start, End do
		table.insert(Entries, Array[Index])
	end

	return Entries
end

return GetEntriesFromArray
