local RunService = game:GetService("RunService")

local SourceCode = script.SourceCode
local Config = require(script.Config)
local Packages = script.Parent

local RoRooms = {
	Config = Config,
	Packages = Packages,
	Shared = SourceCode.Shared,
	Storage = SourceCode.Storage,
	Server = SourceCode.Server,
	Client = SourceCode.Client,
}

local function InstallRealmAPI(Realm: { [any]: any })
	for Key, Value in pairs(Realm) do
		RoRooms[Key] = Value
	end
end

if RunService:IsServer() then
	InstallRealmAPI(require(script.Server))
else
	InstallRealmAPI(require(script.Client))
end

return RoRooms
