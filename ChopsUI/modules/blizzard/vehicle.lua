local T, C, L = unpack(Tukui)

-- Move the vehicle seat indicator.
local frame = TukuiVehicleAnchor
frame:ClearAllPoints()
frame:SetPoint("BOTTOMLEFT", TukuiChatBackgroundRight, "TOPLEFT", 0, 20)
