local MarketplaceService = game:GetService("MarketplaceService")

local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent)
local Future = require(script.Parent.Parent.Parent.Parent.Parent.Parent.Future)
local OnyxUI = require(RoRooms.Packages.OnyxUI)
local Fusion = require(RoRooms.Packages.Fusion)
local States = require(RoRooms.Client.UI.States)
local Prompts = require(RoRooms.Client.UI.States.Prompts)

local Children = Fusion.Children

local AutoScaleFrame = require(OnyxUI.Components.AutoScaleFrame)
local MenuFrame = require(OnyxUI.Components.MenuFrame)
local TitleBar = require(OnyxUI.Components.TitleBar)
local Text = require(OnyxUI.Components.Text)
local Button = require(OnyxUI.Components.Button)
local Frame = require(OnyxUI.Components.Frame)
local Image = require(OnyxUI.Components.Image)

return function(Scope: Fusion.Scope<any>, Props)
	local MenuOpen = Scope:Computed(function(Use)
		return Use(States.CurrentMenu) == script.Name
	end)
	local PlaceInfo = Scope:Value({})

	local function UpdatePlaceInfo()
		if Use(States.WorldPageMenu.PlaceId) == nil then
			return
		end

		Future.Try(function()
			return MarketplaceService:GetProductInfo(Use(States.WorldPageMenu.PlaceId))
		end):After(function(Success, Result)
			if Success then
				PlaceInfo:set(Result)
			else
				warn(Result)
			end
		end)
	end

	local Observers = {
		Scope:Observer(States.WorldPageMenu.PlaceId):onChange(UpdatePlaceInfo),
	}
	UpdatePlaceInfo()

	local WorldPageMenu = Scope:New "ScreenGui" {
		Name = "WorldPageMenu",
		Parent = Props.Parent,
		Enabled = MenuOpen,
		ResetOnSpawn = false,

		[Children] = {
			AutoScaleFrame {
				AnchorPoint = Vector2.new(0.5, 0),
				Position = Scope:Spring(
					Scope:Computed(function(Use)
						local YPos = Use(States.TopbarBottomPos)
						if not Use(MenuOpen) then
							YPos = YPos + 15
						end
						return UDim2.new(UDim.new(0.5, 0), UDim.new(0, YPos))
					end),
					Theme.SpringSpeed["1"],
					Theme.SpringDampening["1"]
				),
				BaseResolution = Vector2.new(739, 789),

				[Children] = {
					MenuFrame {
						Size = UDim2.fromOffset(353, 0),
						AutomaticSize = Enum.AutomaticSize.Y,
						GroupTransparency = Scope:Spring(
							Scope:Computed(function(Use)
								if Use(MenuOpen) then
									return 0
								else
									return 1
								end
							end),
							40,
							1
						),
						BackgroundTransparency = States.PreferredTransparency,
						ListEnabled = true,

						[Children] = {
							TitleBar {
								Title = "World",
								CloseButtonDisabled = true,
							},
							Frame {
								Name = "Contents",
								Size = UDim2.fromScale(1, 0),
								AutomaticSize = Enum.AutomaticSize.Y,
								ListEnabled = true,
								ListPadding = Scope:Computed(function(Use)
									return UDim.new(0, Use(Theme.Spacing["1"]))
								end),

								[Children] = {
									Image {
										Name = "Thumbnail",
										Image = Scope:Computed(function(Use)
											if Use(PlaceInfo) and Use(PlaceInfo).IconImageAssetId then
												return `rbxassetid://{Use(PlaceInfo).IconImageAssetId}`
											else
												return "rbxasset://textures/ui/GuiImagePlaceholder.png"
											end
										end),
										Size = UDim2.new(UDim.new(1, 0), UDim.new(0, 80)),
										ScaleType = Enum.ScaleType.Crop,
										CornerRadius = Scope:Computed(function(Use)
											return UDim.new(0, Use(Theme.CornerRadius["1"]))
										end),
									},
									Frame {
										Name = "Details",
										Size = UDim2.fromScale(1, 0),
										AutomaticSize = Enum.AutomaticSize.Y,
										ListEnabled = true,

										[Children] = {
											Text {
												Name = "Name",
												Size = UDim2.fromScale(1, 0),
												AutomaticSize = Enum.AutomaticSize.Y,
												Text = Scope:Computed(function(Use)
													if Use(PlaceInfo) and Use(PlaceInfo).Name then
														return Use(PlaceInfo).Name
													else
														return "Name"
													end
												end),
												TextSize = Theme.TextSize["1.5"],
												FontFace = Scope:Computed(function(Use)
													return Font.new(
														Use(Theme.Font.Heading),
														Use(Theme.FontWeight.Heading)
													)
												end),
												TextTruncate = Enum.TextTruncate.AtEnd,
												RichText = false,
												AutoLocalize = false,
											},
											Text {
												Name = "Description",
												Text = Scope:Computed(function(Use)
													if Use(PlaceInfo) and Use(PlaceInfo).Description then
														return Use(PlaceInfo).Description
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
												MaxSize = Scope:Computed(function(Use)
													return Vector2.new(math.huge, Use(Theme.TextSize["1"]) * 2)
												end),
											},
										},
									},
									Button {
										Name = "PlayButton",
										Size = UDim2.fromScale(1, 0),
										AutomaticSize = Enum.AutomaticSize.Y,
										Contents = { "rbxassetid://17293685944" },
										ContentSize = Theme.TextSize["1.5"],

										OnActivated = function()
											if States.Services.WorldsService then
												States.Services.WorldsService
													:TeleportToWorld(Use(States.WorldPageMenu.PlaceId))
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
