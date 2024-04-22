local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent)

local Shared = RoRooms.Shared
local Config = RoRooms.Config
local Client = RoRooms.Client

local Fusion = require(Shared.ExtPackages.OnyxUI.Packages.Fusion)
local OnyxUI = require(Shared.ExtPackages.OnyxUI)
local EnsureProp = require(OnyxUI.Utils.EnsureProp)

local Children = Fusion.Children
local New = Fusion.New
local Computed = Fusion.Computed

local Frame = require(OnyxUI.Components.Frame)
local Text = require(OnyxUI.Components.Text)
local ItemButton = require(Client.UI.Components.ItemButton)

return function(Props: table)
	Props.CategoryName = EnsureProp(Props.CategoryName, "string", "Category")

	local Category = Computed(function()
		return Config.ItemsSystem.Categories[Props.CategoryName:get()]
	end)

	local ItemButtons = Computed(function()
		local List = {}

		for ItemId, Item in pairs(Config.ItemsSystem.Items) do
			if Item.Category == nil then
				Item.Category = "General"
			end
			if Item.Category == Props.CategoryName:get() then
				table.insert(
					List,
					ItemButton {
						ItemId = ItemId,
						Item = Item,
						BaseColor3 = Item.TintColor,
						-- Callback = function()
						--   if States.ScreenSize:get().Y <= 500 then
						--     States.CurrentMenu:set()
						--   end
						-- end
					}
				)
			end
		end

		return List
	end, Fusion.cleanup)

	return Frame {
		Name = `{Props.CategoryName:get()}ItemsCategory`,
		Size = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		LayoutOrder = Computed(function()
			if Category:get() then
				return Category:get().LayoutOrder
			else
				return 0
			end
		end),

		[Children] = {
			New "UIListLayout" {
				Padding = UDim.new(0, 8),
				SortOrder = Enum.SortOrder.LayoutOrder,
			},
			Text {
				Text = Props.CategoryName,
				TextSize = 20,
			},
			Frame {
				Name = "Items",
				Size = UDim2.fromScale(1, 0),
				AutomaticSize = Enum.AutomaticSize.Y,

				[Children] = {
					New "UIListLayout" {
						SortOrder = Enum.SortOrder.LayoutOrder,
						Padding = UDim.new(0, 12),
						FillDirection = Enum.FillDirection.Horizontal,
						Wraps = true,
					},
					ItemButtons,
				},
			},
		},
	}
end
