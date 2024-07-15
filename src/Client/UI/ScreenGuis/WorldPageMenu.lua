local MarketplaceService = game:GetService("MarketplaceService")

local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent)
local Future = require(script.Parent.Parent.Parent.Parent.Parent.Parent.Future)
local OnyxUI = require(RoRooms.Packages.OnyxUI)
local Fusion = require(OnyxUI.Parent.Fusion)
local States = require(RoRooms.Client.UI.States)
local Prompts = require(RoRooms.Client.UI.States.Prompts)
local Themer = require(OnyxUI.Utils.Themer)
local Modifier = require(OnyxUI.Utils.Modifier)

local Children = Fusion.Children
local Computed = Fusion.Computed
local New = Fusion.New
local Spring = Fusion.Spring
local Value = Fusion.Value
local Observer = Fusion.Observer
local Cleanup = Fusion.Cleanup

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
	local PlaceInfo = Value({})

	local function UpdatePlaceInfo()
		if States.WorldPageMenu.PlaceId:get() == nil then
			return
		end

		Future.Try(function()
			return MarketplaceService:GetProductInfo(States.WorldPageMenu.PlaceId:get())
		end):After(function(Success, Result)
			if Success then
				PlaceInfo:set(Result)
			else
				warn(Result)
			end
		end)
	end

	local Observers = {
		Observer(States.WorldPageMenu.PlaceId):onChange(UpdatePlaceInfo),
	}
	UpdatePlaceInfo()

	local WorldPageMenu = New "ScreenGui" {
		Name = "WorldPageMenu",
		Parent = Props.Parent,
		Enabled = MenuOpen,
		ResetOnSpawn = false,

		[Cleanup] = { Observers },

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
						BackgroundTransparency = States.PreferredTransparency,

						[Children] = {
							Modifier.ListLayout {},

							TitleBar {
								Title = "World",
								CloseButtonDisabled = true,
							},
							Frame {
								Name = "Contents",
								Size = UDim2.fromScale(1, 0),
								AutomaticSize = Enum.AutomaticSize.Y,

								[Children] = {
									Modifier.ListLayout {
										Padding = Computed(function()
											return UDim.new(0, Themer.Theme.Spacing["1"]:get())
										end),
									},

									Image {
										Name = "Thumbnail",
										Image = Computed(function()
											if PlaceInfo:get() and PlaceInfo:get().IconImageAssetId then
												return `rbxassetid://{PlaceInfo:get().IconImageAssetId}`
											else
												return "rbxasset://textures/ui/GuiImagePlaceholder.png"
											end
										end),
										Size = UDim2.new(UDim.new(1, 0), UDim.new(0, 80)),
										ScaleType = Enum.ScaleType.Crop,

										[Children] = {
											Modifier.Corner {},
										},
									},
									Frame {
										Name = "Details",
										Size = UDim2.fromScale(1, 0),
										AutomaticSize = Enum.AutomaticSize.Y,

										[Children] = {
											Modifier.ListLayout {},

											Text {
												Name = "Name",
												Size = UDim2.fromScale(1, 0),
												AutomaticSize = Enum.AutomaticSize.Y,
												Text = Computed(function()
													if PlaceInfo:get() and PlaceInfo:get().Name then
														return PlaceInfo:get().Name
													else
														return "Name"
													end
												end),
												TextSize = Themer.Theme.TextSize["1.5"],
												FontFace = Computed(function()
													return Font.new(
														Themer.Theme.Font.Heading:get(),
														Themer.Theme.FontWeight.Heading:get()
													)
												end),
												TextTruncate = Enum.TextTruncate.AtEnd,
												RichText = false,
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
												Size = UDim2.fromScale(1, 0),
												AutomaticSize = Enum.AutomaticSize.Y,
												TextTruncate = Enum.TextTruncate.AtEnd,
												TextWrapped = true,
												RichText = false,
												AutoLocalize = false,

												[Children] = {
													Modifier.SizeConstraint {
														MaxSize = Computed(function()
															return Vector2.new(
																math.huge,
																Themer.Theme.TextSize["1"]:get() * 2
															)
														end),
													},
												},
											},
										},
									},
									Button {
										Name = "PlayButton",
										Size = UDim2.fromScale(1, 0),
										AutomaticSize = Enum.AutomaticSize.Y,
										Contents = { "rbxassetid://17293685944" },
										ContentSize = Themer.Theme.TextSize["1.5"],

										OnActivated = function()
											if States.Services.WorldsService then
												States.Services.WorldsService
													:TeleportToWorld(States.WorldPageMenu.PlaceId:get())
													:andThen(function(Success: boolean, Message: string)
														States.CurrentMenu:set(nil)

														if not Success then
															Prompts:PushPrompt({
																Title = "Error",
																Text = Message,
																Buttons = {
																	{
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
			},
		},
	}

	return WorldPageMenu
end
