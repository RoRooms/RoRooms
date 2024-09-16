local RunService = game:GetService("RunService")

local Config = require(script.Config)
local Version = require(script.Version)

local RoRooms = {
	_Version = Version,
	Config = Config,
}

function RoRooms:Start()
	if RunService:IsServer() then
		local Server = require(script.Server)
		Server:Start()
	else
		local Client = require(script.Client)
		Client:Start()
	end
end

return RoRooms
