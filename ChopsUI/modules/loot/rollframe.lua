local T, C, L = unpack(Tukui)

-- We actually don't need to move this at the moment. Keeping this file here for
-- easy access if we do later.
local frame = TukuiRollAnchor
frame:ClearAllPoints()
frame:SetPoint('BOTTOM', InvTukuiActionBarBackground, 'TOP', 0, 350)
