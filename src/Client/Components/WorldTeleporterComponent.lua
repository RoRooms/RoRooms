local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local RoRooms = script.Parent.Parent.Parent.Parent
local Future = require(script.Parent.Parent.Parent.Parent.Parent.Future)
local Component = require(RoRooms.Parent.Component)
local States = require(RoRooms.SourceCode.Client.UI.States)
local AttributeValue = require(RoRooms.SourceCode.Shared.ExtPackages.AttributeValue)
local Fusion = require(RoRooms.Parent.Fusion)
local Prompts = require(RoRooms.SourceCode.Client.UI.States.Prompts)

local Peek = Fusion.peek

local WorldTeleporterComponent = Component.new {
	Tag = "RR_WorldTeleporter",
}

function WorldTeleporterComponent:_PromptTeleport()
	local PlaceId = Peek(self.PlaceId)
	local PlaceInfo = Peek(self.PlaceInfo)

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
	self.Scope:Observer(self.PlaceId):onChange(function()
		self:_UpdatePlaceInfo(Peek(self.PlaceId))
	end)
	self:_UpdatePlaceInfo(Peek(self.PlaceId))

	self.Instance.Touched:Connect(function(TouchedPart: BasePart)
		local Character = TouchedPart:FindFirstAncestorOfClass("Model")
		if Character then
			local Player = Players:GetPlayerFromCharacter(Character)
			if Player == Players.LocalPlayer then
				if #Peek(States.Prompts) == 0 then
					self:_PromptTeleport(Peek(self.PlaceId), Peek(self.PlaceInfo))
				end
			end
		end
	end)
end

function WorldTeleporterComponent:Construct()
	self.Scope = Fusion.scoped(Fusion, {
		AttributeValue = AttributeValue,
	})

	self.PlaceId = self.Scope:AttributeValue(self.Instance, "RR_PlaceId")
	self.PlaceInfo = self.Scope:Value({})

	if not self.Instance:IsA("BasePart") then
		warn("WorldTeleporter must be a BasePart object", self.Instance)
		return
	end
	if not Peek(self.PlaceId) then
		warn("No RR_PlaceId attribute defined for WorldTeleporter", self.Instance)
		return
	end
end

return WorldTeleporterComponent
