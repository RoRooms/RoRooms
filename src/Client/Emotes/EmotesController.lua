local RoRooms = require(script.Parent.Parent.Parent.Parent)

local Client = RoRooms.Client
local Packages = RoRooms.Packages

local Knit = require(Packages.Knit)
local Topbar = require(Client.UI.States.Topbar)
local Prompts = require(Client.UI.States.Prompts)
local UIController = require(Client.UI.UIController)

local EmotesMenu = require(Client.UI.ScreenGuis.EmotesMenu)

local EmotesService

local EmotesController = {
	Name = "EmotesController",
}

function EmotesController:PlayEmote(EmoteId: string)
	EmotesService:PlayEmote(EmoteId):andThen(function(FailureReason: string)
		if typeof(FailureReason) == "string" then
			Prompts:PushPrompt({
				Title = "Failure",
				Text = FailureReason,
				Buttons = {
					{
						Primary = false,
						Contents = { "Close" },
					},
				},
			})
		end
	end)
end

function EmotesController:KnitStart()
	UIController = Knit.GetController("UIController")
	EmotesService = Knit.GetService("EmotesService")

	UIController:MountUI(EmotesMenu {})

	Topbar:AddTopbarButton(Topbar.NativeButtons.Emotes)
end

function EmotesController:KnitInit() end

return EmotesController
