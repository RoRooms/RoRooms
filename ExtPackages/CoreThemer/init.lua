local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local TextChatService = game:GetService("TextChatService")

local MouseLockController = Players.LocalPlayer.PlayerScripts
	:WaitForChild("PlayerModule")
	:WaitForChild("CameraModule")
	:WaitForChild("MouseLockController")

local CHAT_WINDOW_THEME = {
	BackgroundColor3 = Color3.fromRGB(0, 0, 0),
	BackgroundTransparency = 0.3,
	TextSize = 15,
	TextStrokeTransparency = 0.6,
}
local CHAT_WINDOW_INPUT_THEME = {
	BackgroundTransparency = 1,
	TextColor3 = Color3.fromRGB(205, 205, 205),
	TextSize = 15,
	TextStrokeTransparency = 1,
}
local BUBBLE_CHAT_THEME = {
	BackgroundColor3 = Color3.fromRGB(20, 20, 20),
	BackgroundTransparency = 0.2,
	TextColor3 = Color3.fromRGB(205, 205, 205),
	TextSize = 17,
}
local SHIFT_LOCK_KEYS = "LeftControl"
local AVATAR_CONTEXT_MENU_THEME = {
	BackgroundTransparency = 1,
	BackgroundImage = "rbxassetid://16819084929",
	BackgroundImageSliceCenter = Rect.new(12, 12, 12, 12),
	BackgroundImageTransparency = 0.3,
	NameTagColor = Color3.fromRGB(20, 20, 20),
	ButtonFrameTransparency = 1,
	ButtonColor = Color3.fromRGB(255, 255, 255),
	ButtonTransparency = 1,
	ButtonHoverTransparency = 0.9,
}
local SELECTION_INDICATOR_OPTIONS = {
	Name = "Indicator",
	Locked = true,
	CanCollide = false,
	Anchored = true,
	Color = Color3.fromRGB(170, 170, 170),
	Material = Enum.Material.Neon,
	Size = Vector3.new(0.45, 0.45, 0.45),
}

type AvatarContextMenuButton = {}

local CoreThemer = {
	_AvatarSelectionHighlight = Instance.new("Highlight"),
	_AvatarSelectionConnection = nil,
}

function CoreThemer:SetDefaults()
	self:SetChatWindowTheme()
	self:SetChatWindowInputTheme()
	self:SetBubbleChatTheme()
	self:SetShiftLockKeys()
	self:SetAvatarContextMenuTheme()
end

function CoreThemer:SetAvatarContextMenuEnabled(Enabled: boolean)
	if Enabled == nil then
		Enabled = true
	end

	self:CallCore("SetCore", "AvatarContextMenuEnabled", Enabled)

	if Enabled then
		self:_StartAvatarSelectionHandler()
	else
		self:_StopAvatarSelectionHandler()
	end
end

function CoreThemer:SetAvatarContextMenuTheme(Options: table?)
	if Options == nil then
		Options = AVATAR_CONTEXT_MENU_THEME

		local SelectionIndicator = Instance.new("Part")
		self:_SetProperties(SelectionIndicator, SELECTION_INDICATOR_OPTIONS)
		Options.SelectedCharacterIndicator = SelectionIndicator
	end

	self:CallCore("SetCore", "AvatarContextMenuTheme", Options)
end

function CoreThemer:SetShiftLockKeys(Keys: string?)
	if Keys == nil then
		Keys = SHIFT_LOCK_KEYS
	end

	local BoundKeys = MouseLockController:FindFirstChild("BoundKeys")
	if BoundKeys then
		BoundKeys.Value = Keys
	else
		BoundKeys = Instance.new("StringValue")
		BoundKeys.Name = "BoundKeys"
		BoundKeys.Value = Keys
		BoundKeys.Parent = MouseLockController
	end
end

function CoreThemer:SetChatWindowTheme(Options: table?)
	if Options == nil then
		Options = CHAT_WINDOW_THEME
	end

	self:_SetProperties(TextChatService.ChatWindowConfiguration, Options)
end

function CoreThemer:SetChatWindowInputTheme(Options: table?)
	if Options == nil then
		Options = CHAT_WINDOW_INPUT_THEME
	end

	self:_SetProperties(TextChatService.ChatInputBarConfiguration, Options)
end

function CoreThemer:SetBubbleChatTheme(Options: table?)
	if Options == nil then
		Options = BUBBLE_CHAT_THEME
	end

	self:_SetProperties(TextChatService.BubbleChatConfiguration, Options)

	if Options == nil then
		local UICorner = TextChatService.BubbleChatConfiguration:FindFirstChild("UICorner")
		if UICorner then
			UICorner.CornerRadius = UDim.new(0, 16)
		end
	end
end

function CoreThemer:CallCore(Method, ...)
	local Result = {}

	for _ = 1, 8 do
		Result = { pcall(StarterGui[Method], StarterGui, ...) }
		if Result[1] then
			break
		end
		task.wait()
	end

	return unpack(Result)
end

function CoreThemer:_StartAvatarSelectionHandler()
	self:_StopAvatarSelectionHandler()

	local Mouse = Players.LocalPlayer:GetMouse()
	self._AvatarSelectionConnection = Mouse.Move:Connect(function()
		self._AvatarSelectionHighlight.Adornee = nil

		local Target = Mouse.Target
		if Target then
			local Character = Target:FindFirstAncestorOfClass("Model")
			if Character then
				local Player = Players:GetPlayerFromCharacter(Character)
				if Player then
					self._AvatarSelectionHighlight.Adornee = Character
				end
			end
		end
	end)
end

function CoreThemer:_StopAvatarSelectionHandler()
	if self._AvatarSelectionConnection then
		self._AvatarSelectionConnection:Disconnect()
		self._AvatarSelectionConnection = nil
	end

	self._AvatarSelectionHighlight.Adornee = nil
end

function CoreThemer:_SetProperties(Instance: Instance, Properties: table)
	for Property, Value in pairs(Properties) do
		Instance[Property] = Value
	end
end

function CoreThemer:_Initialize()
	self._AvatarSelectionHighlight.Parent = Players.LocalPlayer.PlayerGui
	self._AvatarSelectionHighlight.FillTransparency = 1
	self._AvatarSelectionHighlight.OutlineTransparency = 0.1
	self._AvatarSelectionHighlight.DepthMode = Enum.HighlightDepthMode.Occluded
end

CoreThemer:_Initialize()

return CoreThemer
