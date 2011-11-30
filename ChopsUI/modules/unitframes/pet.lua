local T, C, L = unpack(Tukui)
if C.unitframes.enable ~= true then return end

local frame = TukuiPet
local health = frame.Health
local power = frame.Power

-- Reposition the pet frame.
frame:ClearAllPoints()
frame:SetPoint("RIGHT", TukuiPlayer, "LEFT", -67, 0)

-- Change the size of the pet frame.
frame:Size(129, 57)

-- Change the size of the health and power bars.
health:Height(30)
power:Height(7)
