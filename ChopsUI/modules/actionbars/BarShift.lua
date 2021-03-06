local T, C, L = unpack(Tukui)

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("UPDATE_SHAPESHIFT_FORMS")
frame:SetScript("OnEvent", function(self)

  -- Check how many visible buttons there are in the shapeshift bar.
  local visibleButtonCount = 0
  for i = 1, NUM_STANCE_SLOTS do
    local button = _G["StanceButton" .. i]
    if button:IsVisible() then
      visibleButtonCount = visibleButtonCount + 1
    end
  end
  local stanceWidth = (visibleButtonCount * T.buttonsize) + ((visibleButtonCount + 1) * T.buttonspacing) + (visibleButtonCount * 2)

  -- Make the stance bar panel the parent.
  TukuiStance:SetParent(ChopsUIStancePanel)

  -- Reposition the stance bar.
  TukuiStance:ClearAllPoints()
  TukuiStance:SetPoint("BOTTOMLEFT", T.buttonspacing - 0.5, -14)

  -- Make the stance panel as wide as the amount of stance buttons that are
  -- active.
  ChopsUIStancePanel:SetWidth(stanceWidth)

  -- Hide the panel by default, but show it on mouseover.
  ChopsUIStancePanel:SetAlpha(0)
  ChopsUIStancePanel:SetScript("OnEnter", function(self) self:SetAlpha(1) end)
  ChopsUIStancePanel:SetScript("OnLeave", function(self) self:SetAlpha(0) end)
  for i = 1, NUM_STANCE_SLOTS do
    local button = _G["StanceButton" .. i]
    if button:IsVisible() then
      button:SetScript("OnEnter", function(self) ChopsUIStancePanel:SetAlpha(1) end)
      button:SetScript("OnLeave", function(self) ChopsUIStancePanel:SetAlpha(0) end)
    end
  end

end)
