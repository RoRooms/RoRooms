local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent.Parent.Parent)

local Shared = RoRooms.Shared

local ReconcileTable = require(Shared.ExtPackages.ReconcileTable)
local States = require(script.Parent)

local Prompts = {}

function Prompts:PushPrompt(Prompt: { [any]: any })
	local PromptTemplate = {
		Title = "",
		Text = "",
		Buttons = {
			{
				Primary = true,
				Content = { "Confirm" },
				Callback = function() end,
			},
			{
				Primary = false,
				Content = { "Cancel" },
				Callback = function() end,
			},
		},
	}

	local NewPrompts = States.Prompts:get()

	ReconcileTable(Prompt, PromptTemplate)

	for _, ExistingPrompt in ipairs(NewPrompts) do
		if ExistingPrompt.Text == Prompt.Text then
			return
		end
	end

	table.insert(NewPrompts, Prompt)

	States.Prompts:set(NewPrompts)
end

return Prompts
