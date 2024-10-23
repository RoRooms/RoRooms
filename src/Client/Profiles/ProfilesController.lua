local Players = game:GetService("Players")
local RoRooms = script.Parent.Parent.Parent.Parent
local Topbar = require(RoRooms.SourceCode.Client.UI.States.Topbar)
local UIController = require(RoRooms.SourceCode.Client.UI.UIController)
local Fusion = require(RoRooms.Parent.Fusion)
local States = require(RoRooms.SourceCode.Client.UI.States)
local Knit = require(RoRooms.Parent.Knit)
local AvatarSelector = require(script.Parent.AvatarSelector)
local Future = require(RoRooms.Parent.Future)

local Scoped = Fusion.scoped
local Peek = Fusion.peek

local ProfilesService

local ProfilesController = {
	Name = "ProfilesController",

	Scope = Scoped(Fusion),
}

function ProfilesController:GetProfile(UserId: number)
	if UserId <= 0 then
		UserId = 1
	end

	local Success, Result = Future.Try(function()
		return ProfilesService:GetProfile(UserId):await()
	end):Await()
	if Success then
		return Result
	end

	return {}
end

function ProfilesController:KnitStart()
	UIController:MountUI(require(RoRooms.SourceCode.Client.UI.ScreenGuis.ProfileMenu))

	Topbar:AddTopbarButton("Profile", Topbar.NativeButtons.Profile)

	AvatarSelector:Start()

	AvatarSelector.AvatarSelected:Connect(function(Character: Model?)
		local Player = Players:GetPlayerFromCharacter(Character)
		if Player then
			if
				(Player.UserId ~= Peek(States.Menus.ProfileMenu.UserId))
				or (Peek(States.Menus.CurrentMenu) ~= "ProfileMenu")
			then
				States.Menus.ProfileMenu.UserId:set(Player.UserId)
				States.Menus.CurrentMenu:set("ProfileMenu")
			else
				States.Menus.ProfileMenu.UserId:set(nil)
				States.Menus.CurrentMenu:set(nil)
			end
		end
	end)

	AvatarSelector.AvatarDeselected:Connect(function()
		States.Menus.ProfileMenu.UserId:set(nil)

		if Peek(States.Menus.CurrentMenu) == "ProfileMenu" then
			States.Menus.CurrentMenu:set(nil)
		end
	end)

	ProfilesService = Knit.GetService("ProfilesService")
end

return ProfilesController
