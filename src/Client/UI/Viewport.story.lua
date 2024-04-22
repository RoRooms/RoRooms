local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent.Parent)

local Client = RoRooms.Client

local Topbar = require(Client.UI.States.Topbar)

local Viewport = function(Props)
	local ReturnedGuis = {}

	for _, GuiModule in ipairs(script.Parent.ScreenGuis:GetChildren()) do
		local GuiNameSplit = string.split(GuiModule.Name, ".")
		local FileSuffix = GuiNameSplit[2]

		if GuiModule:IsA("ModuleScript") and not FileSuffix then
			local Gui = require(GuiModule)
			table.insert(
				ReturnedGuis,
				Gui {
					Name = GuiModule.Name,
					Parent = Props.Target,
				}
			)
		end
	end

	return ReturnedGuis
end

return function(Target)
	local ViewportGuis = Viewport {
		Target = Target,
	}

	Topbar:AddDefaultButtons()

	return function()
		for _, Gui in ipairs(ViewportGuis) do
			Gui:Destroy()
		end
	end
end
