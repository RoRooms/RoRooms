local MarketplaceService = game:GetService("MarketplaceService")

local RoRooms = script.Parent.Parent.Parent.Parent.Parent
local Future = require(script.Parent.Parent.Parent.Parent.Parent.Parent.Future)
local OnyxUI = require(RoRooms.Parent.OnyxUI)
local Fusion = require(RoRooms.Parent.Fusion)
local States = require(RoRooms.SourceCode.Client.UI.States)

local Children = Fusion.Children
local Util = OnyxUI.Util
local Themer = OnyxUI.Themer
local Peek = Fusion.peek

local CustomButton = require(RoRooms.SourceCode.Client.UI.Components.CustomButton)

return function(Scope: Fusion.Scope<any>, Props)
	local Scope = Fusion.innerScope(Scope, Fusion, OnyxUI.Util, OnyxUI.Components, {
		CustomButton = CustomButton,
	})
	local Theme = Themer.Theme:now()

	local PlaceId = Scope:EnsureValue(Util.Fallback(Props.PlaceId, nil))
	local UserId = Util.Fallback(Props.UserId, 1)
	local DisplayName = Util.Fallback(Props.DisplayName, "DisplayName")
	local Online = Util.Fallback(Props.Online, false)
	local JobId = Util.Fallback(Props.JobId, nil)
	local InRoRooms = Util.Fallback(Props.InRoRooms, false)

	local PlaceInfo = Scope:Value({})

	local function UpdatePlaceInfo()
		if Peek(PlaceId) == nil then
			return
		end

		Future.Try(function()
			return MarketplaceService:GetProductInfo(Peek(PlaceId))
		end):After(function(Success, Result)
			if Success then
				PlaceInfo:set(Result)
			else
				warn(Result)
			end
		end)
	end

	Scope:Observer(PlaceId):onChange(UpdatePlaceInfo)
	UpdatePlaceInfo()

	local Status = Scope:Computed(function(Use)
		if Use(InRoRooms) then
			return "RoRooms"
		elseif Use(Online) then
			return "Online"
		else
			return "Offline"
		end
	end)
	local StatusColor = Scope:Computed(function(Use)
		local StatusValue = Use(Status)
		if StatusValue == "RoRooms" then
			return OnyxUI.Util.Colors.Green["400"]
		elseif StatusValue == "Online" then
			return OnyxUI.Util.Colors.Sky["500"]
		else
			return Use(Theme.Colors.Base.Main)
		end
	end)

	return Scope:CustomButton {
		Name = "FriendButton",
		Parent = Props.Parent,
		ClipsDescendants = true,
		LayoutOrder = Props.LayoutOrder,
		ListEnabled = true,
		ListFillDirection = Enum.FillDirection.Vertical,
		ListHorizontalAlignment = Enum.HorizontalAlignment.Center,
		ListPadding = Scope:Computed(function(Use)
			return UDim.new(0, Use(Theme.Spacing["0.75"]))
		end),

		OnActivated = function()
			States.Menus.ProfileMenu.UserId:set(Peek(UserId))
			States.Menus.ProfileMenu.FriendData.Online:set(Peek(Online))
			States.Menus.ProfileMenu.FriendData.InRoRooms:set(Peek(InRoRooms))
			States.Menus.ProfileMenu.FriendData.JobId:set(Peek(JobId))
			States.Menus.ProfileMenu.FriendData.PlaceId:set(Peek(PlaceId))
			States.Menus.CurrentMenu:set("ProfileMenu")
		end,

		[Children] = {
			Scope:PlayerAvatar {
				Status = Status,
				Image = Scope:Computed(function(Use)
					return `rbxthumb://type=AvatarHeadShot&id={Use(UserId)}&w=150&h=150`
				end),
			},
			Scope:Frame {
				Name = "Details",
				Size = UDim2.fromOffset(80, 0),
				AutomaticSize = Enum.AutomaticSize.Y,
				ListEnabled = true,
				ListPadding = UDim.new(0, 0),
				ListHorizontalFlex = Enum.UIFlexAlignment.Fill,

				[Children] = {
					Scope:Text {
						Name = "DisplayName",
						Text = DisplayName,
						TextTruncate = Enum.TextTruncate.AtEnd,
						AutomaticSize = Enum.AutomaticSize.Y,
						TextXAlignment = Enum.TextXAlignment.Center,
						TextWrapped = false,
						AutoLocalize = false,
					},
					Scope:Text {
						Name = "Status",
						Text = Scope:Computed(function(Use)
							return (Use(InRoRooms) and Use(PlaceInfo).Name) or "Online"
						end),
						TextColor3 = StatusColor,
						TextSize = Theme.TextSize["0.875"],
						TextTruncate = Enum.TextTruncate.AtEnd,
						AutomaticSize = Enum.AutomaticSize.Y,
						TextXAlignment = Enum.TextXAlignment.Center,
						TextWrapped = false,
						AutoLocalize = Scope:Computed(function(Use)
							return next((Use(PlaceInfo) or {})) ~= nil
						end),
					},
				},
			},
		},
	}
end
