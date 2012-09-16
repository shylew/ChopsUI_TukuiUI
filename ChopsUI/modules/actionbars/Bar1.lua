local T, C, L = unpack(Tukui)
if not C["actionbar"].enable == true then return end

-- Split the action bar into two rows.
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript("OnEvent", function(self)
  for i = 1, 12 do
    local button = _G["ActionButton" .. i]
    local button2 = _G["ActionButton" .. i-1]
    button:ClearAllPoints()
    if i == 1 then
      button:SetPoint("TOPLEFT", TukuiBar1, T.buttonspacing, -T.buttonspacing)
    elseif i == 7 then
      button:SetPoint("BOTTOMLEFT", TukuiBar1, T.buttonspacing, T.buttonspacing)
    else
      button:SetPoint("LEFT", button2, "RIGHT", T.buttonspacing, 0)
    end
  end
end)
