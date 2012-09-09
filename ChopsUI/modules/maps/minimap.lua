local T, C, L = unpack(Tukui)

-- Move the minimap to the bottom left corner.
local frame = TukuiMinimap
frame:ClearAllPoints()
frame:Point("BOTTOMRIGHT", TukuiInfoRight, "TOPRIGHT", 0, 6)
