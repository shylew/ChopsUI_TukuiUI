-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--- Interface implementation.
local Stacks = PowerAuras:RegisterServiceInterface("Stacks");

--- Returns the total number of return values for this instances of this
--  service interface.
function Stacks:GetReturnCount()
	return 1;
end

--- Returns the default return values used by instances of this service
--  interface.
function Stacks:GetDefaultValues()
	return 0;
end