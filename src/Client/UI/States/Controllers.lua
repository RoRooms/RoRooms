local RoRooms = script.Parent.Parent.Parent.Parent.Parent.Parent.Parent
local Knit = require(RoRooms.Packages.Knit)
local States = require(script.Parent)

local CONTROLLERS = { "UIController", "EmotesController", "ItemsController", "FriendsController" }

local Controllers = {}

for _, ControllerName in ipairs(CONTROLLERS) do
	States.Controllers[ControllerName] = Knit.GetController(ControllerName)
end

return Controllers
