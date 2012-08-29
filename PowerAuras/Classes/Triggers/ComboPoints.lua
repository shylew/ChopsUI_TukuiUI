-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--- Trigger class for combo point counting.
local ComboPoints = PowerAuras:RegisterTriggerClass("ComboPoints", {
	Parameters = {
		Match = 5,
		Operator = "==",
		IsVehicle = false,
	},
	Events = {
		PLAYER_TARGET_CHANGED = { "PlayerCombo", "VehicleCombo" },
		UNIT_COMBO_POINTS = function(buffer, unit)
			if(unit == "vehicle") then
				buffer.Triggers["VehicleCombo"] = true;
			elseif(unit == "player") then
				buffer.Triggers["PlayerCombo"] = true;
			end
		end,
		UPDATE_SHAPESHIFT_FORM = "PlayerCombo",
		UNIT_ENTERED_VEHICLE = "VehicleCombo",
		UNIT_EXITED_VEHICLE = "VehicleCombo",
		UNIT_TARGET = function(buffer, unit)
			if(unit == "vehicle") then
				buffer.Triggers["VehicleCombo"] = true;
			elseif(unit == "player") then
				buffer.Triggers["PlayerCombo"] = true;
			end
		end,
	},
	Services = {},
	ServiceMirrors = {
		Timer   = "TriggerData",
		Stacks  = "TriggerData",
		Texture = "TriggerData",
		Text    = "TriggerData",
	},
});

--- Constructs a new instance of the trigger and returns it.
-- @param parameters The parameters to construct the trigger from.
function ComboPoints:New(parameters)
	-- Extract parameters.
	local unit  = parameters["IsVehicle"] and "vehicle" or "player";
	local op    = parameters["Operator"];
	local match = parameters["Match"];

	-- Generate function.
	return function(self, buffer, action, store)
		local cp = GetComboPoints(unit, "target");
		if(PowerAuras:CheckOperator(cp, op, match)) then
			store.Stacks = cp;
			return true;
		else
			store.Stacks = nil;
			return false;
		end
	end
end

--- Creates the controls for the basic activation editor frame.
-- @param frame The frame to apply controls to.
-- @param ... ID's to use for Get/SetParameter calls.
function ComboPoints:CreateTriggerEditor(frame, ...)
	-- Expose the truth. Combo Points 2012.
	local operator = PowerAuras:Create("P_OperatorDropdown", frame);
	operator:SetUserTooltip("Operator");
	operator:LinkParameter("Trigger", "Operator", ...);
	operator:SetRelativeWidth(0.4);
	operator:SetPadding(4, 0, 2, 0);
	-- Points slider.
	local points = PowerAuras:Create("P_Slider", frame);
	points:SetUserTooltip("ComboPoints");
	points:SetMinMaxValues(0, MAX_COMBO_POINTS);
	points:SetValueStep(1);
	points:LinkParameter("Trigger", "Match", ...);
	points:SetRelativeWidth(0.4);
	points:SetPadding(2, 0, 2, 0);
	points:SetTitle(L["ComboPoints"]);
	-- Allow tracking vehicle combo points.
	local isVehicle = PowerAuras:Create("P_Checkbox", frame);
	isVehicle:SetUserTooltip("ComboPoints_Vehicle");
	isVehicle:SetText(L["VehicleCombo"]);
	isVehicle:LinkParameter("Trigger", "IsVehicle", ...);
	isVehicle:SetRelativeWidth(1.0);
	isVehicle:SetPadding(4, 0, 4, 0);
	-- Add widgets to frame.
	frame:AddWidget(operator);
	frame:AddWidget(points);
	frame:AddRow(4);
	frame:AddWidget(isVehicle);
end

--- Returns the trigger type name.
-- @param params The parameters of the trigger.
function ComboPoints:GetTriggerType(params)
	return (params["IsVehicle"] and "VehicleCombo" or "PlayerCombo");
end

--- Initialises the per-trigger data store. This can be used to hold
--  values which can then be exposed to other parts of the system.
-- @param params The parameters of this trigger.
-- @return An item to store, or nil.
function ComboPoints:InitialiseDataStore()
	return { Stacks = 0 };
end

--- Upgrades the trigger from the specified version to the current version.
-- @param version The version to upgrade from.
-- @param params  The trigger parameters to upgrade.
function ComboPoints:Upgrade(version, params)
	
end