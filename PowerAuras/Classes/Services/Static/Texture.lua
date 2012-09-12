-- Lock down local environment.
local PowerAuras = _G["PowerAuras"];
setfenv(1, PowerAuras);

--- Service implementation.
local Texture = PowerAuras:RegisterServiceImplementation("Static", "Texture", {
	--- Default parameters table.
	Parameters = {
		Texture = [[Interface\AddOns\PowerAuras\Textures\Aura1.tga]],
	},
	--- Events table.
	Events = {},
});

--- Constructor function for the provider service.
-- @param parameters Configuration parameters for the service.
function Texture:New(parameters)
	-- Generated function.
	local default = self:GetDefaultValues(parameters);
	return function()
		return parameters["Texture"] or default;
	end
end

--- Returns the default value for a service, optionally with the given
--  parameters.
-- @param params The parameters of the service.
function Texture:GetDefaultValues(params)
	return params and params["Texture"] or PowerAuras.DefaultIcon;
end

--- Describes whether or not this service is 'static'. Static services
--  respond to no events and don't require updating, as their returned
--  value doesn't change. If all services in a provider are static, then
--  processing load can be reduced.
-- @return True if the service is static. False if not.
function Texture:IsStaticService()
	return true;
end

--- Upgrades a service from the specified version to the current version.
-- @param version The version to upgrade from.
-- @param params  The parameter table to be updated.
function Texture:Upgrade(version, params)
	
end