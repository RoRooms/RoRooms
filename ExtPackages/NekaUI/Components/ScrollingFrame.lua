local NekaUI = script.Parent.Parent

local Fusion = require(NekaUI.Packages.Fusion)
local Finalize = require(NekaUI.Utils.Finalize)

local New = Fusion.New
local Children = Fusion.Children

local Components = script.Parent
local Frame = require(Components.Frame)

local function ScrollingFrame(Props)
  return Finalize(New "ScrollingFrame" {
    Name = Props.Name,
    Parent = Props.Parent,
    LayoutOrder = Props.LayoutOrder,
    Position = Props.Position,
    AnchorPoint = Props.AnchorPoint,
    Size = Props.Size,
    AutomaticSize = Props.AutomaticSize or Enum.AutomaticSize.None,
    ZIndex = Props.ZIndex,

    BackgroundTransparency = 1,
    ScrollBarThickness = 0,
    ScrollBarImageTransparency = 1,
    ScrollingDirection = Enum.ScrollingDirection.Y,
    ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,

    [Children] = {
      Frame {
        Name = "Contents",
        Size = UDim2.fromScale(1, 1),
        AutomaticSize = Enum.AutomaticSize.None,

        [Children] = Props[Children]
      }
    }
  })
end

return ScrollingFrame