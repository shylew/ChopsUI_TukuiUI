local T, C, L = unpack(Tukui)
if C.unitframes.enable ~= true then return end

local frame = TukuiTarget

-- Reposition the target frame.
frame:ClearAllPoints()
frame:SetPoint("BOTTOMRIGHT", InvTukuiActionBarBackground, "TOPRIGHT", -125, 8)

-- Remove debuffs from the target frame.
frame.Debuffs:Kill()

-- Move the buff frame to the right of the target frame instead of at the top.
frame.Buffs:ClearAllPoints()
frame.Buffs:SetPoint('LEFT', frame, 'RIGHT', 6, -28)
frame.Buffs:SetWidth(54)
frame.Buffs:SetHeight(54)
frame.Buffs.size = 26
frame.Buffs.num = 4
frame.Buffs.spacing = 2
frame.Buffs.InitialAnchor = 'TOPLEFT'

-- Stub out the anchoring methods of the buff frame to prevent OnUpdate events
-- from moving them.
frame.Buffs.ClearAllPoints = T.dummy
frame.Buffs.SetPoint = T.dummy
frame.Buffs.Point = T.dummy
