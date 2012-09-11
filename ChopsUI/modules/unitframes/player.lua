local T, C, L = unpack(Tukui)
if C.unitframes.enable ~= true then return end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript("OnEvent", function(self)

  -- Reposition the player frame.
  TukuiPlayer:ClearAllPoints()
  TukuiPlayer:SetPoint("BOTTOM", ChopsUIInvViewportBackground, "TOP", -130, 32)

end)
