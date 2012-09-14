-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--- Data provider class service definition.
local Texture = PowerAuras:RegisterServiceImplementation("Stance", "Texture", {
	--- Default parameters table.
	Parameters = {},
	--- Events table.
	Events = {
		UPDATE_BONUS_ACTIONBAR = true,
		UPDATE_SHAPESHIFT_FORM = true,
		UPDATE_SHAPESHIFT_FORMS = true,
		UPDATE_SHAPESHIFT_USABLE = true,
		UPDATE_POSSESS_BAR = true,
	},
});

--- Constructor function for the provider service.
-- @param parameters Configuration parameters for the service.
function Texture:New(parameters)
	-- Generated function.
	local default = self:GetDefaultValues(parameters);
	return function()
		-- Return information on the active stance.
		for i = 1, GetNumShapeshiftForms() do
			local icon, _, active = GetShapeshiftFormInfo(i);
			if(active) then
				return icon;
			end
		end
		-- Failed.
		return default;
	end
end

--- Creates the parameter editor frame for this implemenation.
-- @param frame The frame to add widgets to.
-- @param ...   ID's to use for Get/SetParameter calls.
function Texture:CreateEditor(frame, ...)
end

--- Upgrades a service from the specified version to the current version.
-- @param version The version to upgrade from.
-- @param params  The parameter table to be updated.
function Texture:Upgrade(version, params)
end