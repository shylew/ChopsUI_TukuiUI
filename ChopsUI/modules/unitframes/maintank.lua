local T, C, L = unpack(Tukui)
if C.unitframes.enable ~= true then return end

local frame = TukuiMainTank

-- Reposition the main tank frame.
frame:ClearAllPoints()
frame:SetPoint("TOPLEFT", TukuiWatchFrameAnchor, "BOTTOMLEFT", 0, 0)
