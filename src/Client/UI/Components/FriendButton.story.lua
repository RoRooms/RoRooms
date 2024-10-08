local Component = require(script.Parent[string.split(script.Name, ".")[1]])

return function(Target)
	local Gui = Component {
		Parent = Target,
	}

	return function()
		Gui:Destroy()
	end
end
