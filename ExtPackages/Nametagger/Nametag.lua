local RunService = game:GetService("RunService")

local RoRooms = script.Parent.Parent.Parent.Parent.Parent
local OnyxUI = require(RoRooms.Parent.OnyxUI)
local Fusion = require(RoRooms.Parent.Fusion)

local Util = OnyxUI.Util
local Themer = OnyxUI.Themer
local Children = Fusion.Children

local TagText = require(script.Parent.TagText)
local PropertyEntry = require(script.Parent.PropertyEntry)

export type Props = {
	Character: Fusion.UsedAs<Model>?,
	Humanoid: Fusion.UsedAs<Humanoid>?,
	Head: Fusion.UsedAs<BasePart>?,
	Player: Fusion.UsedAs<Player>?,
	Properties: { { Value: any, Icon: string? } }?,
	DisplayName: string?,
}

return function(Scope: Fusion.Scope<any>, Props: Props)
	local Scope = Fusion.innerScope(Scope, Fusion, Util, OnyxUI.Components, {
		TagText = TagText,
		PropertyEntry = PropertyEntry,
	})
	local Theme = Themer.Theme:now()

	local Character = Scope:EnsureValue(Props.Character, "Model", nil)
	local Humanoid = Scope:EnsureValue(Props.Humanoid, "Humanoid", nil)
	local Head = Scope:EnsureValue(Props.Head, "BasePart", nil)

	local Properties = Util.Fallback(Props.Properties, {})
	local DisplayName = Util.Fallback(
		Props.DisplayName,
		Scope:Computed(function(Use)
			local HumanoidValue = Use(Humanoid)
			if HumanoidValue and HumanoidValue.DisplayName then
				return HumanoidValue and HumanoidValue.DisplayName
			else
				return "Name"
			end
		end)
	)
	local AbsoluteSize = Scope:Value(Vector2.new())

	local Contents = Scope:Frame {
		AnchorPoint = Vector2.new(0.5, 1),
		Position = UDim2.fromScale(0.5, 1),
		ListEnabled = true,
		ListPadding = Scope:Computed(function(Use)
			return UDim.new(0, Use(Theme.Spacing["0.25"]) / 2)
		end),
		ListHorizontalAlignment = Enum.HorizontalAlignment.Center,

		[Children] = {
			Scope:TagText {
				Name = "DisplayName",
				Text = DisplayName,
				FontFace = Scope:Computed(function(Use)
					return Font.new(Use(Theme.Font.Body), Use(Theme.FontWeight.Bold))
				end),
				StrokeEnabled = true,
			},
			Scope:Frame {
				Name = "Properties",
				ListEnabled = true,
				ListFillDirection = Enum.FillDirection.Horizontal,
				ListHorizontalAlignment = Enum.HorizontalAlignment.Center,
				ListPadding = Scope:Computed(function(Use)
					return UDim.new(0, Use(Theme.Spacing["0.25"]))
				end),
				CornerRadius = Scope:Computed(function(Use)
					return UDim.new(0, 1000)
				end),
				Padding = Scope:Computed(function(Use)
					return UDim.new(0, Use(Theme.Spacing["0.25"]))
				end),
				PaddingTop = Scope:Computed(function(Use)
					return UDim.new(0, Use(Theme.Spacing["0"]))
				end),
				PaddingBottom = Scope:Computed(function(Use)
					return UDim.new(0, Use(Theme.Spacing["0"]))
				end),
				BackgroundColor3 = Util.Colors.Black,
				BackgroundTransparency = 0.8,

				[Children] = {
					Scope:ForValues(
						Properties,
						function(Use, Scope, Property: { Value: Fusion.UsedAs<any>, Image: Fusion.UsedAs<string?>? })
							return Scope:PropertyEntry {
								Value = Property.Value,
								Image = Property.Image,
							}
						end
					),
				},
			},
		},
	}

	RunService.RenderStepped:Connect(function()
		AbsoluteSize:set(Contents.AbsoluteSize)
	end)

	return Scope:New "BillboardGui" {
		Name = "Nametag",
		Parent = Character,
		Adornee = Head,
		Active = false,
		AutoLocalize = false,
		ClipsDescendants = false,
		Size = Scope:Computed(function(Use)
			local AbsoluteSizeValue = Use(AbsoluteSize)
			return UDim2.fromOffset(AbsoluteSizeValue.X, AbsoluteSizeValue.Y)
		end),
		StudsOffset = Vector3.new(0, 1.25, 0),
		SizeOffset = Vector2.new(0, 1),
		MaxDistance = 50,

		[Children] = {
			Contents,
		},
	}
end
