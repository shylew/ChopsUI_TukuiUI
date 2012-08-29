-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--- Interface implementation.
local Texture = PowerAuras:RegisterServiceInterface("Texture");

--- Returns the total number of return values for this instances of this
--  service interface.
function Texture:GetReturnCount()
	return 1;
end

--- Returns the default return values used by instances of this service
--  interface.
function Texture:GetDefaultValues()
	return DefaultIcon;
end