local States = require(script.Parent)

local Topbar = {}

function Topbar:AddTopbarButton(
	Name: string,
	Button: {
		[string]: {
			MenuName: string,
			IconImage: string,
			SizeMultiplier: number,
			LayoutOrder: number,
		},
	}
)
	local TopbarButtons = States.TopbarButtons:get()

	TopbarButtons[Name] = Button

	States.TopbarButtons:set(TopbarButtons)
end

function Topbar:RemoveTopbarButton(Name: string)
	local TopbarButtons = States.TopbarButtons:get()

	TopbarButtons[Name] = nil

	States.TopbarButtons:set(TopbarButtons)
end

return Topbar
