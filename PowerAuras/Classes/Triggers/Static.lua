-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--- Trigger class definition.
local Static = PowerAuras:RegisterTriggerClass("Static", {
	--- Dictionary of default parameters this trigger uses.
	Parameters = {},
	--- Dictionary of events this trigger responds to.
	Events = {},
	--- Dictionary of provider services required by this trigger type.
	Services = {},
	--- Dictionary of supported trigger > service conversions.
	ServiceMirrors = {
		Stacks  = "TriggerData",
		Text    = "TriggerData",
		Texture = "TriggerData",
		Timer   = "TriggerData",
	},
});

--- Constructs a new instance of the trigger and returns it.
-- @param params The parameters to construct the trigger from.
function Static:New(params)
	return [[true]];
end

--- Creates the controls for the basic activation editor frame.
-- @param frame The frame to apply controls to.
-- @param ... ID's to use for Get/SetParameter calls.
function Static:CreateTriggerEditor(frame, ...)
	-- No config message.
	local l = PowerAuras:Create("Label", frame);
	l:SetText(L["TriggerNoConf"]);
	l:SetRelativeWidth(1.0);
	l:SetHeight(36);
	l:SetJustifyH("CENTER");
	l:SetJustifyV("MIDDLE");
	frame:AddWidget(l);
end

--- Return true if the trigger supports lazy checks. Lazy triggers
--  require that their individual trigger type be flagged for a recheck
--  before being re-processed within an already-flagged action.
--  Returns false by default if this trigger has dependencies, or is timed.
function Static:SupportsLazyChecks(params)
	-- No point in being lazily checked.
	return false;
end

--- Upgrades the trigger from the specified version to the current version.
-- @param version The version to upgrade from.
-- @param params  The trigger parameters to upgrade.
function Static:Upgrade(version, params)
end