local T, C, L = unpack(Tukui)
if C.unitframes.enable ~= true then return end

-- Reposition the boss unit frames.
for i = 1, MAX_BOSS_FRAMES do
	local frame = _G["TukuiBoss"..i]
  if i == 1 then
    frame:SetPoint("BOTTOMRIGHT", TukuiChatBackgroundRight, "TOPRIGHT", 0, 90)
  end
end
