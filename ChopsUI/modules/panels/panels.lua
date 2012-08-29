local T, C, L = unpack(Tukui)

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
