local RoRooms = require(script.Parent.Parent.Parent.Parent)
local GroupService = game:GetService("GroupService")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local Packages = RoRooms.Packages

local BloxstrapRPC = require(Packages.BloxstrapRPC)

local BloxstrapController = {
  Name = "BloxstrapController"
}

function BloxstrapController:KnitStart()
  local GameIcon = 0
  local CreatorName = "Creator"
  local GameName = "Game"
  local IsVerified = false

  local Success, Result = pcall(function()
    local GameInfo = MarketplaceService:GetProductInfo(game.PlaceId, Enum.InfoType.Asset)
    GameIcon = GameInfo.IconImageAssetId
    CreatorName = GameInfo.Creator.Name
    GameName = GameInfo.Name
    IsVerified = GameInfo.Creator.HasVerifiedBadge
  end)
  if not Success then
    warn(Result)
  end

  BloxstrapRPC.SetRichPresence({
    details = `In {GameName}`,
    state = `by {CreatorName} {(IsVerified and "☑️") or ""}`,
    startTime = os.time(),
    largeImage = {
      assetId = GameIcon,
      hoverText = GameName
    },
    smallImage = {
      assetId = 15885967339,
      hoverText = "RoRooms"
    }
})
end

function BloxstrapController:KnitInit()
  
end

return BloxstrapController