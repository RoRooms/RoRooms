local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent)
local OnyxUI = require(RoRooms.Packages.OnyxUI)
local Fusion = require(RoRooms.Packages.Fusion)
local States = require(RoRooms.Client.UI.States)

local Children = Fusion.Children
local Util = OnyxUI.Util
local Themer = OnyxUI.Themer
local Peek = Fusion.peek

local ItemsCategory = require(RoRooms.Client.UI.Components.ItemsCategory)
local ItemCategoriesSidebar = require(RoRooms.Client.UI.Components.ItemCategoriesSidebar)

return function(Scope: Fusion.Scope<any>, Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components)
	local Theme = Themer.Theme:now()

	local ItemsMenu = Scope:New "ScreenGui" {
		Name = "ItemsMenu",
		Parent = Props.Parent,
		ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets,
		Enabled = States.ItemsMenu.Open,
		ResetOnSpawn = false,

		[Children] = {
			Scope:AutoScaleFrame {
				AnchorPoint = Vector2.new(0.5, 1),
				Position = Scope:Spring(
					Scope:Computed(function(Use)
						local YPos = 68 + 15
						if not Use(States.ItemsMenu.Open) then
							YPos -= 15
						end
						return UDim2.new(UDim.new(0.5, 0), UDim.new(1, -YPos))
					end),
					Theme.SpringSpeed["1"],
					Theme.SpringDampening["1"]
				),
				BaseResolution = Vector2.new(739, 789),
				MinScale = 1,
				MaxScale = 1,

				[Children] = {
					Scope:MenuFrame {
						Size = UDim2.fromOffset(385, 0),
						AutomaticSize = Enum.AutomaticSize.Y,
						GroupTransparency = Scope:Spring(
							Scope:Computed(function(Use)
								if Use(States.ItemsMenu.Open) then
									return 0
								else
									return 1
								end
							end),
							Theme.SpringSpeed["1"],
							Theme.SpringDampening["1"]
						),
						BackgroundTransparency = States.PreferredTransparency,
						ListEnabled = true,
						ListFillDirection = Enum.FillDirection.Horizontal,

						[Children] = {
							Scope:ItemCategoriesSidebar {
								Size = UDim2.fromScale(0, 1),
							},
							Scope:Scroller {
								Name = "Items",
								Size = UDim2.new(UDim.new(1, 0), UDim.new(0, 220)),
								ScrollBarThickness = Theme.StrokeThickness["1"],
								ScrollBarImageColor3 = Theme.Util.Colors.NeutralContent.Dark,
								Padding = Scope:Computed(function(Use)
									return UDim.new(0, Use(Theme.StrokeThickness["1"]))
								end),
								ListEnabled = true,
								ListPadding = Scope:Computed(function(Use)
									return UDim.new(0, Use(Theme.Spacing["0.75"]))
								end),

								[Children] = {
									Scope:ForPairs(
										RoRooms.Config.Systems.Items.Categories,
										function(Name: string, Category)
											return Name,
												Scope:ItemsCategory {
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
			},
		},
	}

	local DisconnectOpen = Scope:Observer(States.ItemsMenu.Open):onChange(function()
		local TextClasses = { "TextLabel", "TextButton", "TextBox" }
		if Peek(States.ItemsMenu.Open) then
			if Peek(States.ScreenSize).Y < 1000 then
				States.CurrentMenu:set()
			end
		end
		for _, Descendant in ipairs(ItemsMenu:GetDescendants()) do
			if table.find(TextClasses, Descendant.ClassName) then
				task.wait()
			end
		end
	end)

	local DisconnectFocusedCategory = Scope:Observer(States.ItemsMenu.FocusedCategory):onChange(function()
		local Items = ItemsMenu.AutoScaleFrame.MenuFrame.Contents.Items
		local Category = Items:FindFirstChild(`{Peek(States.ItemsMenu.FocusedCategory)}ItemsCategory`)
		if Category then
			Items.CanvasPosition = Vector2.new(0, 0)
			Items.CanvasPosition = Vector2.new(0, Category.AbsolutePosition.Y - Items.AbsolutePosition.Y)
		end
	end)

	ItemsMenu:GetPropertyChangedSignal("Parent"):Connect(function()
		if ItemsMenu.Parent == nil then
			DisconnectOpen()
			DisconnectFocusedCategory()
		end
	end)

	return ItemsMenu
end
