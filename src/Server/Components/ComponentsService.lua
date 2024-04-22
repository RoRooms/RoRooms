local ComponentsService = {
	Name = script.Name,
}

function ComponentsService:KnitStart()
	for _, Module in ipairs(script.Parent:GetChildren()) do
		if Module:IsA("ModuleScript") and Module ~= script then
			require(Module)
		end
	end
end

function ComponentsService:KnitInit() end

return ComponentsService
