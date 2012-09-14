-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

-- Function upvalues.
local GetHealth, GetMaxHealth = UnitHealth, UnitHealthMax;

--- Trigger class definition.
local UnitHealth = PowerAuras:RegisterTriggerClass("UnitHealth", {
	--- Dictionary of default parameters this trigger uses.
	Parameters = {
		Operator = "<=",
		Value = 50,
		IsAbsolute = false,
		Unit = PowerAuras:EncodeUnits("player"),
	},
	--- Dictionary of events this trigger responds to.
	Events = {
		PLAYER_FOCUS_CHANGED = "FocusHealth",
		PLAYER_TARGET_CHANGED = "TargetHealth",
		UNIT_HEALTH = function(buffer, unit)
			if(unit == "player") then
				buffer.Triggers["PlayerHealth"] = true;
			elseif(unit == "pet") then
				buffer.Triggers["PetHealth"] = true;
			elseif(unit == "vehicle") then
				buffer.Triggers["VehicleHealth"] = true;
			elseif(unit == "target") then
				buffer.Triggers["TargetHealth"] = true;
			elseif(unit == "focus") then
				buffer.Triggers["FocusHealth"] = true;
			end
		end,
		UNIT_HEALTH_FREQUENT = function(buffer, unit)
			if(unit == "player") then
				buffer.Triggers["PlayerHealth"] = true;
			elseif(unit == "pet") then
				buffer.Triggers["PetHealth"] = true;
			elseif(unit == "vehicle") then
				buffer.Triggers["VehicleHealth"] = true;
			elseif(unit == "target") then
				buffer.Triggers["TargetHealth"] = true;
			elseif(unit == "focus") then
				buffer.Triggers["FocusHealth"] = true;
			end
		end,
		UNIT_MAXHEALTH = function(buffer, unit)
			if(unit == "player") then
				buffer.Triggers["PlayerHealth"] = true;
			elseif(unit == "pet") then
				buffer.Triggers["PetHealth"] = true;
			elseif(unit == "vehicle") then
				buffer.Triggers["VehicleHealth"] = true;
			elseif(unit == "target") then
				buffer.Triggers["TargetHealth"] = true;
			elseif(unit == "focus") then
				buffer.Triggers["FocusHealth"] = true;
			end
		end,
		UNIT_ENTERED_VEHICLE = "VehicleHealth",
		UNIT_EXITED_VEHICLE = "VehicleHealth",
		UNIT_PET = "PetHealth",
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

--- Callback for CheckUnits in the trigger.
local function CheckValue(unit, op, match, abs)
	-- Get current/max values.
	local cur, max = GetHealth(unit), GetMaxHealth(unit);
	cur = (cur or 0);
	max = (max or 0);
	-- Check the value.
	if(abs) then
		return PowerAuras:CheckOperator(cur, op, match), cur, 0, max;
	else
		local perc = (cur / (max == 0 and 1 or max)) * 100;
		return PowerAuras:CheckOperator(perc, op, match), cur, 0, max;
	end
end

--- Constructs a new instance of the trigger and returns it.
-- @param parameters The parameters to construct the trigger from.
function UnitHealth:New(parameters)
	-- Get parameters.
	local operator, value = parameters["Operator"], parameters["Value"];
	local isAbs = parameters["IsAbsolute"];
	local units = PowerAuras:DecodeUnits(parameters["Unit"]);

	-- Generate the trigger.
	return function(self, buffer, action, store)
		-- Check units.
		local state, match, value, min, max = PowerAuras:CheckUnits(
			units, CheckValue, operator, value, isAbs
		);

		-- Got one?
		if(state) then
			local checkVal, checkMax = (value - min), (max - min);
			local perc = (checkVal / (checkMax <= 0 and 1 or checkMax)) * 100;
			store.Stacks        = (isAbs and value or perc);
			store.Text["name"]  = UnitName(match);
			store.Text["value"] = value;
			store.Text["min"]   = min;
			store.Text["max"]   = max;
			store.Text["perc"]  = perc;
		else
			store.Stacks        = nil;
			store.Text["name"]  = nil
			store.Text["value"] = nil;
			store.Text["min"]   = nil;
			store.Text["max"]   = nil;
			store.Text["perc"]  = nil;
		end

		-- Done.
		return state;
	end
end

--- Creates the controls for the basic activation editor frame.
-- @param frame The frame to apply controls to.
-- @param ... ID's to use for Get/SetParameter calls.
function UnitHealth:CreateTriggerEditor(frame, ...)
	-- Unit dialog.
	local unitBox = PowerAuras:Create("DialogBox", frame, nil, "UnitDialog",
		"Trigger", "Unit", ...);
	unitBox:SetUserTooltip("UnitStats_Unit");
	unitBox:SetTitle(L["Unit"]);
	unitBox:SetRelativeWidth(0.6);
	unitBox:SetPadding(4, 0, 2, 0);
	unitBox:SetText(PowerAuras:GetParameter("Trigger", "Unit", ...));
	unitBox:ConnectParameter("Trigger", "Unit", unitBox.SetText, ...);
	unitBox.OnValueUpdated:Connect(PowerAuras:FormatString([[
		local self, value = ...;
		PowerAuras:SetParameter("Trigger", "Unit", value, ${...});
	]], ...));
	frame:AddWidget(unitBox);

	-- Absolute checkbox.
	local isAbs = PowerAuras:Create("P_Checkbox", frame);
	isAbs:SetUserTooltip("UnitStats_Abs");
	isAbs:SetRelativeWidth(0.4);
	isAbs:SetPadding(2, 0, 4, 0);
	isAbs:SetMargins(0, 20, 0, 0);
	isAbs:SetText(L["Absolute"]);
	isAbs:LinkParameter("Trigger", "IsAbsolute", ...);
	isAbs:ConnectParameter("Trigger", "IsAbsolute", function()
		PowerAuras.Editor:Refresh()
	end);
	frame:AddWidget(isAbs);

	-- Value selection.
	if(PowerAuras:GetParameter("Trigger", "IsAbsolute", ...)) then
		-- Use a numberbox for bounded input.
		local value = PowerAuras:Create("P_NumberBox", frame);
		value:SetUserTooltip("UnitStats_Value");
		value:SetRelativeWidth(0.6);
		value:SetPadding(4, 0, 2, 0);
		value:SetTitle(L["Value"]);
		value:SetValueStep(1);
		value:SetMinMaxValues(0, 2^31 - 1);
		value:LinkParameter("Trigger", "Value", 0, ...);
		frame:AddWidget(value);
	else
		-- 0-100% dropdown.
		local value = PowerAuras:Create("P_Slider", frame);
		value:SetUserTooltip("UnitStats_Value");
		value:SetRelativeWidth(0.6);
		value:SetPadding(4, 0, 2, 0);
		value:SetTitle(L["Value"]);
		value:SetMinMaxValues(0, 100);
		value:SetValueStep(1);
		value:SetMinMaxLabels("%d%%", "%d%%");
		value:LinkParameter("Trigger", "Value", ...);
		frame:AddWidget(value);
	end

	-- Operator dropdown.
	local op = PowerAuras:Create("P_OperatorDropdown", frame);
	op:SetUserTooltip("Operator");
	op:SetRelativeWidth(0.4);
	op:SetPadding(2, 0, 4, 0);
	op:LinkParameter("Trigger", "Operator", ...);
	frame:AddWidget(op);
end

--- Returns the trigger type name.
-- @param params The parameters of the trigger.
function UnitHealth:GetTriggerType(params)
	return ("%sHealth"):format(params["Unit"]:gsub("^%a", string.upper, 1));
end

--- Initialises the per-trigger data store. This can be used to hold
--  values which can then be exposed to other parts of the system.
-- @param params The parameters of this trigger.
-- @return An item to store, or nil.
function UnitHealth:InitialiseDataStore(params)
	-- We can communicate to sources, so set this up appropriately.
	return {
		Stacks = 0,
		Text = {
			name  = "",
			value = 0,
			min   = 0,
			max   = 0,
			perc  = 0,
		},
	};
end

--- Upgrades the trigger from the specified version to the current version.
-- @param version The version to upgrade from.
-- @param params  The trigger parameters to upgrade.
function UnitHealth:Upgrade(version, params)
end