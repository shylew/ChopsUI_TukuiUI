local T, C, L = unpack(Tukui)

--ViewportOverlay = WorldFrame:CreateTexture(nil, "BACKGROUND")
--ViewportOverlay:SetTexture(0, 0, 0, 1)
--ViewportOverlay:SetPoint("TOPLEFT", UIParent, "TOPLEFT", -1, 1)
--ViewportOverlay:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 1, -1)
ViewportFrame = CreateFrame("Frame", "ChopsUIInvViewportBackground")
ViewportFrame:SetFrameStrata("BACKGROUND")
ViewportFrame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 0, 0)
ViewportFrame:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, 0)
ViewportFrame:SetHeight(130)
--local t = ViewportFrame:CreateTexture(nil,"BACKGROUND")
--t:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Factions.blp")
--t:SetAllPoints(ViewportFrame)
--ViewportFrame.texture = t

WorldFrame:SetPoint("BOTTOMRIGHT", 0, 130)
