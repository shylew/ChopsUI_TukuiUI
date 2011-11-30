local T, C, L = unpack(Tukui)

-- Add a frame spanning the entire screen width at the bottom of the screen.
local bottomBarFrame = CreateFrame("Frame", "ChopsuiBottomHorizontalBar", UIParent)
bottomBarFrame:CreatePanel("Default", 1, 28, "BOTTOM", UIParent, "BOTTOM", 0, -2)
bottomBarFrame:ClearAllPoints()
bottomBarFrame:SetPoint("BOTTOM", UIParent, 0, -2)
bottomBarFrame:SetPoint("LEFT", UIParent, "LEFT", -2, -2)
bottomBarFrame:SetPoint("RIGHT", UIParent, "RIGHT", 2, -2)
bottomBarFrame:SetFrameStrata("BACKGROUND")
bottomBarFrame:SetFrameLevel(0)

-- Hide the horizontal lines connecting action bars and chat frames.
if C.chat.background then
  TukuiLineToABLeftAlt:Kill()
	TukuiLineToABRightAlt:Kill()
else
  TukuiLineToABLeft:Kill()
	TukuiLineToABRight:Kill()
end

-- "Skada" button next to the "Loot" button in the right chat frame.
local skadaActivationButton = CreateFrame("Button", "SkadaActivationButton", TukuiTabsRightBackground)
skadaActivationButton:SetNormalFontObject("GameFontNormalSmall")
skadaActivationButton:SetText("Skada")
skadaActivationButton:SetWidth(35)
skadaActivationButton:SetHeight(20)
skadaActivationButton:ClearAllPoints()
skadaActivationButton:SetPoint("LEFT", TukuiTabsRightBackground, "LEFT", 70, 1)
skadaActivationButton:SetFrameStrata("LOW")
skadaActivationButton:SetFrameLevel(0)
