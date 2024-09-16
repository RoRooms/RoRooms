local RoRooms = script.Parent.Parent.Parent.Parent
local Version = require(RoRooms.Version)
local Fetch = require(RoRooms.Parent.Fetch)
local Future = require(RoRooms.Parent.Future)
local Knit = require(RoRooms.Parent.Knit)

local LATEST_RELEASE_URL = "https://api.github.com/repos/imavafe/onyxui/releases/latest"

local UpdatesService = {
	Name = script.Name,
	Client = {
		UpToDate = Knit.CreateProperty(),
	},

	UpToDate = false,
}

function UpdatesService:IsUpToDate()
	return Future.Try(function()
		local Success, Result = self:GetLatestVersion():Await()

		if Success then
			local UpToDate = Version == Result
			self.UpToDate = UpToDate
			self.Client.UpToDate:Set(UpToDate)

			return UpToDate
		end

		return nil
	end)
end

function UpdatesService:GetLatestVersion()
	return Future.Try(function()
		local Success, Response = Fetch(LATEST_RELEASE_URL):Await()

		if Success and Response.Ok then
			local DecodeSucceeded, Data = Response:Json()
			if DecodeSucceeded then
				return Data.tag_name
			end
		end

		return nil
	end)
end

function UpdatesService:KnitStart()
	self:IsUpToDate()
end

return UpdatesService
