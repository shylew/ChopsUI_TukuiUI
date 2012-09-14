-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--- Interface implementation.
local Timer = PowerAuras:RegisterServiceInterface("Timer");

--- Returns the total number of return values for this instances of this
--  service interface.
function Timer:GetReturnCount()
	return 2;
end

--- Returns the default return values used by instances of this service
--  interface.
function Timer:GetDefaultValues()
	return 0, 2^31 - 1;
end