local RoRooms = script.Parent.Parent.Parent.Parent
local Knit = require(RoRooms.Packages.Knit)
local Topbar = require(RoRooms.Client.UI.States.Topbar)
local Prompts = require(RoRooms.Client.UI.States.Prompts)
local UIController = require(RoRooms.Client.UI.UIController)

local EmotesMenu = require(RoRooms.Client.UI.ScreenGuis.EmotesMenu)

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

	Topbar:AddTopbarButton("Emotes", Topbar.NativeButtons.Emotes)
end

function EmotesController:KnitInit() end

return EmotesController
