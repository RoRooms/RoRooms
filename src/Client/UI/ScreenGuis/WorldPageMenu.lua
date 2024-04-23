local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent)
local MarketplaceService = game:GetService("MarketplaceService")

local Shared = RoRooms.Shared
local Client = RoRooms.Client

local OnyxUI = require(Shared.ExtPackages.OnyxUI)
local Fusion = require(OnyxUI._Packages.Fusion)
local States = require(Client.UI.States)
local Prompts = require(Client.UI.States.Prompts)
local Themer = require(OnyxUI.Utils.Themer)
local Modifier = require(OnyxUI.Utils.Modifier)

local Children = Fusion.Children
local Computed = Fusion.Computed
local New = Fusion.New
local Spring = Fusion.Spring

local AutoScaleFrame = require(OnyxUI.Components.AutoScaleFrame)
local MenuFrame = require(OnyxUI.Components.MenuFrame)
local TitleBar = require(OnyxUI.Components.TitleBar)
local Text = require(OnyxUI.Components.Text)
local Button = require(OnyxUI.Components.Button)
local Frame = require(OnyxUI.Components.Frame)
local Image = require(OnyxUI.Components.Image)

return function(Props)
	local MenuOpen = Computed(function()
		return States.CurrentMenu:get() == script.Name
	end)
	local PlaceInfo = Computed(function()
		if States.WorldPageMenu.PlaceId:get() then
			local Success, Result = pcall(function()
				return MarketplaceService:GetProductInfo(States.WorldPageMenu.PlaceId:get())
			end)
			if Success then
				return Result
			else
				warn(Result)
			end
		end
	end)

	local WorldPageMenu = New "ScreenGui" {
		Name = "WorldPageMenu",
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
					Themer.Theme.SpringSpeed["1"],
					Themer.Theme.SpringDampening
				),
				BaseResolution = Vector2.new(739, 789),

				[Children] = {
					MenuFrame {
						Size = UDim2.fromOffset(353, 0),
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
							Modifier.Padding {
								Padding = Computed(function()
									return UDim.new(0, Themer.Theme.Spacing["1"]:get())
								end),
							},

							TitleBar {
								Title = "World",
								CloseButtonDisabled = true,
							},
							Image {
								Name = "Thumbnail",
								Image = Computed(function()
									if PlaceInfo:get() then
										return `rbxassetid://{PlaceInfo:get().IconImageAssetId}`
									else
										return "rbxasset://textures/ui/GuiImagePlaceholder.png"
									end
								end),
								Size = UDim2.new(UDim.new(1, 0), UDim.new(0, 80)),
								ScaleType = Enum.ScaleType.Crop,

								[Children] = {
									Modifier.Corner {
										CornerRadius = Computed(function()
											return UDim.new(0, Themer.Theme.CornerRadius["2"]:get())
										end),
									},
								},
							},
							Frame {
								Name = "WorldInfo",
								Size = UDim2.fromScale(1, 0),
								AutomaticSize = Enum.AutomaticSize.Y,

								[Children] = {
									Modifier.ListLayout {},

									Text {
										Size = UDim2.fromScale(1, 0),
										AutomaticSize = Enum.AutomaticSize.Y,
										Text = Computed(function()
											if PlaceInfo:get() and PlaceInfo:get().Name then
												return PlaceInfo:get().Name
											else
												return "World Name"
											end
										end),
										TextSize = 25,
										TextTruncate = Enum.TextTruncate.AtEnd,
										RichText = true,
										AutoLocalize = false,
									},
									Text {
										Name = "Description",
										Text = Computed(function()
											if PlaceInfo:get() and PlaceInfo:get().Description then
												return PlaceInfo:get().Description
											else
												return "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
											end
										end),
										TextWrapped = true,
										RichText = true,
										Size = UDim2.new(UDim.new(1, 0), UDim.new(0, 35)),
										AutomaticSize = Enum.AutomaticSize.None,
										TextTruncate = Enum.TextTruncate.AtEnd,
										AutoLocalize = false,
									},
								},
							},
							Button {
								Name = "PlayButton",
								Size = UDim2.fromScale(1, 0),
								AutomaticSize = Enum.AutomaticSize.Y,
								Contents = { "rbxassetid://10392248278" },
								ContentSize = 25,
								Style = "Filled",

								OnActivated = function()
									if States.WorldsService then
										States.WorldsService
											:TeleportToWorld(States.WorldPageMenu.PlaceId:get())
											:andThen(function(Success: boolean, Message: string)
												States.CurrentMenu:set(nil)
												if not Success then
													Prompts:PushPrompt({
														Title = "Error",
														Text = Message,
														Buttons = {
															{
																Primary = false,
																Contents = { "Dismiss" },
															},
														},
													})
												end
											end)
									end
								end,
							},
						},
					},
				},
			},
		},
	}

	return WorldPageMenu
end
