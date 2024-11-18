local MarketplaceService = game:GetService("MarketplaceService")

local Rorooms = script.Parent.Parent.Parent.Parent
local Knit = require(Rorooms.Parent.Knit)
local Topbar = require(Rorooms.SourceCode.Client.UI.States.Topbar)
local UIController = require(Rorooms.SourceCode.Client.UI.UIController)
local Prompts = require(Rorooms.SourceCode.Client.UI.States.Prompts)
local States = require(Rorooms.SourceCode.Client.UI.States)
local Future = require(Rorooms.Parent.Future)

local WorldRegistryService

local WorldsController = {
	Name = "WorldsController",
}

function WorldsController:TeleportToWorld(PlaceId: number, JobId: string?, RequireConfirmation: boolean?)
	return Future.Try(function()
		return MarketplaceService:GetProductInfo(PlaceId, Enum.InfoType.Asset)
	end):After(function(FetchSuccess, PlaceInfo)
		if FetchSuccess and (PlaceInfo ~= nil) then
			local function Teleport()
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
			end
			local function AskConfirmation()
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
								Teleport()
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
								Teleport()
							end,
						},
					},
				})
			else
				if RequireConfirmation then
					AskConfirmation()
				else
					Teleport()
				end
			end
		end
	end)
end

function WorldsController:KnitStart()
	UIController = Knit.GetController("UIController")
	WorldRegistryService = Knit.GetService("WorldRegistryService")

	UIController:MountUI(require(Rorooms.SourceCode.Client.UI.ScreenGuis.WorldsMenu))
	UIController:MountUI(require(Rorooms.SourceCode.Client.UI.ScreenGuis.WorldPageMenu))

	Topbar:AddTopbarButton("Worlds", Topbar.NativeButtons.Worlds)

	WorldRegistryService.Registered:Observe(function(Registered: boolean)
		States.Worlds.Registered:set(Registered)
	end)
end

return WorldsController
