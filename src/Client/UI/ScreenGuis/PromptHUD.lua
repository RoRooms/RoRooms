local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent)
local OnyxUI = require(RoRooms.Packages.OnyxUI)
local Fusion = require(OnyxUI.Packages.Fusion)
local States = require(RoRooms.Client.UI.States)
local Modifier = require(OnyxUI.Utils.Modifier)
local Themer = require(OnyxUI.Utils.Themer)
local Prompts = require(RoRooms.Client.UI.States.Prompts)

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
	local Buttons = Computed(function()
		if CurrentPrompt:get() and CurrentPrompt:get().Buttons then
			return CurrentPrompt:get().Buttons
		else
			return {}
		end
	end)

	return New "ScreenGui" {
		Name = "PromptHUD",
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
						Size = Computed(function()
							return UDim2.fromOffset(Themer.Theme.Spacing["16"]:get(), 0)
						end),
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
						BackgroundTransparency = States.PreferredTransparency,

						[Children] = {
							Modifier.ListLayout {
								Padding = Computed(function()
									return UDim.new(0, Themer.Theme.Spacing["2"]:get())
								end),
							},

							Frame {
								Name = "Details",
								Size = UDim2.fromScale(1, 0),
								AutomaticSize = Enum.AutomaticSize.Y,

								[Children] = {
									Modifier.ListLayout {},

									Text {
										Name = "Title",
										Text = Computed(function()
											if CurrentPrompt:get() and CurrentPrompt:get().Title then
												return CurrentPrompt:get().Title
											else
												return "Title"
											end
										end),
										TextSize = Themer.Theme.TextSize["1.25"],
										FontFace = Computed(function()
											return Font.new(
												Themer.Theme.Font.Heading:get(),
												Themer.Theme.FontWeight.Heading:get()
											)
										end),
										Size = UDim2.fromScale(1, 0),
										AutomaticSize = Enum.AutomaticSize.Y,
										TextWrapped = false,
									},
									Text {
										Name = "Body",
										Text = Computed(function()
											if CurrentPrompt:get() and CurrentPrompt:get().Text then
												return CurrentPrompt:get().Text
											else
												return "Prompt body text"
											end
										end),
										Size = Computed(function()
											return UDim2.new(UDim.new(1, 0), UDim.new(0, 0))
										end),
										AutomaticSize = Enum.AutomaticSize.Y,
										TextWrapped = true,
									},
								},
							},
							Frame {
								Name = "Buttons",
								Size = UDim2.fromScale(1, 0),
								AutomaticSize = Enum.AutomaticSize.Y,
								Visible = Computed(function()
									return #Buttons:get() >= 1
								end),

								[Children] = {
									Modifier.ListLayout {
										FillDirection = Enum.FillDirection.Horizontal,
										HorizontalAlignment = Enum.HorizontalAlignment.Right,
									},

									ForValues(Buttons, function(PromptButton)
										return Button {
											Contents = PromptButton.Contents,
											Style = PromptButton.Style,
											Color = PromptButton.Color,
											Disabled = PromptButton.Disabled,

											OnActivated = function()
												Prompts:RemovePrompt(CurrentPrompt:get())

												if PromptButton.Callback then
													PromptButton.Callback()
												end
											end,
										}
									end, Fusion.cleanup),
								},
							},
						},
					},
				},
			},
		},
	}
end
