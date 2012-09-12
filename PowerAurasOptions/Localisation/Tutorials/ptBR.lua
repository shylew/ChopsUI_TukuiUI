-- Ensure current locale matches.
if(GetLocale() ~= "ptBR") then return; end

-- Lock down local environment. Set function environment to the localization
-- table.
local PowerAuras = _G["PowerAuras"];
setfenv(1, PowerAuras.L);