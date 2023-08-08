local RoRooms = require(game:GetService("ReplicatedStorage").RoRooms)
local Players = game:GetService("Players")

local Shared = RoRooms.Shared

local Component = require(Shared.Packages.Component)
local Fusion = require(Shared.ExtPackages.NekaUI.Packages.Fusion)

local AnimSeat = Component.new {
  Tag = "RR_AnimSeat"
}

function AnimSeat:Start()
  if self.PromptToSit then
    self.ProximityPrompt = Fusion.New "ProximityPrompt" {
      Parent = self.Instance,
      ActionText = "",
      RequiresLineOfSight = false,
      MaxActivationDistance = 7.5,
      Enabled = Fusion.Computed(function()
        return self.OccupantPlayer:get() == nil
      end)
    }

    self.ProximityPrompt.Triggered:Connect(function(Player: Player)
      if Player == Players.LocalPlayer then
        local Char = Players.LocalPlayer.Character
        if Char then
          local Humanoid = Char:FindFirstChildOfClass("Humanoid")
          if Humanoid then
            self.Instance:Sit(Humanoid)
          end
        end
      end
    end)
  end

  self.Instance:GetPropertyChangedSignal("Occupant"):Connect(function()
    if self.LastAnimTrack then
      self.LastAnimTrack:Stop()
      self.LastAnimTrack = nil
    end
    if not self.Instance.Occupant then
      self.OccupantPlayer:set(nil)
      return
    end
    local Char = self.Instance.Occupant:FindFirstAncestorOfClass("Model")
    self.OccupantPlayer:set(Players:GetPlayerFromCharacter(Char))
    if self.OccupantPlayer:get() == Players.LocalPlayer then
      local Animator = Char:FindFirstChild("Animator", true)
      if Animator then
        local AnimTrack = Animator:LoadAnimation(self.Animation)
        AnimTrack:Play()
        self.LastAnimTrack = AnimTrack
      end
    end
  end)
end

function AnimSeat:Construct()
  if not self.Instance:IsA("Seat") then
    warn("AnimSeat must be a Seat object --", self.Instance)
    return
  end
  self.Animation = self.Instance:FindFirstChildOfClass("Animation")
  if not self.Animation then
    warn("No Animation inside AnimSeat --", self.Instance)
    return
  end
  self.PromptToSit = self.Instance:GetAttribute("RR_PromptToSit") or true
  -- self.MaxActivationDistance = 

  self.OccupantPlayer = Fusion.Value()
end

return AnimSeat