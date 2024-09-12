local RunService = game:GetService("RunService")
local RoRooms = script.Parent.Parent.Parent.Parent
local OnyxUI = require(RoRooms.Parent.OnyxUI)
local Fusion = require(RoRooms.Packages.Fusion)
local States = require(RoRooms.SourceCode.Client.UI.States)
local Prompts = require(RoRooms.SourceCode.Client.UI.States.Prompts)

local Observer = Fusion.Observer

local UpdatesController = {
	Name = script.Name,
}

function UpdatesController:KnitStart()
	local LastUpToDate: boolean?

	if RunService:IsStudio() then
		Observer(States.RoRooms.UpToDate):onChange(function()
			local UpToDate = States.RoRooms.UpToDate:get()
			if not UpToDate and (LastUpToDate ~= UpToDate) then
				Prompts:PushPrompt({
					Title = "Update available ✨",
					Text = "RoRooms is out of date. Please update to receive the latest bug-fixes and improvements.",
					Buttons = {
						{
							Contents = { "Close" },
						},
					},
				})
			end

			LastUpToDate = States.RoRooms.UpToDate:get()
		end)
	end
end

function UpdatesController:KnitInit() end

return UpdatesController
