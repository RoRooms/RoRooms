local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent)

local Shared = RoRooms.Shared
local Client = RoRooms.Client
local Config = RoRooms.Config

local OnyxUI = require(Shared.ExtPackages.OnyxUI)
local Fusion = require(OnyxUI._Packages.Fusion)
local States = require(Client.UI.States)
local Themer = require(OnyxUI.Utils.Themer)
local Modifier = require(OnyxUI.Utils.Modifier)

local Children = Fusion.Children
local New = Fusion.New
local Computed = Fusion.Computed
local Spring = Fusion.Spring
local Observer = Fusion.Observer
local ForPairs = Fusion.ForPairs

local AutoScaleFrame = require(OnyxUI.Components.AutoScaleFrame)
local MenuFrame = require(OnyxUI.Components.MenuFrame)
local ScrollingFrame = require(OnyxUI.Components.ScrollingFrame)
local ItemsCategory = require(Client.UI.Components.ItemsCategory)
local ItemCategoriesSidebar = require(Client.UI.Components.ItemCategoriesSidebar)

return function(Props)
	local ItemsMenu = New "ScreenGui" {
		Name = "ItemsMenu",
		Parent = Props.Parent,
		ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets,
		Enabled = States.ItemsMenu.Open,
		ResetOnSpawn = false,

		[Children] = {
			AutoScaleFrame {
				AnchorPoint = Vector2.new(0.5, 1),
				Position = Spring(
					Computed(function()
						local YPos = 68 + 15
						if not States.ItemsMenu.Open:get() then
							YPos -= 15
						end
						return UDim2.new(UDim.new(0.5, 0), UDim.new(1, -YPos))
					end),
					Themer.Theme.SpringSpeed["1"],
					Themer.Theme.SpringDampening
				),
				BaseResolution = Vector2.new(739, 789),
				ScaleClamps = { Min = 1, Max = 1 },

				[Children] = {
					MenuFrame {
						Size = UDim2.fromOffset(385, 0),
						GroupTransparency = Spring(
							Computed(function()
								if States.ItemsMenu.Open:get() then
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
								FillDirection = Enum.FillDirection.Horizontal,
							},

							ItemCategoriesSidebar {
								Size = UDim2.fromScale(0, 1),
							},
							ScrollingFrame {
								Name = "Items",
								Size = UDim2.new(UDim.new(1, 0), UDim.new(0, 220)),
								ScrollBarThickness = Themer.Theme.StrokeThickness["1"],
								ScrollBarImageColor3 = Themer.Theme.Colors.NeutralContent.Dark,

								[Children] = {
									Modifier.Padding {
										Padding = Computed(function()
											return UDim.new(0, Themer.Theme.StrokeThickness["1"]:get())
										end),
									},
									Modifier.ListLayout {
										Padding = Computed(function()
											return UDim.new(0, Themer.Theme.Spacing["1"]:get())
										end),
									},

									ForPairs(Config.ItemsSystem.Categories, function(Name: string, Category)
										return Name,
											ItemsCategory {
												CategoryName = Name,
												LayoutOrder = Category.LayoutOrder,
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

	local DisconnectOpen = Observer(States.ItemsMenu.Open):onChange(function()
		local TextClasses = { "TextLabel", "TextButton", "TextBox" }
		if States.ItemsMenu.Open:get() then
			if States.ScreenSize:get().Y < 1000 then
				States.CurrentMenu:set()
			end
		end
		for _, Descendant in ipairs(ItemsMenu:GetDescendants()) do
			if table.find(TextClasses, Descendant.ClassName) then
				task.wait()
			end
		end
	end)

	local DisconnectFocusedCategory = Observer(States.ItemsMenu.FocusedCategory):onChange(function()
		local Items = ItemsMenu.AutoScaleFrame.MenuFrame.Contents.Items
		local Category = Items.Contents:FindFirstChild(`{States.ItemsMenu.FocusedCategory:get()}ItemsCategory`)
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
