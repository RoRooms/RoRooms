local Players = game:GetService("Players")
local RoRooms = require(script.Parent.Parent.Parent.Parent)

local Shared = RoRooms.Shared
local Client = RoRooms.Client
local Config = RoRooms.Config
local Packages = RoRooms.Packages

local Component = require(Packages.Component)
local States = require(Client.UI.States)

local WorldTeleporter = Component.new {
  Tag = "RR_WorldTeleporter"
}

function WorldTeleporter:Start()
  self.Instance.Touched:Connect(function(Hit)
    local Char = Hit:FindFirstAncestorOfClass("Model")
    local Player = Players:GetPlayerFromCharacter(Char)
    if Player and Player == Players.LocalPlayer then
      if #States.Prompts:get() == 0 then
        States:PushPrompt({
          Title = "Teleport",
          Text = "Do you want to teleport to world "..self.World.Name.."?",
          Buttons = {
            {
              Primary = false,
              Contents = {"Cancel"},
            },
            {
              Primary = true,
              Contents = {"Teleport"},
              Callback = function()
                States.WorldsService:TeleportToWorld(self.WorldId)
              end
            },
          }
        })
      end
    end
  end)
end

function WorldTeleporter:Construct()
  self.WorldId = self.Instance:GetAttribute("RR_WorldId")
  self.World = Config.WorldsSystem.Worlds[self.WorldId]

  if not self.WorldId then
    warn("No RR_WorldId attribute defined for WorldTeleporter", self.Instance)
    return
  end
  if not self.World then
    warn("Could not find world by WorldId "..self.WorldId, self.Instance)
    return
  end
  if not self.Instance:IsA("BasePart") then
    warn("WorldTeleporter must be a BasePart object --", self.Instance)
    return
  end
end

return WorldTeleporter