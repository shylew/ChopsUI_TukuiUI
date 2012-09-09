local T, C, L = unpack(Tukui)

ViewportOverlay = WorldFrame:CreateTexture(nil, "BACKGROUND")
ViewportOverlay:SetTexture(0, 0, 0, 1)
ViewportOverlay:SetPoint("TOPLEFT", UIParent, "TOPLEFT", -1, 1)
ViewportOverlay:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 1, -1)

WorldFrame:SetPoint("BOTTOMRIGHT", 0, 130)
