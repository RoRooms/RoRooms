local RunService = game:GetService("RunService")
local Rorooms = script.Parent.Parent.Parent.Parent
local Fusion = require(Rorooms.Parent.Fusion)
local States = require(Rorooms.SourceCode.Client.UI.States)
local Prompts = require(Rorooms.SourceCode.Client.UI.States.Prompts)

local Peek = Fusion.peek

local UpdatesController = {
	Name = script.Name,
	Scope = Fusion.scoped(Fusion),
}

function UpdatesController:KnitStart()
	local LastUpToDate: boolean?

	if RunService:IsStudio() then
		self.Scope:Observer(States.Rorooms.UpToDate):onChange(function()
			local UpToDate = Peek(States.Rorooms.UpToDate)
			if (UpToDate == false) and (LastUpToDate ~= UpToDate) then
				Prompts:PushPrompt({
					Title = "Update available ✨",
					Text = "Rorooms is out of date. Please update to receive the latest bug-fixes and improvements.",
					Buttons = {
						{
							Content = { "Close" },
						},
					},
				})
			end

			LastUpToDate = Peek(States.Rorooms.UpToDate)
		end)
	end
end

return UpdatesController
