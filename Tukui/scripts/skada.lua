-- Don't do anything if we don't have the Skada frames we expect
local dpsFrame = SkadaBarWindowDPS
local threatFrame = SkadaBarWindowThreat
if not IsAddOnLoaded("Skada") or not dpsFrame or not threatFrame then return end

-----------------------------------------------------------------------
-- SETUP SKADA FRAMES
-----------------------------------------------------------------------

local lootFrame = _G[format("ChatFrame%s", 4)]
local lootFrameTab = _G[format("ChatFrame%sTab", 4)]
local rightChatBackground = _G["ChopsuiChatBackgroundRight"]

-- Position the frames
dpsFrame:ClearAllPoints()
dpsFrame:SetPoint("TOPRIGHT", rightChatBackground, "TOPRIGHT", TukuiDB.Scale(-5), TukuiDB.Scale(-4))

threatFrame:ClearAllPoints()
threatFrame:SetPoint("TOPLEFT", rightChatBackground, "TOPLEFT", TukuiDB.Scale(5), TukuiDB.Scale(-4))
