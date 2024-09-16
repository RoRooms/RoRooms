local RoRooms = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(RoRooms.Parent.OnyxUI)
local Fusion = require(RoRooms.Parent.Fusion)
local States = require(RoRooms.SourceCode.Client.UI.States)
local Config = require(RoRooms.Config).Config
local Components = require(RoRooms.SourceCode.Client.UI.Components)

local Children = Fusion.Children
local Themer = OnyxUI.Themer
local Peek = Fusion.peek

return function(Scope: Fusion.Scope<any>, Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components, Components)
	local Theme = Themer.Theme:now()

	local MenuOpen = Scope:Computed(function(Use)
		return Use(States.CurrentMenu) == script.Name
	end)

	local EmotesMenu = Scope:Menu {
		Name = script.Name,
		Open = MenuOpen,
		Parent = Props.Parent,
		AutomaticSize = Enum.AutomaticSize.XY,

		[Children] = {
			Scope:TitleBar {
				Title = "Emotes",
				CloseButtonDisabled = true,
			},
			Scope:Frame {
				Size = UDim2.new(UDim.new(0, 0), UDim.new(0, 185)),
				AutomaticSize = Enum.AutomaticSize.X,
				ListEnabled = true,
				ListFillDirection = Enum.FillDirection.Horizontal,
				ListPadding = Scope:Computed(function(Use)
					return UDim.new(0, Use(Theme.Spacing["0.75"]))
				end),

				[Children] = {
					Scope:EmoteCategoriesSidebar {
						Size = UDim2.fromScale(0, 1),
					},
					Scope:Scroller {
						Name = "EmotesList",
						Size = Scope:Computed(function(Use)
							return UDim2.new(UDim.new(0, 260), UDim.new(1, 0))
						end),
						ScrollBarThickness = Theme.StrokeThickness["1"],
						ScrollBarImageColor3 = Theme.Colors.NeutralContent.Dark,
						Padding = Scope:Computed(function(Use)
							return UDim.new(0, Use(Theme.StrokeThickness["1"]))
						end),
						ListEnabled = true,
						ListPadding = Scope:Computed(function(Use)
							return UDim.new(0, Use(Theme.Spacing["1"]))
						end),
						ListFillDirection = Enum.FillDirection.Horizontal,
						ListWraps = true,

						[Children] = {
							Scope:ForPairs(
								Config.Systems.Emotes.Categories,
								function(Use, Scope, Name: string, Category)
									return Name,
										Scope:EmotesCategory {
											CategoryName = Name,
											LayoutOrder = Category.LayoutOrder,
										}
								end
							),
						},
					},
				},
			},
		},
	}

	Scope:Observer(States.EmotesMenu.FocusedCategory):onChange(function()
		local EmotesList = EmotesMenu.AutoScaleFrame.MenuFrame.Contents.Frame.EmotesList
		local Category = EmotesList:FindFirstChild(`{Peek(States.EmotesMenu.FocusedCategory)}EmotesCategory`)
		if Category then
			EmotesList.CanvasPosition = Vector2.new(0, 0)
			EmotesList.CanvasPosition = Vector2.new(0, Category.AbsolutePosition.Y - EmotesList.AbsolutePosition.Y)
		end
	end)

	return EmotesMenu
end
