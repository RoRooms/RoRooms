local GuiService = game:GetService("GuiService")
local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent.Parent.Parent)

local Shared = RoRooms.Shared

local OnyxUI = require(Shared.ExtPackages.OnyxUI)
local Fusion = require(OnyxUI._Packages.Fusion)
local States = require(script.Parent)

local Computed = Fusion.Computed
local Observer = Fusion.Observer

local CoreGui = {
	IsUnibarOpen = Computed(function()
		return States.TopbarInset:get().Min.X > 250
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

	Observer(self.IsUnibarOpen):onChange(function()
		States.TopbarVisible:set(not CoreGui.IsUnibarOpen:get())
		if CoreGui.IsUnibarOpen:get() then
			States.CurrentMenu:set(nil)
		end
	end)

	Observer(States.RobloxMenuOpen):onChange(function()
		States.TopbarVisible:set(not States.RobloxMenuOpen:get())
		if States.RobloxMenuOpen:get() then
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
