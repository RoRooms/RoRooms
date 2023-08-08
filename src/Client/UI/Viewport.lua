local ScreenGuis = script.Parent.ScreenGuis

return function(Props)
  local ReturnedGuis = {}

  for _, GuiModule in ipairs(ScreenGuis:GetChildren()) do
    local GuiNameSplit = string.split(GuiModule.Name, ".")
    local FileSuffix = GuiNameSplit[2]
    
    if GuiModule:IsA("ModuleScript") and not FileSuffix then
      local Gui = require(GuiModule)
      table.insert(ReturnedGuis, Gui {
        Name = GuiModule.Name,
        Parent = Props.Target
      })
    end
  end
  
  return ReturnedGuis
end