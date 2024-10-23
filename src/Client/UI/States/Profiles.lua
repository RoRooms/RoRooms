local RoRooms = script.Parent.Parent.Parent.Parent.Parent
local States = require(script.Parent)
local Future = require(RoRooms.Parent.Future)
local Fusion = require(RoRooms.Parent.Fusion)
local Types = require(RoRooms.SourceCode.Shared.Types)

local Profiles = {}

function Profiles.SafeProfileValue(
	Scope: Fusion.Scope<typeof(Fusion)>,
	ProfileValue: Fusion.Value<Fusion.Scope<any>, Types.Profile?>
)
	return Scope:Computed(function(Use): Types.Profile
		local Profile: Types.Profile = Use(ProfileValue)

		if Profile then
			return Profile
		else
			return {
				Nickname = "Name",
				DisplayName = "Name",
				Username = "Username",
				Role = nil,
				Bio = nil,
				Level = 0,
			}
		end
	end)
end

function Profiles.ProfileValue(
	Scope: Fusion.Scope<typeof(Fusion)>,
	UserId: Fusion.UsedAs<number>
): Fusion.Value<Fusion.Scope<any>, Types.Profile?>
	local ProfileValue = Scope:Value(nil)

	local function UpdateProfile()
		task.spawn(function()
			local UserIdValue = Fusion.peek(UserId) or 0
			if UserIdValue > 0 then
				local RetrievedProfile = Profiles:GetProfile(UserIdValue)
				if RetrievedProfile then
					ProfileValue:set(RetrievedProfile)
				end
			end
		end)
	end

	Scope:Observer(UserId):onChange(function()
		UpdateProfile()
	end)
	if next(States.Services.ProfilesService) ~= nil then
		States.Services.ProfilesService.ProfileUpdated:Connect(function(UpdatedUserId: number)
			if UpdatedUserId == Fusion.peek(UserId) then
				Profiles:FetchProfile(UpdatedUserId)
				UpdateProfile()
			end
		end)
	end
	UpdateProfile()

	return ProfileValue
end

function Profiles:GetProfile(UserId: number): Types.Profile?
	local LoadedProfiles = Fusion.peek(States.Profiles.Loaded)
	local ExistingProfile = LoadedProfiles[UserId]

	if ExistingProfile ~= nil then
		return ExistingProfile
	else
		return self:FetchProfile(UserId)
	end
end

function Profiles:FetchProfile(UserId: number): Types.Profile?
	if UserId <= 0 then
		UserId = 1
	end

	local Profile
	local LoadedProfiles = Fusion.peek(States.Profiles.Loaded)

	local Success, Result = Future.Try(function()
		if next(States.Services.ProfilesService) ~= nil then
			local Success2, Result2 = States.Services.ProfilesService:GetProfile(UserId):await()
			if Success2 and Result2 then
				return Result2
			end
		end
		return nil
	end):Await()
	if Success and Result then
		Profile = Result
	end

	LoadedProfiles[UserId] = Profile
	States.Profiles.Loaded:set(LoadedProfiles)

	return Profile
end

return Profiles
