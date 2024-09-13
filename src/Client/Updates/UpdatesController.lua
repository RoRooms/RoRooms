local RunService = game:GetService("RunService")
local RoRooms = script.Parent.Parent.Parent.Parent
local Fusion = require(RoRooms.Parent.Fusion)
local States = require(RoRooms.SourceCode.Client.UI.States)
local Prompts = require(RoRooms.SourceCode.Client.UI.States.Prompts)

local Peek = Fusion.peek

local UpdatesController = {
	Name = script.Name,
	Scope = Fusion.scoped(Fusion),
}

function UpdatesController:KnitStart()
	local LastUpToDate: boolean?

	if RunService:IsStudio() then
		self.Scope:Observer(States.RoRooms.UpToDate):onChange(function()
			local UpToDate = Peek(States.RoRooms.UpToDate)
			if not UpToDate and (LastUpToDate ~= UpToDate) then
				Prompts:PushPrompt({
					Title = "Update available ✨",
					Text = "RoRooms is out of date. Please update to receive the latest bug-fixes and improvements.",
					Buttons = {
						{
							Content = { "Close" },
						},
					},
				})
			end

			LastUpToDate = Peek(States.RoRooms.UpToDate)
		end)
	end
end

function UpdatesController:KnitInit() end

return UpdatesController
