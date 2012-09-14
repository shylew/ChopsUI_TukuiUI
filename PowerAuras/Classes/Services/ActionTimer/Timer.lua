-- Lock down local environment.
local PowerAuras = _G["PowerAuras"];
setfenv(1, PowerAuras);

--- Data provider class service definition.
local Timer = PowerAuras:RegisterServiceImplementation("ActionTimer", "Timer", {
	--- Default parameters table.
	Parameters = {
		ID = -1,
	},
	--- Events table.
	Events = {},
});

--- Constructor function for the provider service.
-- @param parameters Configuration parameters for the service.
function Timer:New(parameters)
	-- Upvalue the action ID.
	local actionID = parameters["ID"];
	local min, max = self:GetDefaultValues(parameters);
	-- A timer service function returns two values: The first is the start
	-- time and the second is the end time. Either can be omitted.
	return function()
		-- We only know the start time, not the end time :)
		local start = PowerAuras:GetActionActivationTime(actionID);
		return (start or min), max;
	end;
end

--- Creates the parameter editor frame for this implemenation.
-- @param frame The frame to add widgets to.
-- @param ...   ID's to use for Get/SetParameter calls.
function Timer:CreateEditor(frame, ...)
	-- Action ID.
	local action = PowerAuras:Create("P_NumberBox", frame);
	action:SetPadding(4, 0, 2, 0);
	action:SetRelativeWidth(0.45);
	action:SetTitle(L["Action"]);
	action:SetMinMaxValues(1, PowerAuras.MAX_ACTIONS_PER_PROFILE);
	action:LinkParameter("Provider", "ID", 0, ...);
	frame:AddWidget(action);
end

--- Returns a dictionary of actions that this service will depend upon in
--  terms of state changes. Returns action IDs as the keys of the table.
-- @param params The parameters of the service.
function Timer:GetActionDependencies(params)
	return { [params["ID"]] = false };
end

--- Upgrades a service from the specified version to the current version.
-- @param version The version to upgrade from.
-- @param params  The parameter table to be updated.
function Timer:Upgrade(version, params)
	
end