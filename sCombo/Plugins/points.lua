-- sCombo
local T, C, L = unpack(Tukui)

local O = Options["points"]
if O.display ~= true then return end

local f = CreateFrame("Frame")
local text = T.SetFontString(sCombo[1], C.media.font, 20, "THINOUTLINE")
text:Point("BOTTOM", sCombo[3], "TOP", 0, 3)
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("UNIT_COMBO_POINTS")
f:RegisterEvent("PLAYER_TARGET_CHANGED")
f:SetScript("OnEvent", function(self, event)
	points = GetComboPoints("player", "target")
	text:SetText(points)
end)