return function(Array: { [number]: any }, StartingPage: number, PageCount: number, PageSize: number)
	local Pages = {}

	for CurrentPage = StartingPage, (StartingPage + PageCount) do
		local Page = {}

		local StartingIndex = (CurrentPage * PageSize) + 1
		for Index = StartingIndex, (StartingIndex + (PageCount * PageSize)) do
			local Entry = Array[Index]
			if Entry then
				table.insert(Page, Entry)
			end
		end

		if #Page >= 1 then
			table.insert(Pages, Page)
		else
			break
		end
	end

	return Pages
end
