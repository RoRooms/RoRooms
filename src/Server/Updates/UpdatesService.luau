local Rorooms = script.Parent.Parent.Parent.Parent
local Version = require(Rorooms.Version)
local Fetch = require(Rorooms.Parent.Fetch)
local Future = require(Rorooms.Parent.Future)
local Knit = require(Rorooms.Parent.Knit)

local LATEST_RELEASE_URL = "https://api.github.com/repos/Rorooms/Rorooms/releases/latest"

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
