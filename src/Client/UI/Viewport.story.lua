local Viewport = require(script.Parent.Viewport)

return function(Target)
  local ViewportGuis = Viewport {
    Target = Target
  }

  return function()
    for _, Gui in ipairs(ViewportGuis) do
      Gui:Destroy()
    end
  end
end