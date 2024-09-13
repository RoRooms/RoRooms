local RoRooms = script.Parent.Parent.Parent.Parent.Parent
local Components = require(RoRooms.SourceCode.Client.UI.Components)
local Fusion = require(RoRooms.Parent.Fusion)

return {
	story = function(Parent: GuiObject, _Props: { [string]: any })
		local Scope = Fusion.scoped(Fusion, Components)

		local Instance = Scope:EmoteCategoriesSidebar {
			Parent = Parent,
			Size = UDim2.fromOffset(0, 200),
		}

		return function()
			Instance:Destroy()
		end
	end,
}
