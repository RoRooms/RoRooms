local RoRooms = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(RoRooms.Parent.OnyxUI)
local Fusion = require(RoRooms.Parent.Fusion)
local States = require(RoRooms.SourceCode.Client.UI.States)
local Prompts = require(RoRooms.SourceCode.Client.UI.States.Prompts)
local Components = require(RoRooms.SourceCode.Client.UI.Components)
local OnyxUITheme = require(RoRooms.SourceCode.Client.UI.OnyxUITheme)

local Children = Fusion.Children
local Themer = OnyxUI.Themer
local Peek = Fusion.peek

return function(Scope: Fusion.Scope<any>, Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components, Components)
	local Theme = Themer.Theme:now()

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

	return Scope:Menu {
		Name = script.Name,
		Parent = Props.Parent,
		Open = PromptOpen,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		Size = Scope:Computed(function(Use)
			return UDim2.fromOffset(Use(Theme.Spacing["16"]) * 1.25, 0)
		end),
		AutomaticSize = Enum.AutomaticSize.Y,
		ListHorizontalFlex = Enum.UIFlexAlignment.Fill,

		[Children] = {
			Scope:Frame {
				Name = "Details",
				AutomaticSize = Enum.AutomaticSize.Y,
				ListEnabled = true,
				ListHorizontalFlex = Enum.UIFlexAlignment.Fill,
				ListPadding = Scope:Computed(function(Use)
					return UDim.new(0, Use(Theme.Spacing["0.5"]))
				end),

				[Children] = {
					Scope:Text {
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
						AutomaticSize = Enum.AutomaticSize.Y,
						TextWrapped = false,
					},
					Scope:Text {
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
			Scope:Frame {
				Name = "Buttons",
				AutomaticSize = Enum.AutomaticSize.Y,
				Visible = Scope:Computed(function(Use)
					return #Use(Buttons) >= 1
				end),
				ListEnabled = true,
				ListFillDirection = Enum.FillDirection.Horizontal,
				ListHorizontalAlignment = Enum.HorizontalAlignment.Right,

				[Children] = {
					Themer.Theme:is(OnyxUITheme):during(function()
						local Theme = Themer.Theme:now()

						return Scope:ForValues(Buttons, function(Use, Scope, PromptButton)
							return Scope:Button {
								Content = PromptButton.Content,
								Style = PromptButton.Style,
								Color = Scope:Computed(function(Use)
									if PromptButton.Color == nil then
										return Use(Theme.Colors.Primary.Main)
									else
										return PromptButton.Color
									end
								end),
								Disabled = PromptButton.Disabled,

								OnActivated = function()
									Prompts:RemovePrompt(Peek(CurrentPrompt))

									if PromptButton.Callback then
										PromptButton.Callback()
									end
								end,
							}
						end)
					end),
				},
			},
		},
	}
end
