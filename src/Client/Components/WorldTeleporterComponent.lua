local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local RoRooms = require(script.Parent.Parent.Parent.Parent)
local Future = require(script.Parent.Parent.Parent.Parent.Parent.Future)
local Component = require(RoRooms.Packages.Component)
local States = require(RoRooms.Client.UI.States)
local AttributeValue = require(RoRooms.Shared.ExtPackages.AttributeValue)
local OnyxUI = require(RoRooms.Packages.OnyxUI)
local Fusion = require(RoRooms.Packages.Fusion)
local Prompts = require(RoRooms.Client.UI.States.Prompts)

local WorldTeleporterComponent = Component.new {
	Tag = "RR_WorldTeleporter",
}

function WorldTeleporterComponent:_PromptTeleport()
	local PlaceId = Use(self.PlaceId)
	local PlaceInfo = Use(self.PlaceInfo)

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
	Scope:Observer(self.PlaceId):onChange(function()
		self:_UpdatePlaceInfo(Use(self.PlaceId))
	end)
	self:_UpdatePlaceInfo(Use(self.PlaceId))

	self.Instance.Touched:Connect(function(TouchedPart: BasePart)
		local Character = TouchedPart:FindFirstAncestorOfClass("Model")
		if Character then
			local Player = Players:GetPlayerFromCharacter(Character)
			if Player == Players.LocalPlayer then
				if #Use(States.Prompts) == 0 then
					self:_PromptTeleport(Use(self.PlaceId), Use(self.PlaceInfo))
				end
			end
		end
	end)
end

function WorldTeleporterComponent:Construct()
	self.PlaceId = AttributeValue(self.Instance, "RR_PlaceId")
	self.PlaceInfo = Scope:Value({})

	if not self.Instance:IsA("BasePart") then
		warn("WorldTeleporter must be a BasePart object", self.Instance)
		return
	end
	if not Use(self.PlaceId) then
		warn("No RR_PlaceId attribute defined for WorldTeleporter", self.Instance)
		return
	end
end

return WorldTeleporterComponent
