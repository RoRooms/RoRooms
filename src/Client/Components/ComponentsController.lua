local ComponentsController = {
	Name = script.Name,
}

function ComponentsController:KnitStart()
	for _, Module in ipairs(script.Parent:GetChildren()) do
		if Module:IsA("ModuleScript") and Module ~= script then
			require(Module)
		end
	end
end

function ComponentsController:KnitInit() end

return ComponentsController
