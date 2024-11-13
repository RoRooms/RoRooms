local Rorooms = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(Rorooms.Parent.OnyxUI)
local Fusion = require(Rorooms.Parent.Fusion)
local States = require(Rorooms.SourceCode.Client.UI.States)
local Config = require(Rorooms.Config).Config
local Components = require(Rorooms.SourceCode.Client.UI.Components)

local Children = Fusion.Children
local Themer = OnyxUI.Themer
local Peek = Fusion.peek

return function(Scope: Fusion.Scope<any>, Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components, Components)
	local Theme = Themer.Theme:now()

	local ItemsMenu = Scope:Menu {
		Name = script.Name,
		Open = States.Menus.ItemsMenu.Open,
		Parent = Props.Parent,
		AutomaticSize = Enum.AutomaticSize.X,
		Size = UDim2.fromOffset(0, 220),
		AnchorPoint = Vector2.new(0.5, 1),
		Position = Scope:Computed(function(Use)
			local YPos = 68 + 15
			if not Use(States.Menus.ItemsMenu.Open) then
				YPos -= 15
			end
			return UDim2.new(UDim.new(0.5, 0), UDim.new(1, -YPos))
		end),
		ListFillDirection = Enum.FillDirection.Horizontal,
		ListVerticalFlex = Enum.UIFlexAlignment.Fill,

		[Children] = {
			Scope:ItemCategoriesSidebar {},
			Scope:Scroller {
				Name = "Items",
				Size = Scope:Computed(function(Use)
					return UDim2.fromOffset(252, 0)
				end),
				Padding = Scope:Computed(function(Use)
					return UDim.new(0, Use(Theme.StrokeThickness["1"]))
				end),
				PaddingRight = Scope:Computed(function(Use)
					return UDim.new(0, Use(Theme.Spacing["1"]))
				end),
				ListEnabled = true,
				ListPadding = Scope:Computed(function(Use)
					return UDim.new(0, Use(Theme.Spacing["0.75"]))
				end),
				ScrollBarThickness = Theme.StrokeThickness["1"],

				[Children] = {
					Scope:ForPairs(Config.Systems.Items.Categories, function(Use, Scope, Name: string, Category)
						return Name,
							Scope:ItemsCategory {
								Name = Name,
								CategoryName = Name,
								LayoutOrder = Category.LayoutOrder,
							}
					end),
				},
			},
		},
	}

	Scope:Observer(States.Menus.ItemsMenu.Open):onChange(function()
		local TextClasses = { "TextLabel", "TextButton", "TextBox" }
		if Peek(States.Menus.ItemsMenu.Open) then
			if Peek(States.CoreGui.ScreenSize).Y < 1000 then
				States.Menus.CurrentMenu:set()
			end
		end
		for _, Descendant in ipairs(ItemsMenu:GetDescendants()) do
			if table.find(TextClasses, Descendant.ClassName) then
				task.wait()
			end
		end
	end)

	local ItemsList = ItemsMenu.MenuFrame.Items
	Scope:Observer(States.Menus.ItemsMenu.FocusedCategory):onChange(function()
		local Category = ItemsList:FindFirstChild(`{Peek(States.Menus.ItemsMenu.FocusedCategory)}`)
		if Category then
			ItemsList.CanvasPosition = Vector2.new(0, 0)
			ItemsList.CanvasPosition = Vector2.new(0, Category.AbsolutePosition.Y - ItemsList.AbsolutePosition.Y)
		end
	end)

	return ItemsMenu
end
