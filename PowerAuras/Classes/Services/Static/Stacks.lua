-- Lock down local environment.
local PowerAuras = _G["PowerAuras"];
setfenv(1, PowerAuras);

--- Data provider class service definition.
local Stacks = PowerAuras:RegisterServiceImplementation("Static", "Stacks", {
	--- Default parameters table.
	Parameters = {
		Value = 0,
	},
	--- Events table.
	Events = {},
});

--- Constructor function for the provider service.
-- @param parameters Configuration parameters for the service.
function Stacks:New(parameters)
	return function()
		return parameters["Value"];
	end;
end

--- Describes whether or not this service is 'static'. Static services
--  respond to no events and don't require updating, as their returned
--  value doesn't change. If all services in a provider are static, then
--  processing load can be reduced.
-- @return True if the service is static. False if not.
function Stacks:IsStaticService()
	return true;
end

--- Upgrades a service from the specified version to the current version.
-- @param version The version to upgrade from.
-- @param params  The parameter table to be updated.
function Stacks:Upgrade(version, params)
	
end