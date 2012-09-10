local T, C, L = unpack(Tukui)
local viewportHeight = 143

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

WorldFrame:SetUserPlaced(false)

local h, w = GetScreenHeight(), GetScreenWidth()
if(GetCVarBool'useUiScale') then
  local s = GetCVar'uiscale' or 1
  h, w = h * s, w * s
end
WorldFrame:SetWidth(w)
WorldFrame:SetHeight(h)

WorldFrame:SetPoint("TOP")
WorldFrame:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, viewportHeight)
