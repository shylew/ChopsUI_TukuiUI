local T, C, L, G = unpack(Tukui)

-- Hide the minimap data text frames.
TukuiMinimapStatsLeft:Hide()
TukuiMinimapStatsRight:Hide()

-- Increase the width of the info panels.
TukuiInfoLeft:SetWidth(445)
TukuiInfoRight:SetWidth(445)

-- Add a background frame to the chat buttons.
local chatTabPanel = CreateFrame("Frame", "ChopsUIChatTabsPanel", UIParent)
chatTabPanel:SetTemplate()
chatTabPanel:Size(445, 19)
chatTabPanel:SetPoint("BOTTOMLEFT", TukuiInfoLeft, "TOPLEFT", 0, 152)
chatTabPanel:SetFrameLevel(2)
chatTabPanel:SetFrameStrata("BACKGROUND")

-- Increase the height of the vertical lines next to the info panels.
TukuiInfoLeftLineVertical:SetHeight(175)
TukuiInfoRightLineVertical:SetHeight(175)

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

-- Add another data text container on the left side.
local dataTextLeft = CreateFrame("Frame", "ChopsUIDataTextLeft", UIParent)
dataTextLeft:SetTemplate()
dataTextLeft:Size((T.buttonsize * 6) + (T.buttonspacing * 7) + 1, 23)
dataTextLeft:SetPoint("LEFT", TukuiInfoLeft, "RIGHT", 7, 0)
dataTextLeft:SetFrameLevel(2)
dataTextLeft:SetFrameStrata("BACKGROUND")
G.Panels.DataTextLeftTwo = dataTextLeft

-- Add another data text container on the right side.
local dataTextRight = CreateFrame("Frame", "ChopsUIDataTextRight", UIParent)
dataTextRight:SetTemplate()
dataTextRight:Size((T.buttonsize * 6) + (T.buttonspacing * 7) + 1, 23)
dataTextRight:SetPoint("RIGHT", TukuiInfoRight, "LEFT", -7, 0)
dataTextRight:SetFrameLevel(2)
dataTextRight:SetFrameStrata("BACKGROUND")
G.Panels.DataTextRightTwo = dataTextRight

-- Make the primary action bar two rows large, and position it to the right of
-- the left chat frame instead of in the middle.
TukuiBar1:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 148)
TukuiBar1:SetPoint("LEFT", UIParent, "LEFT", 489, 0)
TukuiBar1:SetWidth((T.buttonsize * 6) + (T.buttonspacing * 7))
TukuiBar1:SetHeight((T.buttonsize * 2) + (T.buttonspacing * 3))

-- Move the second action bar below the first action bar instead of to the left.
TukuiBar2:ClearAllPoints()
TukuiBar2:SetPoint("TOPLEFT", TukuiBar1, "BOTTOMLEFT", 0, -6)

-- Move the third action bar below the fourth action bar instead of to the
-- right.
TukuiBar3:ClearAllPoints()
TukuiBar3:SetPoint("TOPLEFT", TukuiBar4, "BOTTOMLEFT", 0, -6)

-- Make the fourth action bar two rows large, and position it to the left of the
-- right chat frame instead of in the middle.
TukuiBar4:ClearAllPoints()
TukuiBar4:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 148)
TukuiBar4:SetPoint("RIGHT", UIParent, "RIGHT", -489, 0)
TukuiBar4:SetWidth((T.buttonsize * 6) + (T.buttonspacing * 7))
TukuiBar4:SetHeight((T.buttonsize * 2) + (T.buttonspacing * 3))

-- Hide the action bar expander.
TukuiBar4Button:Hide()
