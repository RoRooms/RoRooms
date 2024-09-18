local RoRooms = script.Parent.Parent.Parent.Parent
local Topbar = require(RoRooms.SourceCode.Client.UI.States.Topbar)
local UIController = require(RoRooms.SourceCode.Client.UI.UIController)
local Fusion = require(RoRooms.Parent.Fusion)
local States = require(RoRooms.SourceCode.Client.UI.States)

local Scoped = Fusion.scoped
local Peek = Fusion.peek

local ProfilesController = {
	Name = "ProfilesController",

	Scope = Scoped(Fusion),
}

function ProfilesController:KnitStart()
	UIController:MountUI(require(RoRooms.SourceCode.Client.UI.ScreenGuis.ProfileMenu))

	Topbar:AddTopbarButton("Profile", Topbar.NativeButtons.Profile)

	self.Scope:Observer(States.Profile.Nickname):onChange(function()
		local NicknameValue = Peek(States.Profile.Nickname)

		if States.Services.ProfilesService then
			States.Services.ProfilesService:SetNickname(NicknameValue)
		end
	end)
	self.Scope:Observer(States.Profile.Status):onChange(function()
		local StatusValue = Peek(States.Profile.Status)

		if States.Services.ProfilesService then
			States.Services.ProfilesService:SetStatus(StatusValue)
		end
	end)
end

return ProfilesController
