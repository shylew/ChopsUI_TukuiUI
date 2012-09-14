local T, C, L = unpack(Tukui)

-- Move the extra action bar frame holder.
local frame = TukuiExtraActionBarFrameHolder
frame:ClearAllPoints()
frame:SetPoint("BOTTOMLEFT", TukuiChatBackgroundRight, "TOPLEFT", 0, 90)
