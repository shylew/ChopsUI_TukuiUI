-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

local GTFOLastActive = {};

--- Backwards compatability.
_G["PowaAuras"] = {
	AurasByType = { GTFOHigh = true }, 
	MarkAuras = function(_, type)
		GTFOLastActive[type] = GetTime();
		PowerAuras:MarkTriggerType(type);
	end,
};

--- Trigger class definition.
local GTFO = PowerAuras:RegisterTriggerClass("GTFO", {
	--- Dictionary of default parameters this trigger uses.
	Parameters = {
		Type = "GTFOHigh",
		Duration = 0.5,
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
function GTFO:New(parameters)
	local type, duration = parameters["Type"], parameters["Duration"];
	return function()
		return (GTFOLastActive[type] ~= nil
			and GetTime() < GTFOLastActive[type] + duration)
	end;
end

--- Creates the controls for the basic activation editor frame.
-- @param frame The frame to apply controls to.
-- @param ... ID's to use for Get/SetParameter calls.
function GTFO:CreateTriggerEditor(frame, ...)
	-- Construct widgets.
	local gtfo = PowerAuras:Create("P_Dropdown", frame);
	gtfo:SetUserTooltip("GTFO_Type");
	gtfo:SetRelativeWidth(0.5);
	gtfo:SetPadding(4, 0, 2, 0);
	gtfo:SetTitle(L["Type"]);
	gtfo:AddCheckItem("GTFOLow", L["GTFO_LowDamage"]);
	gtfo:AddCheckItem("GTFOHigh", L["GTFO_HighDamage"]);
	gtfo:AddCheckItem("GTFOFail", L["GTFO_FailAlert"]);
	gtfo:AddCheckItem("GTFOFriendlyFire", L["GTFO_FriendlyFire"]);
	gtfo:LinkParameter("Trigger", "Type", ...);
	frame:AddWidget(gtfo);

	-- Time to remain active.
	local duration = PowerAuras:Create("P_Slider", frame);
	duration:SetUserTooltip("GTFO_Duration");
	duration:SetRelativeWidth(0.5);
	duration:SetPadding(2, 0, 4, 0);
	duration:SetTitle(L["Duration"]);
	duration:SetMinMaxValues(0.25, 30);
	duration:SetValueStep(0.05);
	duration:LinkParameter("Trigger", "Duration", ...);
	frame:AddWidget(duration);
end

--- Returns the trigger type name.
-- @param params The parameters of the trigger.
function GTFO:GetTriggerType(params)
	return params["Type"];
end

--- Determines whether or not a trigger requires per-frame updates.
-- @param params The parameters of the trigger.
-- @return True if updates are required, false if not.
-- @return The first value is the default timed state on creation. The 
--         second boolean is whether or not the timed status is capable of
--         being toggled by the trigger.
function GTFO:IsTimed(params)
	return true, false;
end

--- Upgrades the trigger from the specified version to the current version.
-- @param version The version to upgrade from.
-- @param params  The trigger parameters to upgrade.
function GTFO:Upgrade(version, params)
	-- GTFO fix: Medium isn't a type.
	if(version < PowerAuras.Version("5.0.0.O")) then
		if(params.Type == "GTFOMedium") then
			params.Type = "GTFOHigh";
		end
	end
end