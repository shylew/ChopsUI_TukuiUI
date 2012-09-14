-- Ensure current locale matches.
if(GetLocale() ~= "enCN") then return; end

-- Lock down local environment. Set function environment to the localization
-- table.
local PowerAuras = _G["PowerAuras"];
setfenv(1, PowerAuras.L);