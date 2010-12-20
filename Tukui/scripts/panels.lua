-- ACTION BAR PANEL
TukuiDB.buttonsize = TukuiDB.Scale(27)
TukuiDB.buttonspacing = TukuiDB.Scale(4)
TukuiDB.petbuttonsize = TukuiDB.Scale(29)
TukuiDB.petbuttonspacing = TukuiDB.Scale(4)

-- set left and right info panel width
TukuiCF["panels"] = {["tinfowidth"] = 370}

local barbg = CreateFrame("Frame", "TukuiActionBarBackground", UIParent)
TukuiDB.CreatePanel(barbg, 1, 1, "BOTTOM", UIParent, "BOTTOM", 0, TukuiDB.Scale(14))
TukuiDB.CreateShadow(TukuiActionBarBackground)
if TukuiDB.lowversion == true then
	barbg:SetWidth((TukuiDB.buttonsize * 12) + (TukuiDB.buttonspacing * 13))
	if TukuiCF["actionbar"].bottomrows == 2 then
		barbg:SetHeight((TukuiDB.buttonsize * 2) + (TukuiDB.buttonspacing * 3))
	else
		barbg:SetHeight(TukuiDB.buttonsize + (TukuiDB.buttonspacing * 2))
	end
else
	barbg:SetWidth((TukuiDB.buttonsize * 22) + (TukuiDB.buttonspacing * 23))
	if TukuiCF["actionbar"].bottomrows == 2 then
		barbg:SetHeight((TukuiDB.buttonsize * 2) + (TukuiDB.buttonspacing * 3))
	else
		barbg:SetHeight(TukuiDB.buttonsize + (TukuiDB.buttonspacing * 2))
	end
end
barbg:SetFrameStrata("BACKGROUND")
barbg:SetFrameLevel(1)

-- INVISIBLE FRAME COVERING TukuiActionBarBackground
local invbarbg = CreateFrame("Frame", "InvTukuiActionBarBackground", UIParent)
invbarbg:SetSize(barbg:GetWidth(), barbg:GetHeight())
invbarbg:SetPoint("BOTTOM", 0, TukuiDB.Scale(14))

-- INFO LEFT (FOR STATS)
local ileft = CreateFrame("Frame", "TukuiInfoLeft", barbg)
TukuiDB.CreatePanel(ileft, TukuiCF["panels"].tinfowidth, 23, "BOTTOMLEFT", UIParent, "BOTTOMLEFT", TukuiDB.Scale(14), TukuiDB.Scale(14))
TukuiDB.CreateShadow(TukuiInfoLeft)
ileft:SetFrameLevel(2)
ileft:SetFrameStrata("BACKGROUND")

-- INFO RIGHT (FOR STATS)
local iright = CreateFrame("Frame", "TukuiInfoRight", barbg)
TukuiDB.CreatePanel(iright, TukuiCF["panels"].tinfowidth, 23, "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", TukuiDB.Scale(-14), TukuiDB.Scale(14))
TukuiDB.CreateShadow(TukuiInfoRight)
iright:SetFrameLevel(2)
iright:SetFrameStrata("BACKGROUND")

if TukuiMinimap then
	local minimapstatsleft = CreateFrame("Frame", "TukuiMinimapStatsLeft", TukuiMinimap)
	TukuiDB.CreatePanel(minimapstatsleft, ((TukuiMinimap:GetWidth() + 4) / 2) - 1, 19, "TOPLEFT", TukuiMinimap, "BOTTOMLEFT", 0, TukuiDB.Scale(-2))

	local minimapstatsright = CreateFrame("Frame", "TukuiMinimapStatsRight", TukuiMinimap)
	TukuiDB.CreatePanel(minimapstatsright, ((TukuiMinimap:GetWidth() + 4) / 2) -1, 19, "TOPRIGHT", TukuiMinimap, "BOTTOMRIGHT", 0, TukuiDB.Scale(-2))
end

--RIGHT BAR BACKGROUND
if TukuiCF["actionbar"].enable == true then
	local barbgr = CreateFrame("Frame", "TukuiActionBarBackgroundRight", UIParent)
	TukuiDB.CreatePanel(barbgr, 1, (TukuiDB.buttonsize * 12) + (TukuiDB.buttonspacing * 13), "RIGHT", UIParent, "RIGHT", TukuiDB.Scale(-23), TukuiDB.Scale(-13.5))
  TukuiDB.CreateShadow(TukuiActionBarBackgroundRight)
	if TukuiCF["actionbar"].rightbars == 1 then
		barbgr:SetWidth(TukuiDB.buttonsize + (TukuiDB.buttonspacing * 2))
	elseif TukuiCF["actionbar"].rightbars == 2 then
		barbgr:SetWidth((TukuiDB.buttonsize * 2) + (TukuiDB.buttonspacing * 3))
	elseif TukuiCF["actionbar"].rightbars == 3 then
		barbgr:SetWidth((TukuiDB.buttonsize * 3) + (TukuiDB.buttonspacing * 4))
	else
		barbgr:Hide()
	end
	if TukuiCF["actionbar"].rightbars > 0 then
		local rbl = CreateFrame("Frame", "TukuiRightBarLine", barbgr)
		local crblu = CreateFrame("Frame", "TukuiCubeRightBarUP", barbgr)
		local crbld = CreateFrame("Frame", "TukuiCubeRightBarDown", barbgr)
		TukuiDB.CreatePanel(rbl, 2, (TukuiDB.buttonsize / 2 * 27) + (TukuiDB.buttonspacing * 6), "RIGHT", barbgr, "RIGHT", TukuiDB.Scale(1), 0)
		rbl:SetWidth(TukuiDB.Scale(2))
		TukuiDB.CreatePanel(crblu, 10, 10, "BOTTOM", rbl, "TOP", 0, 0)
		TukuiDB.CreatePanel(crbld, 10, 10, "TOP", rbl, "BOTTOM", 0, 0)
	end

	local petbg = CreateFrame("Frame", "TukuiPetActionBarBackground", UIParent)
	if TukuiCF["actionbar"].rightbars > 0 then
		TukuiDB.CreatePanel(petbg, TukuiDB.petbuttonsize + (TukuiDB.petbuttonspacing * 2), (TukuiDB.petbuttonsize * 10) + (TukuiDB.petbuttonspacing * 11), "RIGHT", barbgr, "LEFT", TukuiDB.Scale(-6), 0)
	else
		TukuiDB.CreatePanel(petbg, TukuiDB.petbuttonsize + (TukuiDB.petbuttonspacing * 2), (TukuiDB.petbuttonsize * 10) + (TukuiDB.petbuttonspacing * 11), "RIGHT", UIParent, "RIGHT", TukuiDB.Scale(-6), TukuiDB.Scale(-13.5))
	end

	local ltpetbg1 = CreateFrame("Frame", "TukuiLineToPetActionBarBackground", petbg)
	TukuiDB.CreatePanel(ltpetbg1, 30, 265, "TOPLEFT", petbg, "TOPRIGHT", 0, TukuiDB.Scale(-33))
	ltpetbg1:SetFrameLevel(0)
	ltpetbg1:SetAlpha(.8)
end

--BATTLEGROUND STATS FRAME
if TukuiCF["datatext"].battleground == true then
	local bgframe = CreateFrame("Frame", "TukuiInfoLeftBattleGround", UIParent)
	TukuiDB.CreatePanel(bgframe, 1, 1, "TOPLEFT", UIParent, "BOTTOMLEFT", 0, 0)
	bgframe:SetAllPoints(ileft)
	bgframe:SetFrameStrata("LOW")
	bgframe:SetFrameLevel(0)
	bgframe:EnableMouse(true)
end

--BOTTOM HORIZONTAL BAR FRAME
local bottomBarFrame = CreateFrame("Frame", "ChopsuiBottomHorizontalBar", UIParent)
TukuiDB.CreatePanel(bottomBarFrame, 1, TukuiDB.Scale(28), "BOTTOM", UIParent, "BOTTOM", 0, -2)
bottomBarFrame:SetPoint("LEFT", UIParent, "LEFT", -2, -2)
bottomBarFrame:SetPoint("RIGHT", UIParent, "RIGHT", 2, -2)
bottomBarFrame:SetFrameStrata("BACKGROUND")
bottomBarFrame:SetFrameLevel(0)

--LEFT CHAT WINDOW BACKGROUND
local leftChatFrame = CreateFrame("Frame", "ChopsuiChatBackgroundLeft", barbg)
TukuiDB.CreateTransparentPanel(leftChatFrame, TukuiCF["panels"].tinfowidth, TukuiDB.Scale(117), "BOTTOMLEFT", TukuiInfoLeft, "TOPLEFT", 0, 3)
TukuiDB.CreateShadow(leftChatFrame)
leftChatFrame:SetFrameStrata("BACKGROUND")
leftChatFrame:SetFrameLevel(0)

--LEFT CHAT BUTTONS
local socialChatButton = CreateFrame("Button", "ChopsuiSocialChatButton", ChopsuiChatBackgroundLeft)
TukuiDB.CreateTransparentPanel(socialChatButton, TukuiDB.Scale(10), TukuiDB.Scale(10), "TOPLEFT", ChopsuiChatBackgroundLeft, "TOPRIGHT", 5, 0)
--TukuiDB.CreateShadow(socialChatButton)
socialChatButton:SetScript("OnClick", function()
  ChatFrame2:Hide()
  ChatFrame3:Hide()
  ChatFrame1:Show()
end)

local logChatButton = CreateFrame("Button", "ChopsuiLogChatButton", ChopsuiSocialChatButton)
TukuiDB.CreateTransparentPanel(logChatButton, TukuiDB.Scale(10), TukuiDB.Scale(10), "TOPLEFT", ChopsuiSocialChatButton, "BOTTOMLEFT", 0, -5)
TukuiDB.CreateShadow(logChatButton)
logChatButton:SetScript("OnClick", function()
  ChatFrame1:Hide()
  ChatFrame3:Hide()
  ChatFrame2:Show()
end)

local generalChatButton = CreateFrame("Button", "ChopsuiGeneralChatButton", ChopsuiLogChatButton)
TukuiDB.CreateTransparentPanel(generalChatButton, TukuiDB.Scale(10), TukuiDB.Scale(10), "TOPLEFT", ChopsuiLogChatButton, "BOTTOMLEFT", 0, -5)
TukuiDB.CreateShadow(generalChatButton)
generalChatButton:SetScript("OnClick", function()
  ChatFrame1:Hide()
  ChatFrame2:Hide()
  ChatFrame3:Show()
end)

--RIGHT CHAT WINDOW BACKGROUND
local rightChatFrame = CreateFrame("Frame", "ChopsuiChatBackgroundRight", barbg)
TukuiDB.CreateTransparentPanel(rightChatFrame, TukuiCF["panels"].tinfowidth, TukuiDB.Scale(117), "BOTTOMRIGHT", TukuiInfoRight, "TOPRIGHT", 0, 3)
TukuiDB.CreateShadow(rightChatFrame)
rightChatFrame:SetFrameStrata("BACKGROUND")
rightChatFrame:SetFrameLevel(0)

--RIGHT CHAT BUTTONS
local lootChatButton = CreateFrame("Button", "ChopsuiLootChatButton", ChopsuiChatBackgroundRight)
TukuiDB.CreateTransparentPanel(lootChatButton, TukuiDB.Scale(10), TukuiDB.Scale(10), "TOPRIGHT", ChopsuiChatBackgroundRight, "TOPLEFT", -5, 0)
TukuiDB.CreateShadow(lootChatButton)
lootChatButton:SetScript("OnClick", function() Skada:SetActive(false) end)

local skadaChatButton = CreateFrame("Button", "ChopsuiSkadaChatButton", ChopsuiLootChatButton)
TukuiDB.CreateTransparentPanel(skadaChatButton, TukuiDB.Scale(10), TukuiDB.Scale(10), "TOPLEFT", ChopsuiLootChatButton, "BOTTOMLEFT", 0, -5)
TukuiDB.CreateShadow(skadaChatButton)
skadaChatButton:SetScript("OnClick", function() Skada:SetActive(true) end)
