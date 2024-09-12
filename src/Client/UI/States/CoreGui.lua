local GuiService = game:GetService("GuiService")
local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent.Parent.Parent)

local OnyxUI = require(RoRooms.Packages.OnyxUI)
local Fusion = require(RoRooms.Packages.Fusion)
local States = require(script.Parent)

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
		States.TopbarVisible:set(not Use(CoreGui.IsUnibarOpen))
		if Use(CoreGui.IsUnibarOpen) then
			States.CurrentMenu:set(nil)
		end
	end)

	Scope:Observer(States.RobloxMenuOpen):onChange(function()
		States.TopbarVisible:set(not Use(States.RobloxMenuOpen))
		if Use(States.RobloxMenuOpen) then
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
