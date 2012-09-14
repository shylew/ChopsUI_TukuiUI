-- Lock down local environment.
local PowerAuras = _G["PowerAuras"];
setfenv(1, PowerAuras);

--- Data provider class service definition.
local Timer = PowerAuras:RegisterServiceImplementation("Static", "Timer", {
	--- Default parameters table.
	Parameters = {
		Start = 0,
		End = 2^31 - 1,
	},
	--- Events table.
	Events = {},
});

--- Constructor function for the provider service.
-- @param parameters Configuration parameters for the service.
function Timer:New(parameters)
	return function()
		return parameters["Start"], parameters["End"];
	end;
end

--- Describes whether or not this service is 'static'. Static services
--  respond to no events and don't require updating, as their returned
--  value doesn't change. If all services in a provider are static, then
--  processing load can be reduced.
-- @return True if the service is static. False if not.
function Timer:IsStaticService()
	return true;
end

--- Upgrades a service from the specified version to the current version.
-- @param version The version to upgrade from.
-- @param params  The parameter table to be updated.
function Timer:Upgrade(version, params)
	
end