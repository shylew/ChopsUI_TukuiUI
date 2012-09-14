local T, C, L = unpack(Tukui)
local viewportHeight = 143

local frame = CreateFrame("Frame", "ChopsUIInvViewportBackground")
frame:SetFrameStrata("BACKGROUND")
frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", 0, 0)
frame:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", 0, 0)
frame:SetHeight(viewportHeight)

local texture = frame:CreateTexture(nil, "BACKGROUND")
texture:SetTexture(0, 0, 0)
texture:SetAllPoints(frame)
frame.texture = texture

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

-- Some times getting some weird artifacts above the viewport, so make the
-- viewport less than the full requested height, and cheese it with an
-- overlaying frame hiding the artifacts.
WorldFrame:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, viewportHeight - 23)
