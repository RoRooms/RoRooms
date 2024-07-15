local RoRooms = require(script.Parent.Parent.Parent.Parent)
local Knit = require(RoRooms.Packages.Knit)
local OnyxUI = require(RoRooms.Packages.OnyxUI)
local Fusion = require(OnyxUI.Parent.Fusion)
local States = require(RoRooms.Client.UI.States)
local Themer = require(OnyxUI.Utils.Themer)
local Theme = require(script.Parent.OnyxUITheme)

local New = Fusion.New

local Base = require(OnyxUI.Components.Base)

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
		local GuiModule = RoRooms.Client.UI.ScreenGuis:FindFirstChild(GuiName)
		if GuiModule then
			local Gui = require(GuiModule)
			self:MountUI(Gui {})
		end
	end
end

function UIController:KnitInit()
	self.RoRoomsUI = New "ScreenGui" {
		Name = "RoRoomsUI",
		Parent = Knit.Player:WaitForChild("PlayerGui"),
		ResetOnSpawn = false,
	}

	self.XPMultiplierDropdownIcons = {}

	Themer:Set(Theme)
end

return UIController
