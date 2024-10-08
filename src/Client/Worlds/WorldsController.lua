local MarketplaceService = game:GetService("MarketplaceService")

local RoRooms = script.Parent.Parent.Parent.Parent
local Knit = require(RoRooms.Parent.Knit)
local Topbar = require(RoRooms.SourceCode.Client.UI.States.Topbar)
local UIController = require(RoRooms.SourceCode.Client.UI.UIController)
local Prompts = require(RoRooms.SourceCode.Client.UI.States.Prompts)
local States = require(RoRooms.SourceCode.Client.UI.States)
local Future = require(RoRooms.Parent.Future)

local WorldsController = {
	Name = "WorldsController",
}

function WorldsController:TeleportToWorld(PlaceId: number, JobId: string?)
	return Future.Try(function()
		return MarketplaceService:GetProductInfo(PlaceId, Enum.InfoType.Asset)
	end):After(function(FetchSuccess, PlaceInfo)
		if FetchSuccess and (PlaceInfo ~= nil) then
			local function Proceed()
				Prompts:PushPrompt({
					Title = "Teleport",
					Text = `Do you want to teleport to {PlaceInfo.Name}?`,
					Buttons = {
						{
							Content = { "Cancel" },
							Style = "Outlined",
						},
						{
							Content = { "Teleport" },
							Callback = function()
								if next(States.Services.WorldsService) ~= nil then
									States.Services.WorldsService
										:TeleportToWorld(PlaceId)
										:andThen(function(TeleportSuccess: boolean, Message: string)
											States.Menus.CurrentMenu:set(nil)

											if not TeleportSuccess then
												Prompts:PushPrompt({
													Title = "Error",
													Text = Message,
													Buttons = {
														{
															Content = { "Dismiss" },
														},
													},
												})
											end
										end)
								end
							end,
						},
					},
				})
			end

			if (JobId ~= nil) and (JobId == game.JobId) then
				Prompts:PushPrompt({
					Title = "Rejoin",
					Text = "You're already in this server. Would you like to rejoin?",
					Buttons = {
						{
							Content = { "Cancel" },
							Style = "Outlined",
						},
						{
							Content = { "Teleport" },
							Callback = function()
								Proceed()
							end,
						},
					},
				})

				return
			end

			Proceed()
		end
	end)
end

function WorldsController:KnitStart()
	UIController = Knit.GetController("UIController")

	UIController:MountUI(require(RoRooms.SourceCode.Client.UI.ScreenGuis.WorldsMenu))
	UIController:MountUI(require(RoRooms.SourceCode.Client.UI.ScreenGuis.WorldPageMenu))

	Topbar:AddTopbarButton("Worlds", Topbar.NativeButtons.Worlds)
end

return WorldsController
