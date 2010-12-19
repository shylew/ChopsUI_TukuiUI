-- Don't do anything if we don't have the Skada frames we expect
local dpsFrame = SkadaBarWindowDPS
local threatFrame = SkadaBarWindowThreat
if not IsAddOnLoaded("Skada") or not dpsFrame or not threatFrame then return end

-----------------------------------------------------------------------
-- SETUP SKADA FRAMES
-----------------------------------------------------------------------

local lootFrame = _G[format("ChatFrame%s", 4)]
local lootFrameTab = _G[format("ChatFrame%sTab", 4)]

-- Figure out the actual height of the Skada frames.
local frameHeight = (Skada.db.profile.windows[1].barheight * Skada.db.profile.windows[1].barmax)
local frameOffset = frameHeight + TukuiDB.Scale(2)

-- Position the frames
dpsFrame:ClearAllPoints()
dpsFrame:SetPoint("BOTTOMRIGHT", TukuiInfoRight, "TOPRIGHT", TukuiDB.Scale(-2), frameOffset)

threatFrame:ClearAllPoints()
threatFrame:SetPoint("BOTTOMLEFT", TukuiInfoRight, "TOPLEFT", TukuiDB.Scale(2), frameOffset)

-- Hide the loot frame and loot frame tab
local function hideLootFrame()
  lootFrame:Hide()
  lootFrameTab:Hide()
end

-- Show the loot frame and loot frame tab if all Skada windows are hidden
local function showLootFrameIfSkadaIsHidden()
  if not dpsFrame:IsShown() and not threatFrame:IsShown() then
    lootFrame:Show()
    lootFrameTab:Show()
  end
end

-- Hook show/hide events on the frames to show/hide the chat frame
dpsFrame:HookScript("OnShow", hideLootFrame)
dpsFrame:HookScript("OnHide", showLootFrameIfSkadaIsHidden)
threatFrame:HookScript("OnShow", hideLootFrame)
threatFrame:HookScript("OnHide", showLootFrameIfSkadaIsHidden)

-- Automatically show Skada when entering combat, and automatically
-- hide Skada after combat ends if it was activated automatically on
-- combat start.
local autoHideAfterCombat = false

local f = CreateFrame("Frame")
local addon = {}
f:RegisterEvent("PLAYER_REGEN_ENABLED")
f:RegisterEvent("PLAYER_REGEN_DISABLED")
f:SetScript("OnEvent", function(_, event) addon[event]() end)

function addon:PLAYER_REGEN_ENABLED()
  if autoHideAfterCombat then
    Skada:SetActive(false)
  end
end

function addon:PLAYER_REGEN_DISABLED()
  if not dpsFrame:IsShown() or not threatFrame:IsShown() then
    Skada:SetActive(true)
    autoHideAfterCombat = true
  end
end
