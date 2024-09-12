local RoRooms = script.Parent.Parent.Parent.Parent
local PlayerCharacterComponent = require(RoRooms.Server.Components.PlayerCharacterComponent)
local PlayerDataService = require(RoRooms.Server.PlayerData.PlayerDataService)
local t = require(RoRooms.Packages.t)

local EmotesService = {
	Name = "EmotesService",
	Client = {},
}

function EmotesService.Client:PlayEmote(Player: Player, EmoteId: string)
	assert(t.tuple(t.instanceOf("Player")(Player), t.strict(EmoteId)))

	return self.Server:PlayEmote(Player, EmoteId)
end

function EmotesService:PlayEmote(Player: Player, EmoteId: string)
	local Emote = RoRooms.Config.Systems.Emotes.Emotes[EmoteId]
	if Emote then
		local CanUse, FailureReason = self:CanPlayerUseEmote(Player, EmoteId, Emote)
		if CanUse then
			local Character = Player.Character
			if Character then
				local CharacterClass = PlayerCharacterComponent:FromInstance(Character)
				if CharacterClass then
					CharacterClass:PlayEmote(EmoteId, Emote)
				end
			end
		else
			return CanUse, FailureReason
		end
	else
		return false, "Emote does not exist."
	end
end

function EmotesService:CanPlayerUseEmote(Player: Player, EmoteId: string, Emote)
	local CanUse = true
	local FailureReason = nil

	if Emote.LevelRequirement then
		local Profile = PlayerDataService:GetProfile(Player)
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

function EmotesService:KnitInit() end

return EmotesService
