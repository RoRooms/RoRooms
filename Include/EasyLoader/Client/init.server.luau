local RoRooms = require(script.Parent.Parent.RoRooms)
local Config = require(script.Parent.Config)

RoRooms.Config:Update(Config)

RoRooms:Start()
