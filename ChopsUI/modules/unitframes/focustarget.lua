local T, C, L = unpack(Tukui)
if C.unitframes.enable ~= true then return end

local frame = TukuiFocusTarget
local castbar = frame.Castbar

-- Remove the cast bar from the focus frame.
castbar:Kill()

-- Change the size of the focus target frame.
frame:Size(129, 36)
