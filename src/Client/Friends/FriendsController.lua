local Players = game:GetService("Players")

local RoRooms = require(script.Parent.Parent.Parent.Parent)
local Future = require(script.Parent.Parent.Parent.Parent.Parent.Future)
local UIController = require(RoRooms.Client.UI.UIController)
local FriendsMenu = require(RoRooms.Client.UI.ScreenGuis.FriendsMenu)
local States = require(RoRooms.Client.UI.States)
local Knit = require(RoRooms.Packages.Knit)
local Topbar = require(RoRooms.Client.UI.States.Topbar)

local WorldRegistryService

local FRIENDS_ONLINE_CACHE_PERIOD = 30

local FriendsController = {
	Name = "FriendsController",
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
	end):After(function(Success, FriendsOnline)
		if Success then
			self.FriendsOnline = FriendsOnline
			self.FriendsOnlineLastUpdated = os.time()
			States.Friends.Online:set(FriendsOnline)

			self:UpdateFriendsInRoRooms()
		end
	end)
end

function FriendsController:KnitStart()
	WorldRegistryService = Knit.GetService("WorldRegistryService")

	UIController:MountUI(FriendsMenu {})
	Topbar:AddTopbarButton("Friends", Topbar.NativeButtons.Friends)

	self:UpdateFriends(true)

	while task.wait(1) do
		local SecondsSinceUpdated = os.time() - self.FriendsOnlineLastUpdated
		if (SecondsSinceUpdated > FRIENDS_ONLINE_CACHE_PERIOD) and (States.CurrentMenu:get() == "FriendsMenu") then
			self:UpdateFriends()
		end
	end
end

function FriendsController:KnitInit()
	self.FriendsOnline = {}
	self.FriendsInRoRooms = {}
	self.FriendsNotInGame = {}
	self.FriendsOnlineLastUpdated = os.time()
end

return FriendsController
