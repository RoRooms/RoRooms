local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local RoRooms = require(script.Parent.Parent.Parent.Parent)
local Component = require(RoRooms.Packages.Component)
local States = require(RoRooms.Client.UI.States)
local AttributeValue = require(RoRooms.Shared.ExtPackages.AttributeValue)
local OnyxUI = require(RoRooms.Packages.OnyxUI)
local Fusion = require(OnyxUI.Packages.Fusion)
local Prompts = require(RoRooms.Client.UI.States.Prompts)

local Computed = Fusion.Computed

local WorldTeleporterComponent = Component.new {
	Tag = "RR_WorldTeleporter",
}

function WorldTeleporterComponent:PromptTeleport(PlaceId: number, PlaceInfo: { [any]: any })
	Prompts:PushPrompt({
		Title = "Teleport",
		Text = `Do you want to teleport to world {PlaceInfo.Name}?`,
		Buttons = {
			{
				Contents = { "Cancel" },
				Style = "Outlined",
			},
			{
				Contents = { "Teleport" },
				Style = "Filled",
				Callback = function()
					if States.Services.WorldsService then
						States.Services.WorldsService:TeleportToWorld(PlaceId)
					end
				end,
			},
		},
	})
end

function WorldTeleporterComponent:GetPlaceInfo(PlaceId: number)
	if PlaceId then
		local Success, Result = pcall(function()
			return MarketplaceService:GetProductInfo(self.PlaceId:get())
		end)
		if Success then
			return Result
		else
			warn(Result)
			return {}
		end
	else
		return {}
	end
end

function WorldTeleporterComponent:Start()
	self.Instance.Touched:Connect(function(TouchedPart: BasePart)
		local Character = TouchedPart:FindFirstAncestorOfClass("Model")
		local Player = Players:GetPlayerFromCharacter(Character)
		if Player == Players.LocalPlayer then
			if #States.Prompts:get() == 0 then
				self:PromptTeleport(self.PlaceId:get(), self.PlaceInfo:get())
			end
		end
	end)
end

function WorldTeleporterComponent:Construct()
	self.PlaceId = AttributeValue(self.Instance, "RR_PlaceId")
	self.PlaceInfo = Computed(function()
		if self.PlaceId:get() then
			local Success, Result = pcall(function()
				return MarketplaceService:GetProductInfo(self.PlaceId:get())
			end)
			if Success then
				return Result
			else
				warn(Result)
				return {}
			end
		else
			return {}
		end
	end)

	if not self.Instance:IsA("BasePart") then
		warn("WorldTeleporter must be a BasePart object --", self.Instance)
		return
	end
	if not self.PlaceId:get() then
		warn("No RR_PlaceId attribute defined for WorldTeleporter", self.Instance)
		return
	end
end

return WorldTeleporterComponent
