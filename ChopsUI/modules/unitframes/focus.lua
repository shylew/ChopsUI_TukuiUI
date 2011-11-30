local T, C, L = unpack(Tukui)
if C.unitframes.enable ~= true then return end

local frame = TukuiFocus
local castbar = frame.Castbar

-- Position the focus cast bar in the middle of the screen.
castbar:ClearAllPoints()
castbar:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
castbar:SetWidth(240)
castbar:SetHeight(20)

-- Reposition the focus frame.
frame:ClearAllPoints()
frame:SetPoint("BOTTOMRIGHT", TukuiPlayer, "TOPLEFT", -21, 239)

-- Change the size of the focus frame.
frame:Size(129, 36)
