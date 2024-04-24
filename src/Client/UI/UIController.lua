local RoRooms = require(script.Parent.Parent.Parent.Parent)
local StarterGui = game:GetService("StarterGui")

local Shared = RoRooms.Shared
local Client = RoRooms.Client
local Packages = RoRooms.Packages

local Knit = require(Packages.Knit)
local Fusion = require(Shared.ExtPackages.OnyxUI.Packages.Fusion)
local States = require(Client.UI.States)
local NeoHotbar = require(Packages.NeoHotbar)
local Signal = require(Packages.Signal)
local OnyxUI = require(Shared.ExtPackages.OnyxUI)
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

function UIController:_StartACM()
	local SelectionIndicator = New "Part" {
		Name = "Indicator",
		Locked = true,
		CanCollide = false,
		Anchored = true,
		Color = Color3.fromRGB(170, 170, 170),
		Material = Enum.Material.Neon,
		Size = Vector3.new(0.45, 0.45, 0.45),
	}
	StarterGui:SetCore("AvatarContextMenuEnabled", true)
	StarterGui:SetCore("AvatarContextMenuTheme", {
		BackgroundTransparency = 0.015,
		BackgroundColor = Color3.fromRGB(26, 26, 26),
		NameTagColor = Color3.fromRGB(26, 26, 26),
		ButtonFrameColor = Color3.fromRGB(26, 26, 26),
		ButtonColor = Color3.fromRGB(26, 26, 26),
		ButtonHoverColor = Color3.fromRGB(61, 61, 61),
		SelectedCharacterIndicator = SelectionIndicator,
	})
end

function UIController:KnitStart()
	States:Start()

	Themer:Set(Theme)

	for _, GuiName in ipairs(DEFAULT_UIS) do
		local GuiModule = Client.UI.ScreenGuis:FindFirstChild(GuiName)
		if GuiModule then
			local Gui = require(GuiModule)
			self:MountUI(Gui {})
		end
	end

	NeoHotbar:Start()
	self.NeoHotbarOnStart:Fire()

	self:_StartACM()
end

function UIController:KnitInit()
	self.RoRoomsUI = New "ScreenGui" {
		Name = "RoRoomsUI",
		Parent = Knit.Player:WaitForChild("PlayerGui"),
		ResetOnSpawn = false,
	}

	self.NeoHotbarOnStart = Signal.new()

	self.XPMultiplierDropdownIcons = {}
end

return UIController
