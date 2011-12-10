local T, C, L = unpack(Tukui)
if C.unitframes.enable ~= true then return end

local frame = TukuiTarget

-- Reposition the target frame.
frame:ClearAllPoints()
frame:SetPoint("BOTTOMRIGHT", InvTukuiActionBarBackground, "TOPRIGHT", -125, 8)

-- Remove debuffs from the target frame.
frame.Debuffs:Kill()

-- Move the buff frame to the right of the target frame instead of at the top.
-- Since changing the anchoring of the actual buff frame for some reason doesn't
-- work, we'll just kill the original buff frame and create a new one in its
-- place.

frame.Buffs:Kill()

local buffs = CreateFrame('Frame', nil, frame)
buffs:SetPoint('LEFT', frame, 'RIGHT', 6, -28)
buffs:SetWidth(54)
buffs:SetHeight(54)
buffs.size = 26
buffs.num = 4
buffs.spacing = 2
buffs.initialAnchor = 'TOPLEFT'
buffs.PostCreateIcon = T.PostCreateAura
buffs.PostUpdateIcon = T.PostUpdateAura
frame.Buffs = buffs
