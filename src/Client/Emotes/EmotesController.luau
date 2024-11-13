local Rorooms = script.Parent.Parent.Parent.Parent
local Knit = require(Rorooms.Parent.Knit)
local Topbar = require(Rorooms.SourceCode.Client.UI.States.Topbar)
local Prompts = require(Rorooms.SourceCode.Client.UI.States.Prompts)
local UIController = require(Rorooms.SourceCode.Client.UI.UIController)

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
						Content = { "Close" },
					},
				},
			})
		end
	end)
end

function EmotesController:KnitStart()
	UIController = Knit.GetController("UIController")
	EmotesService = Knit.GetService("EmotesService")

	UIController:MountUI(require(Rorooms.SourceCode.Client.UI.ScreenGuis.EmotesMenu))

	Topbar:AddTopbarButton("Emotes", Topbar.NativeButtons.Emotes)
end

return EmotesController
