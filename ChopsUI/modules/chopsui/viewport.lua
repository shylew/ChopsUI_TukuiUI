local T, C, L = unpack(Tukui)
local viewportHeight = 130

ViewportFrame = CreateFrame("Frame", "ChopsUIInvViewportBackground")
ViewportFrame:SetFrameStrata("BACKGROUND")
ViewportFrame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 0, 0)
ViewportFrame:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, 0)
ViewportFrame:SetHeight(viewportHeight)

local border = CreateFrame("Frame", "ChopsUIViewportBorder")
border:SetTemplate()
border:SetPoint("TOPLEFT", ChopsUIInvViewportBackground, "TOPLEFT", -2, 0)
border:SetPoint("TOPRIGHT", ChopsUIInvViewportBackground, "TOPRIGHT", 2, 0)
border:SetHeight(1)
border:SetAlpha(0.3)
border:SetFrameStrata("BACKGROUND")

WorldFrame:SetPoint("BOTTOMRIGHT", 0, viewportHeight)
