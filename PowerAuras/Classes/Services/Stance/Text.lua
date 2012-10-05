-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--- Data provider class service definition.
local Text = PowerAuras:RegisterServiceImplementation("Stance", "Text", {
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
function Text:New(parameters)
	-- Generated function.
	return function(subs)
		-- Reset subs.
		subs["icon"], subs["name"], subs["active"], subs["castable"] = 
			"", "", "", "";
		-- Return information on the active stance.
		for i = 1, GetNumShapeshiftForms() do
			local icon, name, active, castable = GetShapeshiftFormInfo(i);
			if(active) then
				subs["icon"] = icon;
				subs["name"] = name;
				subs["active"] = not not active;
				subs["castable"] = not not castable;
			end
		end
	end
end

--- Creates the parameter editor frame for this implemenation.
-- @param frame The frame to add widgets to.
-- @param ...   ID's to use for Get/SetParameter calls.
function Text:CreateEditor(frame, ...)
end

--- Upgrades a service from the specified version to the current version.
-- @param version The version to upgrade from.
-- @param params  The parameter table to be updated.
function Text:Upgrade(version, params)
end