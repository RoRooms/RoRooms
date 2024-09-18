local Players = game:GetService("Players")
local RoRooms = script.Parent.Parent.Parent.Parent
local Signal = require(RoRooms.Parent.Signal)
local DataTemplate = require(script.Parent.DataTemplate)

export type SessionData = DataTemplate.Data
export type MetaData = {
	CreationTime: number,
}
export type SessionProfile = {
	Data: SessionData,
	MetaData: MetaData,
	UpdateData: (SessionProfile, SessionData) -> SessionData,
	DataUpdated: Signal.Signal<SessionData, SessionData>,
}

local PlayerDataService = {
	Name = script.Name,

	SessionProfiles = {},
	ProfileCreated = Signal.new(),
	ProfileDeleted = Signal.new(),
}

function PlayerDataService:GetProfile(UserId: number): SessionProfile?
	return self.Players[UserId]
end

function PlayerDataService:DeleteProfile(UserId: number)
	if self.SessionProfiles[UserId] ~= nil then
		self.SessionProfiles[UserId] = nil
		self.ProfileDeleted:Fire(UserId)
	end
end

function PlayerDataService:CreateProfile(Player: Player): SessionProfile?
	if self.SessionProfiles[Player.UserId] ~= nil then
		return
	end

	local Profile = {
		Data = table.clone(DataTemplate),
		MetaData = {
			CreationTime = os.time(),
		},
		DataUpdated = Signal.new(),
	}

	function Profile:UpdateData(NewData: SessionData)
		local OldData = table.clone(self.Data)
		self.Data = NewData

		self.DataUpdated:Fire(OldData, NewData)
	end

	self.SessionProfiles[Player.UserId] = Profile

	table.freeze(Profile)

	return Profile
end

function PlayerDataService:Start()
	Players.PlayerAdded:Connect(function(Player)
		self:CreateProfile(Player)
	end)
	for _, Player in ipairs(Players:GetPlayers()) do
		self:CreateProfile(Player)
	end

	Players.PlayerRemoving:Connect(function(Player)
		self:DeleteProfile(Player.UserId)
	end)
end

function PlayerDataService:KnitStart()
	self:Start()
end

return PlayerDataService
