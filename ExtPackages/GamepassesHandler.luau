local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local RoRooms = script.Parent.Parent.Parent.Parent
local Future = require(RoRooms.Parent.Future)
local Signal = require(RoRooms.Parent.Signal)

export type GamepassesProfile = { number }

local GamepassesHandler = {
	Name = script.Name,

	Profiles = {},

	PlayerPurchasedGamepass = Signal.new(),
	PlayerLoadedGamepass = Signal.new(),
}

function GamepassesHandler:PlayerOwnsGamepass(Player: Player, GamepassId: number): boolean
	local Profile = self:_GetProfile(Player)
	local OwnsGamepass = table.find(Profile, GamepassId) ~= nil

	if not OwnsGamepass then
		OwnsGamepass = self:_UpdateOwnershipForPlayer(Player, GamepassId)
	end

	return OwnsGamepass
end

function GamepassesHandler:_UpdateOwnershipForPlayer(Player: Player, GamepassId: number): boolean?
	local Success, OwnsGamepass = Future.Try(function()
		return MarketplaceService:UserOwnsGamePassAsync(Player.UserId, GamepassId)
	end):Await()

	if Success then
		local Profile = self:_GetProfile(Player)
		local OwnershipIndex = table.find(Profile, GamepassId)

		if OwnsGamepass then
			if OwnershipIndex == nil then
				table.insert(Profile, GamepassId)
			end

			self.PlayerLoadedGamepass:Fire(Player, GamepassId)
		else
			if OwnershipIndex ~= nil then
				table.remove(Profile, GamepassId)
			end
		end

		return OwnsGamepass
	end

	return false
end

function GamepassesHandler:_LoadPlayerGamepasses(Player: Player, GamepassIds: { number })
	for _, GamepassId in ipairs(GamepassIds) do
		self:_UpdateOwnershipForPlayer(Player, GamepassId)
	end
end

function GamepassesHandler:_GetProfile(Player: Player): GamepassesProfile
	local Profile = self.Profiles[Player]

	if Profile == nil then
		Profile = {}
		self.Profiles[Player] = Profile
	end

	return Profile
end

function GamepassesHandler:_DeleteProfile(Player: Player)
	self.Profiles[Player] = nil
end

Players.PlayerRemoving:Connect(function(Player)
	GamepassesHandler:_DeleteProfile(Player)
end)

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(Player, GamepassId, WasPurchased)
	if Player and WasPurchased then
		local Profile = GamepassesHandler:_GetProfile(Player)
		table.insert(Profile, GamepassId)

		GamepassesHandler.PlayerPurchasedGamepass:Fire(Player, GamepassId)
	end
end)

return GamepassesHandler
