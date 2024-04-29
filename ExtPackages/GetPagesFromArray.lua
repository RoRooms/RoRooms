return function(Array: { [number]: any }, StartingPage: number, PageCount: number, PageSize: number)
	local Pages = {}

	for CurrentPage = StartingPage, (StartingPage + PageCount) do
		local Page = {}

		for Index = (CurrentPage * PageSize), ((CurrentPage * PageSize) + (PageCount * PageSize)) do
			local PlaceId = Array[Index]
			if PlaceId then
				table.insert(Page, PlaceId)
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
