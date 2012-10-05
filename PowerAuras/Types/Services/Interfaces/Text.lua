-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--- Interface implementation.
local Text = PowerAuras:RegisterServiceInterface("Text");

--- Returns the total number of return values for this instances of this
--  service interface.
function Text:GetReturnCount()
	return 1;
end

--- Returns the default return values used by instances of this service
--  interface.
function Text:GetDefaultValues()
	return nil;
end