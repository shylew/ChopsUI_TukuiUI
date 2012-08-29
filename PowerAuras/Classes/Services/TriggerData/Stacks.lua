-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--- Data provider class service definition.
local Stacks = PowerAuras:RegisterServiceImplementation(
	"TriggerData", "Stacks", {
	--- Default parameters table.
	Parameters = {
		Action = 1,
		Trigger = 1,
	},
	--- Events table.
	Events = {},
});

--- Constructor function for the provider service.
-- @param parameters Configuration parameters for the service.
function Stacks:New(parameters)
	-- Upvalues.
	local action, index = parameters["Action"], parameters["Trigger"];
	local default = self:GetDefaultValues(parameters);
	-- Generated function.
	return function()
		-- Access the store.
		local store = PowerAuras:GetTriggerStore(action, index);
		if(type(store) == "table") then
			return store.Stacks or default;
		else
			return default;
		end
	end
end

--- Returns true if this service can be created from a trigger. This is
--  an override that takes precedence over trigger -> source conversions.
-- @param id     The ID of the action for the trigger.
-- @param index  The index of the trigger.
-- @return True if supported, false if not.
function Stacks:CanCreateFromTrigger(id, index)
	-- We support any trigger, because that's how we roll.
	return true;
end

--- Creates the parameter editor frame for this implemenation.
-- @param frame The frame to add widgets to.
-- @param ...   ID's to use for Get/SetParameter calls.
function Stacks:CreateEditor(frame, ...)
	-- Action ID.
	local action = PowerAuras:Create("P_NumberBox", frame);
	action:SetPadding(4, 0, 2, 0);
	action:SetRelativeWidth(0.45);
	action:SetTitle(L["Action"]);
	action:SetMinMaxValues(1, PowerAuras.MAX_ACTIONS_PER_PROFILE);
	action:LinkParameter("Provider", "Action", 0, ...);
	frame:AddWidget(action);

	-- Trigger ID.
	local trigger = PowerAuras:Create("P_NumberBox", frame);
	trigger:SetPadding(2, 0, 4, 0);
	trigger:SetRelativeWidth(0.45);
	trigger:SetTitle(L["Trigger"]);
	trigger:SetMinMaxValues(1, PowerAuras.MAX_TRIGGERS_PER_ACTION);
	trigger:LinkParameter("Provider", "Trigger", 0, ...);
	frame:AddWidget(trigger);
end

--- Performs a trigger to source conversion.
-- @param tp    The trigger parameters to convert/copy.
-- @param out   The output parameter table to modify.
-- @param id    The ID of the action for this trigger.
-- @param index The index of the trigger.
-- @return True on success, false if an unsupported conversion is done.
function Stacks:CreateFromTrigger(tp, out, id, index)
	-- Simply store the action/trigger indices.
	out.Action = id;
	out.Trigger = index;
	return true;
end

--- Returns a dictionary of actions that this service will depend upon in
--  terms of state changes. Returns action IDs as the keys of the table.
-- @param params The parameters of the service.
function Stacks:GetActionDependencies(params)
	return { [params["Action"]] = false };
end

--- Upgrades a service from the specified version to the current version.
-- @param version The version to upgrade from.
-- @param params  The parameter table to be updated.
function Stacks:Upgrade(version, params)
end