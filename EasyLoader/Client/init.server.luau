local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RoRooms = require(ReplicatedStorage.RoRooms)
local Config = require(script.Parent.Config)

RoRooms.Config:Update(Config)

RoRooms:Start()
