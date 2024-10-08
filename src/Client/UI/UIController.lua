local Players = game:GetService("Players")

local RoRooms = script.Parent.Parent.Parent.Parent
local Fusion = require(RoRooms.Parent.Fusion)
local States = require(RoRooms.SourceCode.Client.UI.States)
local OnyxUI = require(RoRooms.Parent.OnyxUI)
local OnyxUITheme = require(script.Parent.OnyxUITheme)

local Themer = OnyxUI.Themer

local DEFAULT_UIS = { "TopbarHUD", "PromptHUD" }

local UIController = {
	Name = "UIController",

	Scope = Fusion.scoped(Fusion),
	XPMultiplierDropdownIcons = {},
}

function UIController:MountUI(Component)
	Themer.Theme:is(OnyxUITheme):during(function()
		Component(self.Scope, {
			Parent = self.RoRoomsUI,
		})
	end)
end

function UIController:KnitStart()
	States:Start()

	for _, GuiName in ipairs(DEFAULT_UIS) do
		local GuiModule = RoRooms.SourceCode.Client.UI.ScreenGuis:FindFirstChild(GuiName)
		if GuiModule then
			local Gui = require(GuiModule)
			self:MountUI(Gui)
		end
	end
end

UIController.RoRoomsUI = UIController.Scope:New "ScreenGui" {
	Name = "RoRoomsUI",
	Parent = Players.LocalPlayer:WaitForChild("PlayerGui"),
	ResetOnSpawn = false,
}

return UIController
