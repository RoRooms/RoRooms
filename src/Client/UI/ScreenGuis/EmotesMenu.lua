local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent)

local Shared = RoRooms.Shared
local Client = RoRooms.Client
local Config = RoRooms.Config

local NekaUI = require(Shared.ExtPackages.NekaUI)
local Fusion = require(NekaUI.Packages.Fusion)
local States = require(Client.UI.States)
local AutomaticSizer = require(NekaUI.Utils.AutomaticSizer)

local Children = Fusion.Children
local New = Fusion.New
local Computed = Fusion.Computed
local Spring = Fusion.Spring
local Observer = Fusion.Observer
local ForValues = Fusion.ForValues

local AutoScaleFrame = require(NekaUI.Components.AutoScaleFrame)
local MenuFrame = require(NekaUI.Components.MenuFrame)
local TitleBar = require(NekaUI.Components.TitleBar)
local ScrollingFrame = require(NekaUI.Components.ScrollingFrame)
local EmotesCategory = require(Client.UI.Components.EmotesCategory)

return function(Props)
	local MenuOpen = Computed(function()
		return States.CurrentMenu:get() == script.Name
	end)

	local Categories = Computed(function()
		local CategoriesList = {}

		for _, Emote in pairs(Config.EmotesSystem.Emotes) do
			local CategoryName
			if typeof(Emote.Category) == "string" then
				CategoryName = Emote.Category
			elseif Emote.Category == nil then
				CategoryName = "General"
			end
			if not table.find(CategoriesList, CategoryName) then
				table.insert(CategoriesList, CategoryName)
			end
		end

		return CategoriesList
	end)

	local EmotesMenu = New "ScreenGui" {
		Name = "EmotesMenu",
		Parent = Props.Parent,
		Enabled = MenuOpen,
		ResetOnSpawn = false,

		[Children] = {
			AutoScaleFrame {
				AnchorPoint = Vector2.new(0.5, 0),
				Position = Spring(
					Computed(function()
						local YPos = States.TopbarBottomPos:get()
						if not MenuOpen:get() then
							YPos = YPos + 15
						end
						return UDim2.new(UDim.new(0.5, 0), UDim.new(0, YPos))
					end),
					37,
					1
				),
				BaseResolution = Vector2.new(883, 893),

				[Children] = {
					New "UIListLayout" {},
					MenuFrame {
						Size = UDim2.fromOffset(360, 0),
						GroupTransparency = Spring(
							Computed(function()
								if MenuOpen:get() then
									return 0
								else
									return 1
								end
							end),
							40,
							1
						),

						[Children] = {
							New "UIPadding" {
								PaddingBottom = UDim.new(0, 11),
								PaddingLeft = UDim.new(0, 11),
								PaddingRight = UDim.new(0, 11),
								PaddingTop = UDim.new(0, 9),
							},
							TitleBar {
								Title = "Emotes",
								CloseButtonDisabled = true,
								TextSize = 24,
							},
							ScrollingFrame {
								Name = "EmotesList",
								Size = UDim2.new(UDim.new(1, 0), UDim.new(0, 200)),

								[Children] = {
									New "UIPadding" {
										PaddingLeft = UDim.new(0, 2),
										PaddingBottom = UDim.new(0, 2),
										PaddingTop = UDim.new(0, 2),
										PaddingRight = UDim.new(0, 2),
									},
									New "UIListLayout" {
										SortOrder = Enum.SortOrder.LayoutOrder,
										Padding = UDim.new(0, 15),
									},
									ForValues(Categories, function(CategoryName: string)
										return EmotesCategory {
											CategoryName = CategoryName,
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

	local DisconnectOpen = Observer(MenuOpen):onChange(function()
		local TextClasses = { "TextLabel", "TextButton", "TextBox" }
		for _, Descendant in ipairs(EmotesMenu:GetDescendants()) do
			if table.find(TextClasses, Descendant.ClassName) then
				task.wait()
				AutomaticSizer.ApplyLayout(Descendant)
			end
		end
	end)

	EmotesMenu:GetPropertyChangedSignal("Parent"):Connect(function()
		if EmotesMenu.Parent == nil then
			DisconnectOpen()
		end
	end)

	return EmotesMenu
end
