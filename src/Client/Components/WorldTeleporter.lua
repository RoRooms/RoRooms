local RoRooms = require(script.Parent.Parent.Parent.Parent)
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local Client = RoRooms.Client
local Packages = RoRooms.Packages
local Shared = RoRooms.Shared

local Component = require(Packages.Component)
local States = require(Client.UI.States)
local AttributeValue = require(Shared.ExtPackages.AttributeValue)
local NekaUI = require(Shared.ExtPackages.NekaUI)
local Fusion = require(NekaUI.Packages.Fusion)

local Computed = Fusion.Computed

local WorldTeleporter = Component.new {
	Tag = "RR_WorldTeleporter",
}

function WorldTeleporter:PromptTeleport(PlaceId: number, PlaceInfo: table)
	States:PushPrompt({
		Title = "Teleport",
		Text = `Do you want to teleport to world {PlaceInfo.Name}?`,
		Buttons = {
			{
				Primary = false,
				Contents = { "Cancel" },
			},
			{
				Primary = true,
				Contents = { "Teleport" },
				Callback = function()
					States.WorldsService:TeleportToWorld(PlaceId)
				end,
			},
		},
	})
end

function WorldTeleporter:GetPlaceInfo(PlaceId: number)
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

function WorldTeleporter:Start()
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

function WorldTeleporter:Construct()
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

return WorldTeleporter
