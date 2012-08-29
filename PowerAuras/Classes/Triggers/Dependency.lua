-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--- Trigger class definition.
local Dependency = PowerAuras:RegisterTriggerClass("Dependency", {
	--- Dictionary of default parameters this trigger uses.
	Parameters = {
		ID = -1,
	},
	--- Dictionary of events this trigger responds to.
	Events = {
	},
	--- Dictionary of provider services required by this trigger type.
	Services = {
	},
	--- Dictionary of supported trigger > service conversions.
	ServiceMirrors = {
		Stacks  = "TriggerData",
		Text    = "TriggerData",
		Texture = "TriggerData",
		Timer   = "TriggerData",
	},
});

--- Constructs a new instance of the trigger and returns it.
-- @param parameters The parameters to construct the trigger from.
function Dependency:New(parameters)
	return ([[PowerAuras:GetActionActivationState(%d)]]):format(
		parameters["ID"]
	);
end

--- Creates the controls for the basic activation editor frame.
-- @param frame The frame to apply controls to.
-- @param ... ID's to use for Get/SetParameter calls.
function Dependency:CreateTriggerEditor(frame, ...)
	-- Construct widgets.
	local id = PowerAuras:Create("P_NumberBox", frame);
	id:SetUserTooltip("Dependency_AID");
	id:SetRelativeWidth(0.5);
	id:SetPadding(4, 0, 2, 0);
	id:SetTitle(L["Action"]);
	id:SetMinMaxValues(-1, PowerAuras.MAX_ACTIONS_PER_PROFILE);
	id:SetValueStep(1);
	id:LinkParameter("Trigger", "ID", 0, ...);
	frame:AddWidget(id);
end

--- Returns a dictionary of actions that this trigger will depend upon in
--  terms of state changes. Returns action IDs as the keys of the table.
-- @param params The parameters of the trigger.
function Dependency:GetActionDependencies(params)
	return { [params["ID"]] = true };
end

--- Upgrades the trigger from the specified version to the current version.
-- @param version The version to upgrade from.
-- @param params  The trigger parameters to upgrade.
function Dependency:Upgrade(version, params)
	
end