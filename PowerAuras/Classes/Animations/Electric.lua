-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);