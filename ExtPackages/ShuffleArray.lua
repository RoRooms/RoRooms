return function(array)
	local n = #array
	for i = 1, n - 1 do
		local j = math.random(i, n)
		array[i], array[j] = array[j], array[i]
	end
	return array
end
