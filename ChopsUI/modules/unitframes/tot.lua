local T, C, L = unpack(Tukui)
if C.unitframes.enable ~= true then return end

local frame = TukuiTargetTarget
local health = frame.Health

-- Reposition the ToT frame.
frame:ClearAllPoints()
frame:SetPoint("LEFT", TukuiTarget, "RIGHT", 80, 0)

-- Change the size of the pet frame.
frame:Size(129, 57)

-- Change the size of the health bar.
health:Height(38)
