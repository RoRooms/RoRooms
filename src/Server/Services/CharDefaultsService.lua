-- local RoRooms = require(game:GetService("ReplicatedStorage").RoRooms)

-- local Shared = RoRooms.Shared

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")

local CharDefaultsService = {
    Name = "CharDefaultsService";
}

function CharDefaultsService:KnitStart()
    Players.PlayerAdded:Connect(function(Player)
        Player.CharacterAdded:Connect(function(Char)
            CollectionService:AddTag(Char, "RR_PlayerCharacter")
            CollectionService:AddTag(Char, "RR_NametaggedChar")
        end)
    end)
end

return CharDefaultsService