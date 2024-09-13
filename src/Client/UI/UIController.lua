local RoRooms = script.Parent.Parent.Parent.Parent
local Knit = require(RoRooms.Parent.Knit)
local Fusion = require(RoRooms.Parent.Fusion)
local States = require(RoRooms.SourceCode.Client.UI.States)
local Theme = require(script.Parent.OnyxUITheme)

local DEFAULT_UIS = { "Topbar", "PromptHUD" }

local UIController = {
	Name = "UIController",
}

function UIController:MountUI(UI: Instance)
	UI.Parent = self.RoRoomsUI
end

function UIController:KnitStart()
	States:Start()

	for _, GuiName in ipairs(DEFAULT_UIS) do
		local GuiModule = RoRooms.SourceCode.Client.UI.ScreenGuis:FindFirstChild(GuiName)
		if GuiModule then
			local Gui = require(GuiModule)
			self:MountUI(Gui {})
		end
	end
end

function UIController:KnitInit()
	self.RoRoomsUI = Scope:New "ScreenGui" {
		Name = "RoRoomsUI",
		Parent = Knit.Player:WaitForChild("PlayerGui"),
		ResetOnSpawn = false,
	}

	self.XPMultiplierDropdownIcons = {}

	Themer:Set(Theme)
end

return UIController
