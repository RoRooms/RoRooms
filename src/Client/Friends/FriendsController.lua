local RoRooms = require(script.Parent.Parent.Parent.Parent)
local Players = game:GetService("Players")

local Client = RoRooms.Client
local Packages = RoRooms.Packages

local UIController = require(Client.UI.UIController)
local FriendsMenu = require(Client.UI.ScreenGuis.FriendsMenu)
local States = require(Client.UI.States)
local Knit = require(Packages.Knit)
local Topbar = require(Client.UI.States.Topbar)

local WorldsService

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
			local Success, Result = WorldsService:IsWorldRegistered(Friend.PlaceId):await()
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

	local Success, Result = pcall(function()
		return Players.LocalPlayer:GetFriendsOnline()
	end)
	if Success then
		if typeof(Result) == "table" then
			self.FriendsOnline = Result
			self.FriendsOnlineLastUpdated = os.time()
			States.Friends.Online:set(Result)

			self:UpdateFriendsInRoRooms()
		end
	else
		warn(Result)
	end
end

function FriendsController:KnitStart()
	WorldsService = Knit.GetService("WorldsService")

	UIController:MountUI(FriendsMenu {})
	Topbar:AddTopbarButton("Friends", {
		MenuName = "FriendsMenu",
		IconImage = "rbxassetid://16037713145",
		LayoutOrder = 2,
	})

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
