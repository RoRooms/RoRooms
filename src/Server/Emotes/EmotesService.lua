local RoRooms = script.Parent.Parent.Parent.Parent
local PlayerCharacterComponent = require(RoRooms.SourceCode.Server.Components.PlayerCharacterComponent)
local PlayerDataStoreService = require(RoRooms.SourceCode.Server.PlayerData.PlayerDataStoreService)
local t = require(RoRooms.Parent.t)
local Config = require(RoRooms.Config).Config

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
					CharacterClass:PlayEmote(EmoteId, Emote)
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

function EmotesService:CanPlayerUseEmote(Player: Player, EmoteId: string, Emote)
	local CanUse = true
	local FailureReason = nil

	if Emote.LevelRequirement then
		local Profile = PlayerDataStoreService:GetProfile(Player.UserId)
		if Profile then
			CanUse = Profile.Data.Level >= Emote.LevelRequirement
		else
			CanUse = false
			FailureReason = `Emote requires level {Emote.LevelRequirement}.`
		end
	end

	if Emote.RequirementCallback then
		CanUse, FailureReason = Emote.RequirementCallback(Player, EmoteId, Emote)

		if (not CanUse) and (FailureReason == nil) then
			FailureReason = `Insuffient requirements to use {Emote.Name} emote.`
		end
	end

	return CanUse, FailureReason
end

function EmotesService:KnitStart() end

return EmotesService
