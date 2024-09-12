local EmoteCategoriesSidebar = require(script.Parent.EmoteCategoriesSidebar)

return {
	story = function(Parent: GuiObject, _Props: { [string]: any })
		local Instance = Scope:EmoteCategoriesSidebar {
			Parent = Parent,
			Size = UDim2.fromOffset(0, 200),
		}

		return function()
			Instance:Destroy()
		end
	end,
}
