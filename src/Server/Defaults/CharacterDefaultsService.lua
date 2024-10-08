local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

local CharacterDefaultsService = {
	Name = "CharacterDefaultsService",
}

function CharacterDefaultsService:KnitStart()
	Players.PlayerAdded:Connect(function(Player)
		Player.CharacterAdded:Connect(function(Char)
			CollectionService:AddTag(Char, "RR_PlayerCharacter")
		end)
	end)
end

return CharacterDefaultsService
