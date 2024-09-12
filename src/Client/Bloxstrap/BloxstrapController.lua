local MarketplaceService = game:GetService("MarketplaceService")
local RunService = game:GetService("RunService")

local RoRooms = script.Parent.Parent.Parent.Parent
local Future = require(script.Parent.Parent.Parent.Parent.Parent.Future)
local BloxstrapRPC = require(RoRooms.Parent.BloxstrapRPC)

local BloxstrapController = {
	Name = "BloxstrapController",
}

function BloxstrapController:UpdateRichPresence()
	Future.Try(function(PlaceId: number)
		return MarketplaceService:GetProductInfo(PlaceId, Enum.InfoType.Asset)
	end, game.PlaceId):After(function(Success, GameInfo)
		if Success == true then
			BloxstrapRPC.SetRichPresence({
				details = `In {GameInfo.Name}`,
				state = `by {GameInfo.Creator.Name} {(GameInfo.Creator.HasVerifiedBadge and "☑️") or ""}`,
				startTime = os.time(),
				largeImage = {
					assetId = GameInfo.IconImageAssetId,
					hoverText = GameInfo.Name,
				},
				smallImage = {
					assetId = 15885967339,
					hoverText = "RoRooms",
				},
			})
		end
	end)
end

function BloxstrapController:KnitStart()
	if not RunService:IsStudio() then
		self:UpdateRichPresence()
	end
end

function BloxstrapController:KnitInit() end

return BloxstrapController
