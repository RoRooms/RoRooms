local GuiService = game:GetService("GuiService")
local RoRooms = script.Parent.Parent.Parent.Parent.Parent.Parent.Parent

local Fusion = require(RoRooms.Parent.Fusion)
local States = require(script.Parent)
local Peek = Fusion.peek

local CoreGui = {
	IsUnibarOpen = Scope:Computed(function(Use)
		return Use(States.TopbarInset).Min.X > 250
	end),
}

function CoreGui:Start()
	States.TopbarInset:set(GuiService.TopbarInset)

	GuiService:GetPropertyChangedSignal("TopbarInset"):Connect(function()
		States.TopbarInset:set(GuiService.TopbarInset)
	end)

	GuiService:GetPropertyChangedSignal("MenuIsOpen"):Connect(function()
		States.RobloxMenuOpen:set(GuiService.MenuIsOpen)
	end)

	Scope:Observer(self.IsUnibarOpen):onChange(function()
		States.TopbarVisible:set(not Peek(CoreGui.IsUnibarOpen))
		if Peek(CoreGui.IsUnibarOpen) then
			States.CurrentMenu:set(nil)
		end
	end)

	Scope:Observer(States.RobloxMenuOpen):onChange(function()
		States.TopbarVisible:set(not Peek(States.RobloxMenuOpen))
		if Peek(States.RobloxMenuOpen) then
			States.CurrentMenu:set(nil)
			States.ItemsMenu.Open:set(false)
		end
	end)

	function UpdatePrefferedTransparency()
		local Transparency = math.clamp(GuiService.PreferredTransparency / 3, 0, 0.2)
		States.PreferredTransparency:set(Transparency)
	end

	UpdatePrefferedTransparency()
	GuiService:GetPropertyChangedSignal("PreferredTransparency"):Connect(function()
		UpdatePrefferedTransparency()
	end)
end

return CoreGui
