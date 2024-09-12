local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent.Parent.Parent)
local ReconcileTable = require(RoRooms.Shared.ExtPackages.ReconcileTable)
local States = require(script.Parent)
local Fusion = require(RoRooms.Packages.Fusion)

local Peek = Fusion.peek

type Prompt = {
	Title: string,
	Text: string,
	Buttons: {
		[number]: {
			Contents: { [number]: string },
			Style: string?,
			Disabled: boolean?,
			Callback: () -> ()?,
		},
	},
}

local PROMPT_TEMPLATE = {
	Title = "",
	Text = "",
	Buttons = {},
}

local Prompts = {}

function Prompts:PushPrompt(Prompt: Prompt)
	local NewPrompts = Peek(States.Prompts)

	ReconcileTable(Prompt, PROMPT_TEMPLATE)

	for _, ExistingPrompt in ipairs(NewPrompts) do
		if ExistingPrompt.Text == Prompt.Text then
			return
		end
	end

	table.insert(NewPrompts, Prompt)

	States.Prompts:set(NewPrompts)
end

function Prompts:RemovePrompt(Prompt: Prompt)
	local NewPrompts = Peek(States.Prompts)

	for Index = #NewPrompts, 1, -1 do
		if NewPrompts[Index] == Prompt then
			table.remove(NewPrompts, Index)
			break
		end
	end

	States.Prompts:set(NewPrompts)
end

return Prompts
