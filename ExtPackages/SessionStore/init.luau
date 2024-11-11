local Players = game:GetService("Players")

local RoRooms = script.Parent.Parent.Parent.Parent
local Signal = require(RoRooms.Parent.Signal)
local DataTemplate = require(script.DataTemplate)

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

local SessionStore = {
	Profiles = {},
	ProfileCreated = Signal.new(),
	ProfileDeleted = Signal.new(),
}

function SessionStore:GetProfileSafe(Player: Player): SessionProfile
	return self:GetProfile(Player) or self:CreateProfile(Player)
end

function SessionStore:GetProfile(Player: Player): SessionProfile?
	return self.Profiles[Player.UserId]
end

function SessionStore:DeleteProfile(UserId: number)
	if self.Profiles[UserId] ~= nil then
		self.Profiles[UserId] = nil
		self.ProfileDeleted:Fire(UserId)
	end
end

function SessionStore:CreateProfile(Player: Player): SessionProfile?
	if self.Profiles[Player.UserId] ~= nil then
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

	self.Profiles[Player.UserId] = Profile

	table.freeze(Profile)

	return Profile
end

Players.PlayerRemoving:Connect(function(Player)
	SessionStore:DeleteProfile(Player.UserId)
end)

return SessionStore
