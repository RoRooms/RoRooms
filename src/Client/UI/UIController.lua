local RoRooms = script.Parent.Parent.Parent.Parent
local Knit = require(RoRooms.Parent.Knit)
local Fusion = require(RoRooms.Parent.Fusion)
local States = require(RoRooms.SourceCode.Client.UI.States)
local OnyxUI = require(RoRooms.Parent.OnyxUI)
local OnyxUITheme = require(script.Parent.OnyxUITheme)

local Themer = OnyxUI.Themer

local DEFAULT_UIS = { "Topbar", "PromptHUD" }

local UIController = {
	Name = "UIController",
}

function UIController:MountUI(Component)
	Themer.Theme:is(OnyxUITheme):during(function()
		Component {
			Parent = self.RoRoomsUI,
		}
	end)
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
	self.Scope = Fusion.scoped(Fusion)

	self.RoRoomsUI = self.Scope:New "ScreenGui" {
		Name = "RoRoomsUI",
		Parent = Knit.Player:WaitForChild("PlayerGui"),
		ResetOnSpawn = false,
	}

	self.XPMultiplierDropdownIcons = {}
end

return UIController
