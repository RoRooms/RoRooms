local MarketplaceService = game:GetService("MarketplaceService")
local RoRooms = script.Parent.Parent.Parent.Parent
local PlayerCharacterComponent = require(RoRooms.SourceCode.Server.Components.PlayerCharacterComponent)
local PlayerDataStoreService = require(RoRooms.SourceCode.Server.PlayerDataStore.PlayerDataStoreService)
local t = require(RoRooms.Parent.t)
local Config = require(RoRooms.Config).Config
local GamepassesHandler = require(RoRooms.SourceCode.Shared.ExtPackages.GamepassesHandler)
local Future = require(RoRooms.Parent.Future)

local EmotesService = {
	Name = "EmotesService",
	Client = {},
}

function EmotesService.Client:PlayEmote(Player: Player, EmoteId: string)
	assert(t.tuple(t.instanceOf("Player")(Player), t.strict(EmoteId)))

	return self.Server:PlayEmote(Player, EmoteId)
end

function EmotesService:PlayEmote(Player: Player, EmoteId: string)
	local Emote = Config.Systems.Emotes.Emotes[EmoteId]
	if Emote then
		local CanUse, FailureReason = self:CanPlayerUseEmote(Player, EmoteId, Emote)
		if CanUse then
			local Character = Player.Character
			if Character then
				local CharacterClass = PlayerCharacterComponent:FromInstance(Character)
				if CharacterClass then
					CharacterClass:PlayEmote(EmoteId)
					return true
				end
			end
		else
			return CanUse, FailureReason
		end
	else
		return false, "Emote does not exist."
	end

	return false, "Error occurred."
end

function EmotesService:CanPlayerUseEmote(Player: Player, EmoteId: string, Emote): (boolean, string?)
	if Emote.CallbackRequirement ~= nil then
		local CanUse, FailureReason = Emote.CallbackRequirement(Player, EmoteId, Emote)

		if (not CanUse) and (FailureReason == nil) then
			FailureReason = `Insuffient requirements to use {Emote.DisplayName} emote.`
		end

		if not CanUse then
			return false, FailureReason
		end
	end

	if Emote.LevelRequirement ~= nil then
		local Profile = PlayerDataStoreService:GetProfile(Player.UserId)
		if Profile ~= nil then
			if Profile.Data.Level < Emote.LevelRequirement then
				return false, `Emote requires level {Emote.LevelRequirement}.`
			end
		else
			return false, "Data error."
		end
	end

	if Emote.GamepassRequirement ~= nil then
		local OwnsGamepass = GamepassesHandler:PlayerOwnsGamepass(Player, Emote.GamepassRequirement)

		if OwnsGamepass then
			return true
		else
			Future.Try(function()
				MarketplaceService:PromptGamePassPurchase(Player, Emote.GamepassRequirement)
			end)

			return false
		end
	end

	return true
end

return EmotesService
