local T, C, L = unpack(Tukui)

-- Move the minimap to the bottom left corner.
local frame = TukuiMinimap
frame:ClearAllPoints()
frame:Point("BOTTOMRIGHT", TukuiInfoRight, "TOPRIGHT", 0, 6)

-- Increase the map size.
frame:Size(165)
