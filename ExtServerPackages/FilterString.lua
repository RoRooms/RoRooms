local TextService = game:GetService("TextService")

return function(String: string, Player: Player)
  local FilteredText
  local Success, Log = pcall(function()
    local FilterResult = TextService:FilterStringAsync(String, Player.UserId)
    FilteredText = FilterResult:GetNonChatStringForBroadcastAsync()
  end)
  if Success then
    return FilteredText
  else
    warn(Log)
    return "Filtering Error"
  end
end