-- Ensure current locale matches.
if(GetLocale() ~= "enTW") then return; end

-- Lock down local environment. Set function environment to the localization
-- table.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras.L);