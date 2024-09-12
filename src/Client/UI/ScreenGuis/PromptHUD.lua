local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent)
local OnyxUI = require(RoRooms.Packages.OnyxUI)
local Fusion = require(RoRooms.Packages.Fusion)
local States = require(RoRooms.Client.UI.States)

local Prompts = require(RoRooms.Client.UI.States.Prompts)

local Children = Fusion.Children

local AutoScaleFrame = require(OnyxUI.Components.AutoScaleFrame)
local MenuFrame = require(OnyxUI.Components.MenuFrame)
local Text = require(OnyxUI.Components.Text)
local Button = require(OnyxUI.Components.Button)
local Frame = require(OnyxUI.Components.Frame)

return function(Scope: Fusion.Scope<any>, Props)
	local CurrentPrompt = Scope:Computed(function(Use)
		return Use(States.Prompts)[#Use(States.Prompts)]
	end)
	local PromptOpen = Scope:Computed(function(Use)
		return Use(CurrentPrompt) ~= nil
	end)
	local Buttons = Scope:Computed(function(Use)
		if Use(CurrentPrompt) and Use(CurrentPrompt).Buttons then
			return Use(CurrentPrompt).Buttons
		else
			return {}
		end
	end)

	return Scope:New "ScreenGui" {
		Name = "PromptHUD",
		Parent = Props.Parent,
		ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets,
		Enabled = PromptOpen,
		ResetOnSpawn = false,

		[Children] = {
			AutoScaleFrame {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = Scope:Spring(
					Scope:Computed(function(Use)
						local YPos = 0
						if not Use(PromptOpen) then
							YPos = YPos + 15
						end
						return UDim2.new(UDim.new(0.5, 0), UDim.new(0.5, YPos))
					end),
					Theme.SpringSpeed["1"],
					Theme.SpringDampening
				),
				BaseResolution = Vector2.new(739, 789),
				MinScale = 1,
				MaxScale = 1,

				[Children] = {
					MenuFrame {
						Size = Scope:Computed(function(Use)
							return UDim2.fromOffset(Use(Theme.Spacing["16"]) * 1.2, 0)
						end),
						AutomaticSize = Enum.AutomaticSize.Y,
						GroupTransparency = Scope:Spring(
							Scope:Computed(function(Use)
								if Use(PromptOpen) then
									return 0
								else
									return 1
								end
							end),
							Theme.SpringSpeed["1"],
							Theme.SpringDampening
						),
						BackgroundTransparency = States.PreferredTransparency,
						ListEnabled = true,
						ListPadding = Scope:Computed(function(Use)
							return UDim.new(0, Use(Theme.Spacing["2"]))
						end),

						[Children] = {
							Frame {
								Name = "Details",
								Size = UDim2.fromScale(1, 0),
								AutomaticSize = Enum.AutomaticSize.Y,
								ListEnabled = true,

								[Children] = {
									Text {
										Name = "Title",
										Text = Scope:Computed(function(Use)
											if Use(CurrentPrompt) and Use(CurrentPrompt).Title then
												return Use(CurrentPrompt).Title
											else
												return "Title"
											end
										end),
										TextSize = Theme.TextSize["1.25"],
										FontFace = Scope:Computed(function(Use)
											return Font.new(Use(Theme.Font.Heading), Use(Theme.FontWeight.Heading))
										end),
										Size = UDim2.fromScale(1, 0),
										AutomaticSize = Enum.AutomaticSize.Y,
										TextWrapped = false,
									},
									Text {
										Name = "Body",
										Text = Scope:Computed(function(Use)
											if Use(CurrentPrompt) and Use(CurrentPrompt).Text then
												return Use(CurrentPrompt).Text
											else
												return "Prompt body text"
											end
										end),
										Size = Scope:Computed(function(Use)
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
								Visible = Scope:Computed(function(Use)
									return #Use(Buttons) >= 1
								end),
								ListEnabled = true,
								ListFillDirection = Enum.FillDirection.Horizontal,
								ListHorizontalAlignment = Enum.HorizontalAlignment.Right,

								[Children] = {
									Scope:ForValues((Buttons, function(PromptButton)
										return Button {
											Contents = PromptButton.Contents,
											Style = PromptButton.Style,
											Color = PromptButton.Color,
											Disabled = PromptButton.Disabled,

											OnActivated = function()
												Prompts:RemovePrompt(Use(CurrentPrompt))

												if PromptButton.Callback then
													PromptButton.Callback()
												end
											end,
										}
									end),
								},
							},
						},
					},
				},
			},
		},
	}
end
