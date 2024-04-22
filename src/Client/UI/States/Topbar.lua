local States = require(script.Parent)

local Topbar = {
	NativeButtons = {
		Settings = {
			MenuName = "SettingsMenu",
			IconImage = "rbxassetid://15091717549",
			LayoutOrder = 5,
		},
		Emotes = {
			MenuName = "EmotesMenu",
			IconImage = "rbxassetid://15091717452",
			LayoutOrder = 3,
		},
		Friends = {
			MenuName = "FriendsMenu",
			IconImage = "rbxassetid://16037713145",
			LayoutOrder = 2,
		},
		Profile = {
			MenuName = "ProfileMenu",
			IconImage = "rbxassetid://15091717235",
			LayoutOrder = 1,
		},
		Worlds = {
			MenuName = "WorldsMenu",
			IconImage = "rbxassetid://15091717321",
			LayoutOrder = 4,
		},
	},
}

function Topbar:AddDefaultButtons()
	for Name, Button in ipairs(self.DefaultButtons) do
		self:AddDefaultButtons(Name, Button)
	end
end

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
