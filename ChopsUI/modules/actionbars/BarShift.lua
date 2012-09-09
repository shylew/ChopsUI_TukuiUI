local T, C, L = unpack(Tukui)

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("UPDATE_SHAPESHIFT_FORMS")
frame:SetScript("OnEvent", function(self)

  -- Check how many visible buttons there are in the shapeshift bar.
  local visibleButtonWidth = 0
  for i = 1, NUM_STANCE_SLOTS do
    local button = _G["StanceButton" .. i]
    if button:IsVisible() then
      visibleButtonWidth = visibleButtonWidth + button:GetWidth() + 4
    end
  end
  local xOffset = ((TukuiStance:GetWidth() - visibleButtonWidth) / 2) * 1

  -- Reposition the stance bar.
  TukuiStance:ClearAllPoints()
  TukuiStance:SetPoint("BOTTOM", ChopsUIInvViewportBackground, "TOP", xOffset, -32)

  self:UnregisterEvent("PLAYER_ENTERING_WORLD")
  
end)
