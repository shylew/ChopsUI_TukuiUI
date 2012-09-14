local T, C, L = unpack(Tukui)

-- Move the minimap to the bottom left corner.
local frame = TukuiMinimap
frame:ClearAllPoints()
frame:Point("BOTTOMRIGHT", TukuiInfoRight, "TOPRIGHT", 0, 6)

-- Increase the map size.
frame:Size(165)
Minimap:SetParent("UIParent")
Minimap:ClearAllPoints()
Minimap:Size(frame:GetWidth() - 4, frame:GetHeight() - 4)
Minimap:SetParent(TukuiMinimap)
Minimap:ClearAllPoints()
Minimap:Point("TOPLEFT", 2, -2)
Minimap:Point("BOTTOMRIGHT", -2, 2)
