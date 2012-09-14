local T, C, L = unpack(Tukui)
if C.unitframes.enable ~= true then return end

-- Reposition the arena unit frames.
for i = 1, 5 do
	local frame = _G["TukuiArena"..i]
  if i == 1 then
    frame:SetPoint("BOTTOMRIGHT", TukuiChatBackgroundRight, "TOPRIGHT", 0, 90)
  end
end
