local SharedData = require(script.Parent)

return function(Module)
	for Feature, ModuleNames in pairs(SharedData.FeatureModulesMap) do
		if table.find(ModuleNames, Module.Name) then
			return Feature
		end
	end

	return nil
end
