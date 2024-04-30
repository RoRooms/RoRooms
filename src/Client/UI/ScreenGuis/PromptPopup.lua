local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent)
local OnyxUI = require(RoRooms.Packages.OnyxUI)
local Fusion = require(OnyxUI.Packages.Fusion)
local States = require(RoRooms.Client.UI.States)
local Modifier = require(OnyxUI.Utils.Modifier)
local Themer = require(OnyxUI.Utils.Themer)

local Children = Fusion.Children
local New = Fusion.New
local Computed = Fusion.Computed
local Spring = Fusion.Spring
local ForValues = Fusion.ForValues

local AutoScaleFrame = require(OnyxUI.Components.AutoScaleFrame)
local MenuFrame = require(OnyxUI.Components.MenuFrame)
local Text = require(OnyxUI.Components.Text)
local Button = require(OnyxUI.Components.Button)
local Frame = require(OnyxUI.Components.Frame)

return function(Props)
	local CurrentPrompt = Computed(function()
		return States.Prompts:get()[#States.Prompts:get()]
	end)
	local PromptOpen = Computed(function()
		return CurrentPrompt:get() ~= nil
	end)

	-- Prompts:PushPrompt({
	-- 	Title = "Do action",
	-- 	Text = "Would you like to do this action?",
	-- 	Buttons = {
	-- 		{
	-- 			Primary = false,
	-- 			Contents = { "Cancel" },
	-- 			Callback = function()
	-- 				print("cancelled")
	-- 			end,
	-- 		},
	-- 		{
	-- 			Primary = true,
	-- 			Contents = { "Confirm" },
	-- 			Callback = function()
	-- 				print("confirmed")
	-- 			end,
	-- 		},
	-- 	},
	-- })

	local PromptPopup = New "ScreenGui" {
		Name = "PromptPopup",
		Parent = Props.Parent,
		ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets,
		Enabled = PromptOpen,
		ResetOnSpawn = false,

		[Children] = {
			AutoScaleFrame {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = Spring(
					Computed(function()
						local YPos = 0
						if not PromptOpen:get() then
							YPos = YPos + 15
						end
						return UDim2.new(UDim.new(0.5, 0), UDim.new(0.5, YPos))
					end),
					Themer.Theme.SpringSpeed["1"],
					Themer.Theme.SpringDampening
				),
				BaseResolution = Vector2.new(739, 789),
				ScaleClamps = { Min = 1, Max = 1 },

				[Children] = {
					MenuFrame {
						Size = UDim2.fromOffset(305, 0),
						GroupTransparency = Spring(
							Computed(function()
								if PromptOpen:get() then
									return 0
								else
									return 1
								end
							end),
							Themer.Theme.SpringSpeed["1"],
							Themer.Theme.SpringDampening
						),

						[Children] = {
							Modifier.Padding {},
							Modifier.ListLayout {},

							Text {
								Name = "Title",
								TextWrapped = false,
								Text = Computed(function()
									if CurrentPrompt:get() then
										return CurrentPrompt:get().Title
									else
										return ""
									end
								end),
								TextSize = 23,
								FontFace = Font.fromName("GothamSsm", Enum.FontWeight.SemiBold),
							},
							Text {
								Name = "Text",
								Size = UDim2.new(UDim.new(1, 0), UDim.new(0, 80)),
								AutomaticSize = Enum.AutomaticSize.None,
								TextWrapped = true,
								Text = Computed(function()
									if CurrentPrompt:get() then
										return CurrentPrompt:get().Text
									else
										return ""
									end
								end),
								TextSize = 20,
							},
							Frame {
								Size = UDim2.fromScale(1, 0),
								AutomaticSize = Enum.AutomaticSize.Y,

								[Children] = {
									Modifier.ListLayout {
										Padding = Computed(function()
											return UDim.new(0, Themer.Theme.Spacing["0.75"]:get())
										end),
										FillDirection = Enum.FillDirection.Horizontal,
										HorizontalAlignment = Enum.HorizontalAlignment.Center,
									},

									ForValues(
										Computed(function()
											if CurrentPrompt:get() then
												return CurrentPrompt:get().Buttons
											else
												return {}
											end
										end),
										function(ButtonEntry)
											local ButtonCount = #CurrentPrompt:get().Buttons
											return Button {
												Style = (ButtonEntry.Primary and "Filled") or "Empty",
												Contents = ButtonEntry.Contents,
												OnActivated = function()
													local NewPrompts = States.Prompts:get()
													table.remove(
														NewPrompts,
														table.find(NewPrompts, CurrentPrompt:get())
													)
													States.Prompts:set(NewPrompts)
													if ButtonEntry.Callback then
														ButtonEntry.Callback()
													end
												end,
												Size = UDim2.new(UDim.new(1 / ButtonCount, -5), UDim.new(0, 0)),
												AutomaticSize = Enum.AutomaticSize.Y,
											}
										end,
										Fusion.cleanup
									),
								},
							},
						},
					},
				},
			},
		},
	}

	return PromptPopup
end
