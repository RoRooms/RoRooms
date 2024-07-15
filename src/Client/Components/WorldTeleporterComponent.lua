local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local RoRooms = require(script.Parent.Parent.Parent.Parent)
local Future = require(script.Parent.Parent.Parent.Parent.Parent.Future)
local Component = require(RoRooms.Packages.Component)
local States = require(RoRooms.Client.UI.States)
local AttributeValue = require(RoRooms.Shared.ExtPackages.AttributeValue)
local OnyxUI = require(RoRooms.Packages.OnyxUI)
local Fusion = require(OnyxUI.Parent.Fusion)
local Prompts = require(RoRooms.Client.UI.States.Prompts)

local Value = Fusion.Value
local Observer = Fusion.Observer

local WorldTeleporterComponent = Component.new {
	Tag = "RR_WorldTeleporter",
}

function WorldTeleporterComponent:_PromptTeleport()
	local PlaceId = self.PlaceId:get()
	local PlaceInfo = self.PlaceInfo:get()

	if PlaceId and PlaceInfo then
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
end

function WorldTeleporterComponent:_UpdatePlaceInfo(PlaceId: number)
	Future.Try(function(_PlaceId)
		return MarketplaceService:GetProductInfo(_PlaceId)
	end, PlaceId):After(function(Success, PlaceInfo)
		if Success == true then
			self.PlaceInfo:set(PlaceInfo)
		end
	end)
end

function WorldTeleporterComponent:Start()
	Observer(self.PlaceId):onChange(function()
		self:_UpdatePlaceInfo(self.PlaceId:get())
	end)
	self:_UpdatePlaceInfo(self.PlaceId:get())

	self.Instance.Touched:Connect(function(TouchedPart: BasePart)
		local Character = TouchedPart:FindFirstAncestorOfClass("Model")
		if Character then
			local Player = Players:GetPlayerFromCharacter(Character)
			if Player == Players.LocalPlayer then
				if #States.Prompts:get() == 0 then
					self:_PromptTeleport(self.PlaceId:get(), self.PlaceInfo:get())
				end
			end
		end
	end)
end

function WorldTeleporterComponent:Construct()
	self.PlaceId = AttributeValue(self.Instance, "RR_PlaceId")
	self.PlaceInfo = Value({})

	if not self.Instance:IsA("BasePart") then
		warn("WorldTeleporter must be a BasePart object", self.Instance)
		return
	end
	if not self.PlaceId:get() then
		warn("No RR_PlaceId attribute defined for WorldTeleporter", self.Instance)
		return
	end
end

return WorldTeleporterComponent
