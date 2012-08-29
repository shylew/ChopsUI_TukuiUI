-- Lock down local environment.
local PowerAuras = _G["PowerAuras"];
setfenv(1, PowerAuras);

--- Data provider class service definition.
local Text = PowerAuras:RegisterServiceImplementation("Static", "Text", {
	--- Default parameters table.
	Parameters = {},
	--- Events table.
	Events = {},
});

--- Constructor function for the provider service.
-- @param parameters Configuration parameters for the service.
function Text:New(parameters)
	-- Generated function.
	return function(subs)
		return subs;
	end
end

--- Upgrades a service from the specified version to the current version.
-- @param version The version to upgrade from.
-- @param params  The parameter table to be updated.
function Text:Upgrade(version, params)
	
end