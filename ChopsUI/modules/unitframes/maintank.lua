local T, C, L = unpack(Tukui)
if C.unitframes.enable ~= true then return end

if C.unitframes.maintank == true then
  DEFAULT_CHAT_FRAME:AddMessage("Tukui maintank enabled")
else
  DEFAULT_CHAT_FRAME:AddMessage("Tukui maintank disabled")
end

local frame = TukuiMainTank

-- Reposition the main tank frame.
frame:ClearAllPoints()
frame:SetPoint("TOPLEFT", TukuiWatchFrameAnchor, "BOTTOMLEFT", 0, 0)
