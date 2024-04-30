local RoRooms = require(script.Parent.Parent.Parent.Parent)

local Client = RoRooms.Client
local Packages = RoRooms.Packages

local Knit = require(Packages.Knit)
local OnyxUI = require(RoRooms.Packages.OnyxUI)
local Fusion = require(OnyxUI.Packages.Fusion)
local States = require(Client.UI.States)
local Themer = require(OnyxUI.Utils.Themer)
local Theme = require(script.Parent.OnyxUITheme)

local New = Fusion.New

local DEFAULT_UIS = { "Topbar", "PromptPopup" }

local UIController = {
	Name = "UIController",
}

function UIController:MountUI(UI: Instance)
	UI.Parent = self.RoRoomsUI
end

function UIController:KnitStart()
	States:Start()

	for _, GuiName in ipairs(DEFAULT_UIS) do
		local GuiModule = Client.UI.ScreenGuis:FindFirstChild(GuiName)
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
