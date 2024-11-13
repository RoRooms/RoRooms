local Players = game:GetService("Players")

local Rorooms = script.Parent.Parent.Parent.Parent
local Fusion = require(Rorooms.Parent.Fusion)
local States = require(Rorooms.SourceCode.Client.UI.States)
local OnyxUI = require(Rorooms.Parent.OnyxUI)
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
			Parent = self.RoroomsUI,
		})
	end)
end

function UIController:KnitStart()
	States:Start()

	for _, GuiName in ipairs(DEFAULT_UIS) do
		local GuiModule = Rorooms.SourceCode.Client.UI.ScreenGuis:FindFirstChild(GuiName)
		if GuiModule then
			local Gui = require(GuiModule)
			self:MountUI(Gui)
		end
	end
end

UIController.RoroomsUI = UIController.Scope:New "ScreenGui" {
	Name = "RoroomsUI",
	Parent = Players.LocalPlayer:WaitForChild("PlayerGui"),
	ResetOnSpawn = false,
}

return UIController
