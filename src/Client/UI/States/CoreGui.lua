local GuiService = game:GetService("GuiService")

local RoRooms = script.Parent.Parent.Parent.Parent.Parent
local Fusion = require(RoRooms.Parent.Fusion)
local States = require(script.Parent)
local Peek = Fusion.peek

local CoreGui = {
	Scope = Fusion.scoped(Fusion),
}

CoreGui.IsUnibarOpen = CoreGui.Scope:Computed(function(Use)
	return Use(States.CoreGui.TopbarInset).Min.X > 250
end)

function CoreGui:Start()
	States.CoreGui.TopbarInset:set(GuiService.TopbarInset)

	GuiService:GetPropertyChangedSignal("TopbarInset"):Connect(function()
		States.CoreGui.TopbarInset:set(GuiService.TopbarInset)
	end)

	GuiService:GetPropertyChangedSignal("MenuIsOpen"):Connect(function()
		States.CoreGui.RobloxMenuOpen:set(GuiService.MenuIsOpen)
	end)

	self.Scope:Observer(self.IsUnibarOpen):onChange(function()
		States.Topbar.Visible:set(not Peek(CoreGui.IsUnibarOpen))
		if Peek(CoreGui.IsUnibarOpen) then
			States.Menus.CurrentMenu:set(nil)
		end
	end)

	self.Scope:Observer(States.CoreGui.RobloxMenuOpen):onChange(function()
		States.Topbar.Visible:set(not Peek(States.CoreGui.RobloxMenuOpen))
		if Peek(States.CoreGui.RobloxMenuOpen) then
			States.Menus.CurrentMenu:set(nil)
			States.Menus.ItemsMenu.Open:set(false)
		end
	end)

	local function UpdatePrefferedTransparency()
		local Transparency = math.clamp(GuiService.PreferredTransparency / 3, 0, 0.2)
		States.CoreGui.PreferredTransparency:set(Transparency)
	end

	UpdatePrefferedTransparency()
	GuiService:GetPropertyChangedSignal("PreferredTransparency"):Connect(function()
		UpdatePrefferedTransparency()
	end)
end

return CoreGui
