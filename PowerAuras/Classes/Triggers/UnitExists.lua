-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--- Trigger class definition.
local UnitExists = PowerAuras:RegisterTriggerClass("UnitExists", {
	--- Dictionary of default parameters this trigger uses.
	Parameters = {
		Units = PowerAuras:EncodeUnits("player"),
	},
	--- Dictionary of events this trigger responds to.
	Events = {
		ARENA_OPPONENT_UPDATE = "UnitExists",
		GROUP_ROSTER_UPDATE = "UnitExists",
		INSTANCE_ENCOUNTER_ENGAGE_UNIT = "UnitExists",
		PLAYER_FOCUS_CHANGED = "UnitExists",
		PLAYER_TARGET_CHANGED = "UnitExists",
		UNIT_AURA = "UnitExists",
		UNIT_ENTERED_VEHICLE = "UnitExists",
		UNIT_EXITED_VEHICLE = "UnitExists",
		UNIT_PET = "UnitExists",
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
-- @param actionID   The ID of the action that owns this trigger.
-- @param provider   The provider attached to this trigger.
function UnitExists:New(parameters, actionID, provider)
	-- Parameters.
	local units = PowerAuras:DecodeUnits(parameters["Units"]);

	-- Generate the function.
	if(type(units) == "string") then
		return ([[UnitExists(%q)]]):format(units);
	else
		return function(self, buffer, action, store)
			return PowerAuras:CheckUnits(units, _G.UnitExists);
		end
	end
end

--- Creates the controls for the basic activation editor frame.
-- @param frame The frame to apply controls to.
-- @param ... ID's to use for Get/SetParameter calls.
function UnitExists:CreateTriggerEditor(frame, ...)
	-- Unit pickerydoo.
	local unitBox = PowerAuras:Create("DialogBox", frame, nil, "UnitDialog",
		"Trigger", "Units", ...);
	unitBox:SetUserTooltip("UnitAura_Unit");
	unitBox:SetTitle(L["UnitAura_Unit"]);
	unitBox:SetRelativeWidth(1.0);
	unitBox:SetPadding(4, 0, 4, 0);
	unitBox:SetText(PowerAuras:GetParameter("Trigger", "Units", ...));
	unitBox:ConnectParameter("Trigger", "Units", unitBox.SetText, ...);
	unitBox.OnValueUpdated:Connect(PowerAuras:FormatString([[
		local self, value = ...;
		PowerAuras:SetParameter("Trigger", "Units", value, ${...});
	]], ...));
	frame:AddWidget(unitBox);
end

--- Returns true if the trigger is considered a 'support' trigger and can
--  be shown as an additional trigger option within the simple activation
--  editor.
function UnitExists:IsSupportTrigger()
	return true;
end

--- Upgrades the trigger from the specified version to the current version.
-- @param version The version to upgrade from.
-- @param params  The trigger parameters to upgrade.
function UnitExists:Upgrade(version, params)
	
end