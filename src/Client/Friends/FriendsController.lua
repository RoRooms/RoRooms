local Players = game:GetService("Players")

local RoRooms = script.Parent.Parent.Parent.Parent
local Future = require(script.Parent.Parent.Parent.Parent.Parent.Future)
local UIController = require(RoRooms.SourceCode.Client.UI.UIController)
local States = require(RoRooms.SourceCode.Client.UI.States)
local Knit = require(RoRooms.Parent.Knit)
local Topbar = require(RoRooms.SourceCode.Client.UI.States.Topbar)
local Fusion = require(RoRooms.Parent.Fusion)

local Peek = Fusion.peek

local WorldRegistryService

local FRIENDS_ONLINE_CACHE_PERIOD = 30

local FriendsController = {
	Name = "FriendsController",

	FriendsOnline = {},
	FriendsInRoRooms = {},
	FriendsNotInGame = {},
	FriendsOnlineLastUpdated = os.time(),
}

function FriendsController:UpdateFriendsInRoRooms()
	local FriendsInRoRooms = {}
	local FriendsNotInRoRooms = {}

	for _, Friend in ipairs(self.FriendsOnline) do
		local WorldIsRegistered = false
		if Friend.PlaceId then
			local Success, Result = WorldRegistryService:IsWorldRegistered(Friend.PlaceId):await()
			if Success then
				WorldIsRegistered = Result
			end
		end
		if WorldIsRegistered then
			table.insert(FriendsInRoRooms, Friend)
		else
			table.insert(FriendsNotInRoRooms, Friend)
		end
	end

	self.FriendsInRoRooms = FriendsInRoRooms
	States.Friends.InRoRooms:set(FriendsInRoRooms)

	self.FriendsNotInRoRooms = FriendsNotInRoRooms
	States.Friends.NotInRoRooms:set(FriendsNotInRoRooms)
end

function FriendsController:UpdateFriends(ForceUpdate: boolean?)
	if (not ForceUpdate) and ((os.time() - self.FriendsOnlineLastUpdated) <= FRIENDS_ONLINE_CACHE_PERIOD) then
		return
	end

	return Future.Try(function()
		return Players.LocalPlayer:GetFriendsOnline()
	end):After(function(Success, Result)
		if Success then
			self.FriendsOnline = Result
			self.FriendsOnlineLastUpdated = os.time()
			States.Friends.Online:set(Result)

			self:UpdateFriendsInRoRooms()
		else
			warn(Result)
		end
	end)
end

function FriendsController:KnitStart()
	WorldRegistryService = Knit.GetService("WorldRegistryService")

	UIController:MountUI(require(RoRooms.SourceCode.Client.UI.ScreenGuis.FriendsMenu))
	Topbar:AddTopbarButton("Friends", Topbar.NativeButtons.Friends)

	self:UpdateFriends(true)

	while task.wait(1) do
		local SecondsSinceUpdated = os.time() - self.FriendsOnlineLastUpdated
		if
			(SecondsSinceUpdated > FRIENDS_ONLINE_CACHE_PERIOD) and (Peek(States.Menus.CurrentMenu) == "FriendsMenu")
		then
			self:UpdateFriends()
		end
	end
end

return FriendsController
