-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

-- Function upvalues.
local GetPower, GetMaxPower = UnitPower, UnitPowerMax;

--- Trigger class definition.
local UnitPower = PowerAuras:RegisterTriggerClass("UnitPower", {
	--- Dictionary of default parameters this trigger uses.
	Parameters = {
		Operator = "<=",
		Value = 50,
		IsAbsolute = false,
		Unit = PowerAuras:EncodeUnits("player"),
		-- Default resource is class-based.
		Resource = (UnitPowerType("player") == 1 and "Rage"
			or UnitPowerType("player") == 2 and "Focus"
			or UnitPowerType("player") == 3 and "Energy"
			or UnitPowerType("player") == 6 and "RunicPower"
			or "Mana"),
	},
	--- Dictionary of events this trigger responds to.
	Events = {
		PLAYER_FOCUS_CHANGED = "FocusPower",
		PLAYER_TARGET_CHANGED = "TargetPower",
		UNIT_POWER = function(buffer, unit)
			if(unit == "player") then
				buffer.Triggers["PlayerPower"] = true;
			elseif(unit == "pet") then
				buffer.Triggers["PetPower"] = true;
			elseif(unit == "vehicle") then
				buffer.Triggers["VehiclePower"] = true;
			elseif(unit == "target") then
				buffer.Triggers["TargetPower"] = true;
			elseif(unit == "focus") then
				buffer.Triggers["FocusPower"] = true;
			end
		end,
		UNIT_POWER_FREQUENT = function(buffer, unit)
			if(unit == "player") then
				buffer.Triggers["PlayerPower"] = true;
			elseif(unit == "pet") then
				buffer.Triggers["PetPower"] = true;
			elseif(unit == "vehicle") then
				buffer.Triggers["VehiclePower"] = true;
			elseif(unit == "target") then
				buffer.Triggers["TargetPower"] = true;
			elseif(unit == "focus") then
				buffer.Triggers["FocusPower"] = true;
			end
		end,
		UNIT_MAXPOWER = function(buffer, unit)
			if(unit == "player") then
				buffer.Triggers["PlayerPower"] = true;
			elseif(unit == "pet") then
				buffer.Triggers["PetPower"] = true;
			elseif(unit == "vehicle") then
				buffer.Triggers["VehiclePower"] = true;
			elseif(unit == "target") then
				buffer.Triggers["TargetPower"] = true;
			elseif(unit == "focus") then
				buffer.Triggers["FocusPower"] = true;
			end
		end,
		UNIT_ENTERED_VEHICLE = "VehiclePower",
		UNIT_EXITED_VEHICLE = "VehiclePower",
		UNIT_PET = "PetPower",
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

--- Cache for the minimum values of power types.
local PowerTypeMinimums = setmetatable({}, {
	__index = function(self, k)
		-- Extract the data and store it.
		local data = bit.rshift(PowerAuras.UnitPowerTypeBounds[k], 16);
		local inf, sign = bit.band(data, 0x8000), bit.band(data, 0x4000);
		local value = bit.band(data, 0x3FFF);
		if(inf > 0) then
			value = 2^31 - 1;
		end
		self[k] = (sign > 0 and -value or value);
		return self[k];
	end,
});

--- Callback for CheckUnits in the trigger.
local function CheckValue(unit, op, match, resource, abs)
	-- Convert the resource type.
	local realRes = PowerAuras.UnitPowerTypes[resource];

	-- Get the minimum bound.
	local min = PowerTypeMinimums[resource];

	-- Burning embers are terrible.
	local badDesign = (resource == "BurningEmbers");

	-- Get current/max values.
	local cur = GetPower(unit, realRes, badDesign);
	local max = GetMaxPower(unit, realRes, badDesign);
	cur = (cur or 0);
	max = (max or 0);
	-- Check the value.
	if(abs) then
		return PowerAuras:CheckOperator(cur, op, match), cur, min, max;
	else
		local checkVal, checkMax = (cur - min), (max - min);
		local perc = (checkVal / (checkMax == 0 and 1 or checkMax)) * 100;
		return PowerAuras:CheckOperator(perc, op, match), cur, min, max;
	end
end

--- Constructs a new instance of the trigger and returns it.
-- @param parameters The parameters to construct the trigger from.
function UnitPower:New(parameters)
	-- Get parameters.
	local operator, value = parameters["Operator"], parameters["Value"];
	local resource = parameters["Resource"];
	local isAbs = parameters["IsAbsolute"];
	local units = PowerAuras:DecodeUnits(parameters["Unit"]);

	-- Generate the trigger.
	return function(self, buffer, action, store)
		-- Check units.
		local state, match, value, min, max = PowerAuras:CheckUnits(
			units, CheckValue, operator, value, resource, isAbs
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
			store.Text["name"]  = ""
			store.Text["value"] = "";
			store.Text["min"]   = "";
			store.Text["max"]   = "";
			store.Text["perc"]  = "";
		end

		-- Done.
		return state;
	end
end

--- Creates the controls for the basic activation editor frame.
-- @param frame The frame to apply controls to.
-- @param ... ID's to use for Get/SetParameter calls.
function UnitPower:CreateTriggerEditor(frame, ...)
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
	end, ...);
	frame:AddWidget(isAbs);

	-- Value selection.
	if(PowerAuras:GetParameter("Trigger", "IsAbsolute", ...)) then
		-- Use a numberbox for bounded input.
		local value = PowerAuras:Create("P_NumberBox", frame);
		value:SetUserTooltip("UnitStats_Value");
		value:SetRelativeWidth(0.35);
		value:SetPadding(4, 0, 2, 0);
		value:SetTitle(L["Value"]);
		value:SetValueStep(1);

		-- Get min/max values.
		local resource = PowerAuras:GetParameter("Trigger", "Resource", ...);
		local data = PowerAuras.UnitPowerTypeBounds[resource];
		local min, max = bit.rshift(data, 16), bit.band(data, 0xFFFF);

		-- Get caps.
		local minInf, minSign = bit.band(min, 0x8000), bit.band(min, 0x4000);
		min = (minInf > 0 and (2^31 - 1) or bit.band(min, 0x3FFF));
		local maxInf, maxSign = bit.band(max, 0x8000), bit.band(max, 0x4000);
		max = (maxInf > 0 and (2^31 - 1) or bit.band(max, 0x3FFF));

		-- Now set the values.
		value:SetMinMaxValues(
			(minSign > 0 and -min or min),
			(maxSign > 0 and -max or max)
		);

		-- Link to parameter.
		value:LinkParameter("Trigger", "Value", 0, ...);
		frame:AddWidget(value);
	else
		-- 0-100% dropdown.
		local value = PowerAuras:Create("P_Slider", frame);
		value:SetUserTooltip("UnitStats_Value");
		value:SetRelativeWidth(0.35);
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
	op:SetRelativeWidth(0.25);
	op:SetPadding(2, 0, 2, 0);
	op:LinkParameter("Trigger", "Operator", ...);
	frame:AddWidget(op);

	-- Power type dropdown.
	local res = PowerAuras:Create("P_Dropdown", frame);
	res:SetUserTooltip("UnitPower_Resource");
	res:SetRelativeWidth(0.4);
	res:SetPadding(2, 0, 4, 0);
	res:SetTitle(L["Type"]);
	for key, id in PowerAuras:ByKey(PowerAuras.UnitPowerTypes) do
		res:AddCheckItem(key, L["UnitPower"][key]);
	end
	res:LinkParameter("Trigger", "Resource", ...);
	res:ConnectParameter("Trigger", "Resource", function()
		PowerAuras.Editor:Refresh()
	end, ...);
	frame:AddWidget(res);
end

--- Returns the trigger type name.
-- @param params The parameters of the trigger.
function UnitPower:GetTriggerType(params)
	return ("%sPower"):format(params["Unit"]:gsub("^%a", string.upper, 1));
end

--- Initialises the per-trigger data store. This can be used to hold
--  values which can then be exposed to other parts of the system.
-- @param params The parameters of this trigger.
-- @return An item to store, or nil.
function UnitPower:InitialiseDataStore(params)
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
function UnitPower:Upgrade(version, params)
	
end