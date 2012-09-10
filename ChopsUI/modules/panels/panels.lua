local T, C, L = unpack(Tukui)

-- Hide the minimap data text frames.
TukuiMinimapStatsLeft:Hide()
TukuiMinimapStatsRight:Hide()

-- Add a background frame to the chat buttons.
local chatTabPanel = CreateFrame("Frame", "ChopsUIChatTabsPanel", UIParent)
chatTabPanel:SetTemplate()
chatTabPanel:Size(T.InfoLeftRightWidth, 19)
chatTabPanel:SetPoint("BOTTOMLEFT", TukuiInfoLeft, "TOPLEFT", 0, 132)
chatTabPanel:SetFrameLevel(2)
chatTabPanel:SetFrameStrata("BACKGROUND")

-- Increase the height of the vertical lines next to the info panels.
TukuiInfoLeftLineVertical:SetHeight(155)
TukuiInfoRightLineVertical:SetHeight(155)

-- Hide the horizontal lines stretching to the action bars (reanchoring them
-- raises some error about TukuiInfoLeft/Right being dependent on that frame).
TukuiLineToABLeft:Hide()
TukuiLineToABRight:Hide()

-- Create some new lines from the vertical bars to the info panels on each side.
local leftToInfoLine = CreateFrame("Frame", "ChopsUILineToInfoLeft", UIParent)
leftToInfoLine:SetTemplate()
leftToInfoLine:Size(5, 2)
leftToInfoLine:ClearAllPoints()
leftToInfoLine:Point("BOTTOMLEFT", TukuiInfoLeftLineVertical, "BOTTOMLEFT", 0, 0)
leftToInfoLine:Point("RIGHT", TukuiInfoLeft, "LEFT", 0, 0)
leftToInfoLine:SetFrameStrata("BACKGROUND")
leftToInfoLine:SetFrameLevel(1)

local rightToInfoLine = CreateFrame("Frame", "ChopsUILineToInfoRight", UIParent)
rightToInfoLine:SetTemplate()
rightToInfoLine:Size(5, 2)
rightToInfoLine:ClearAllPoints()
rightToInfoLine:Point("BOTTOMRIGHT", TukuiInfoRightLineVertical, "BOTTOMRIGHT", 0, 0)
rightToInfoLine:Point("LEFT", TukuiInfoRight, "RIGHT", 0, 0)
rightToInfoLine:SetFrameStrata("BACKGROUND")
rightToInfoLine:SetFrameLevel(1)
