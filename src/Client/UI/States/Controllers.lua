local RoRooms = require(script.Parent.Parent.Parent.Parent.Parent.Parent.Parent)

local Packages = RoRooms.Packages

local Knit = require(Packages.Knit)
local States = require(script.Parent)

local CONTROLLERS = { "UIController", "EmotesController", "ItemsController", "FriendsController" }

local Controllers = {}

for _, ControllerName in ipairs(CONTROLLERS) do
	States.Controllers[ControllerName] = Knit.GetController(ControllerName)
end

return Controllers
