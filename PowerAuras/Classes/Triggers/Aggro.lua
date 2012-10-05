-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--- Trigger class for threat/aggro information.
local Aggro = PowerAuras:RegisterTriggerClass("Aggro", {
	Parameters = {
		Unit = "player",
		UnitDetailed = "target",
		Type  = 1,   -- 1 = Simple (player vs. any unit), 2 = Detailed.
		Ret   = 2,   -- Return value index for detailed.
		Match = 0xC, -- Defaults to activating if status == (2 | 3).
		Operator = ">", -- Only valid if type > 1.
	},
	Events = {
		UNIT_THREAT_LIST_UPDATE = "AggroDetailed",
		UNIT_THREAT_SITUATION_UPDATE = { "AggroDetailed", "AggroSimple" },
		ARENA_OPPONENT_UPDATE = "AggroDetailed",
		GROUP_ROSTER_UPDATE = "AggroDetailed",
		INSTANCE_ENCOUNTER_ENGAGE_UNIT = "AggroDetailed",
		PLAYER_FOCUS_CHANGED = "AggroDetailed",
		PLAYER_TARGET_CHANGED = "AggroDetailed",
		UNIT_ENTERED_VEHICLE = "AggroDetailed",
		UNIT_EXITED_VEHICLE = "AggroDetailed",
		UNIT_PET = "AggroDetailed",
	},
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
-- @param parameters The parameters to construct the trigger from.
function Aggro:New(parameters)
	-- Determine the type of this trigger.
	local name = self:GetTriggerType(parameters);
	-- Generate function based upon the type.
	if(parameters["Type"] == 1) then
		-- Checking threat status.
		return ([[bit.band(%d, 2^(UnitThreatSituation(%q) or -1)) > 0]])
			:format(parameters["Match"], parameters["Unit"]);
	else
		-- Checking a detailed threat value.
		-- Is it just a status check?
		if(parameters["Ret"] == 2) then
			-- Check the status of certain units.
			return ([[bit.band(%d, select(2, %s(%q, %q)) or 0) > 0]]):format(
				parameters["Match"],
				"UnitDetailedThreatSituation",
				parameters["Unit"],
				parameters["UnitDetailed"]
			);
		else
			-- Just hack ze returns.
			return ([[(select(%d, %s(%q, %q)) or 0) %s %g]]):format(
				parameters["Ret"],
				"UnitDetailedThreatSituation",
				parameters["Unit"],
				parameters["UnitDetailed"],
				parameters["Operator"],
				parameters["Match"]
			);
		end
	end
end

--- Creates the controls for the basic activation editor frame.
-- @param frame The frame to apply controls to.
-- @param ... ID's to use for Get/SetParameter calls.
function Aggro:CreateTriggerEditor(frame, ...)
	-- Add a dropdown for picking the mode.
	local match = PowerAuras:Create("P_Dropdown", frame);
	match:SetUserTooltip("Aggro_MatchType");
	match:AddCheckItem(1, L["Basic"]);
	match:SetItemTooltip(1, L["AggroBasicTooltip"]);
	match:AddCheckItem(2, L["Detailed"]);
	match:SetItemTooltip(2, L["AggroDetailTooltip"]);
	match:LinkParameter("Trigger", "Type", ...);
	match:SetTitle(L["MatchType"]);
	match:SetPadding(4, 0, 2, 0);
	match:SetRelativeWidth(0.5);
	match.OnValueUpdated:Connect(PowerAuras:FormatString([[
		-- Reset the match.
		PowerAuras:SetParameter("Trigger", "Match", 0, ${...});
		-- Refresh the host.
		local displays = PowerAuras.Editor.Displays;
		displays:RefreshHost(displays:GetCurrentNode());
	]], ...));
	frame:AddWidget(match);

	-- Remaining widgets vary based upon the type.
	local ptype = PowerAuras:GetParameter("Trigger", "Type", ...);
	local ret = PowerAuras:GetParameter("Trigger", "Ret", ...);
	-- Types > 1 allow unit selection/return value selection.
	if(ptype > 1) then
		-- Return value selection.
		local retOpt = PowerAuras:Create("P_Dropdown", frame);
		retOpt:SetUserTooltip("Aggro_ThreatSit");
		retOpt:AddCheckItem(2, L["AggroStatus"]);
		retOpt:SetItemTooltip(2, L["AggroStatusTooltip"]);
		retOpt:AddCheckItem(3, L["AggroScaled"]);
		retOpt:SetItemTooltip(3, L["AggroScaledTooltip"]);
		retOpt:AddCheckItem(4, L["AggroRaw"]);
		retOpt:SetItemTooltip(4, L["AggroRawTooltip"]);
		retOpt:AddCheckItem(5, L["AggroValue"]);
		retOpt:SetItemTooltip(5, L["AggroValueTooltip"]);
		retOpt:LinkParameter("Trigger", "Ret", ...);
		retOpt:SetTitle(L["AggroRet"]);
		retOpt:SetPadding(2, 0, 4, 0);
		retOpt:SetRelativeWidth(0.5);
		retOpt.OnValueUpdated:Connect(PowerAuras:FormatString([[
			-- Reset the match.
			PowerAuras:SetParameter("Trigger", "Match", 0, ${...});
			-- Refresh the host.
			local displays = PowerAuras.Editor.Displays;
			displays:RefreshHost(displays:GetCurrentNode());
		]], ...));

		-- Unit selection.
		local unit = PowerAuras:Create("P_UnitDropdown", frame, 3,
			"Single", "raid-units", "party-units");
		unit:SetUserTooltip("Unit");
		unit:SetTitle(L["AggroUnit1"]);
		unit:LinkParameter("Trigger", "Unit", ...);
		unit:SetRelativeWidth(0.3);
		unit:SetPadding(4, 0, 2, 0);

		local unit2 = PowerAuras:Create("P_UnitDropdown", frame, 3,
			"target", "focus", "boss-units");
		unit2:SetUserTooltip("Aggro_Enemy");
		unit2:SetTitle(L["AggroUnit2"]);
		unit2:LinkParameter("Trigger", "UnitDetailed", ...);
		unit2:SetRelativeWidth(0.3);
		unit2:SetPadding(2, 0, 4, 0);

		-- Add widgets.
		frame:AddWidget(retOpt);
		frame:AddRow(4);
		frame:AddWidget(unit);
		frame:AddWidget(unit2);

		-- Add in more controls based upon status return.
		if(ret == 3 or ret == 4) then
			-- Percentage selectorydoo.
			local value = PowerAuras:Create("P_Slider", frame);
			value:SetUserTooltip("Aggro_ThreatLevel");
			value:SetMinMaxValues(0, (ret == 3 and 100 or 130));
			value:SetValueStep(1);
			value:LinkParameter("Trigger", "Match", ...);
			value:SetRelativeWidth(0.4);
			value:SetPadding(2, 0, 4, 0);
			value:SetMinMaxLabels("%d%%", "%d%%");
			value:SetTitle(L["AggroRaw"]);
			frame:AddWidget(value);
		elseif(ret == 5) then
			-- Value pickerydoo.
			local value = PowerAuras:Create("P_NumberBox");
			value:SetUserTooltip("Aggro_ThreatLevel");
			value:SetRelativeWidth(0.4);
			value:SetPadding(2, 0, 4, 0);
			value:SetMinMaxValues(0, 2^31 - 1);
			value:LinkParameter("Trigger", "Match", 0, ...);
			value:SetTitle(L["AggroValue"]);
			frame:AddWidget(value);
			frame:AddRow(4);
		end

		if(ret > 2) then
			-- Operator dropdown.
			local operator = PowerAuras:Create("P_OperatorDropdown", frame);
			operator:SetUserTooltip("Operator");
			operator:LinkParameter("Trigger", "Operator", ...);
			operator:SetRelativeWidth(0.3);
			operator:SetPadding(4, 0, 2, 0);
			if(ret == 3 or ret == 4) then
				operator:SetMargins(0, 16, 0, 0);
			end
			frame:AddWidget(operator);
		end
	end

	-- Types 1 and Type 2 Ret 2 are status handlers.
	if(ptype == 1 or ret == 2) then
		-- Situation selection dropdown.
		local sit = PowerAuras:Create("SimpleDropdown", frame);
		sit:SetUserTooltip("Aggro_ThreatSit");
		sit:SetTitle(L["Situation"]);
		sit:SetPadding((ptype == 1 and 4 or 2), 0, 4, 0);
		sit:SetRelativeWidth(ptype == 1 and 0.5 or 0.4);

		-- Add the options.
		local value = PowerAuras:GetParameter("Trigger", "Match", ...);
		sit:AddCheckItem(0, L["AggroStatus0"], bit.band(value, 1) > 0, true);
		sit:AddCheckItem(1, L["AggroStatus1"], bit.band(value, 2) > 0, true);
		sit:AddCheckItem(2, L["AggroStatus2"], bit.band(value, 4) > 0, true);
		sit:AddCheckItem(3, L["AggroStatus3"], bit.band(value, 8) > 0, true);
		for i = 0, 3 do
			sit:SetItemTooltip(i, L[("AggroStatus%dTooltip"):format(i)]);
		end

		-- The text displayed on the dropdown varies based on how many bits
		-- are set. Easy way is to just see if it's a power of two.
		if(value == 0) then
			-- Handle 0's as a "None" option. Don't pass 0 to math.log!
			sit:SetRawText(NONE);
		elseif(bit.band(value, value - 1) == 0) then
			-- Reverse the number back to a usable key.
			sit:SetText(math.log(value) / math.log(2));
		else
			sit:SetRawText(L["Multiple"]);
		end

		-- Connect callbacks.
		sit:ConnectParameter("Trigger", "Match", PowerAuras:Loadstring([[
			local self, value = ...;
			for i = 0, 3 do
				self:SetItemChecked(i, bit.band(value, 2^i) > 0);
			end
			if(value == 0) then
				self:SetRawText(NONE);
			elseif(bit.band(value, value - 1) == 0) then
				self:SetText(math.log(value) / math.log(2));
			else
				self:SetRawText(PowerAuras.L["Multiple"]);
			end
		]]), ...);
		sit.OnValueUpdated:Connect(PowerAuras:FormatString([[
			local self, value = ...;
			-- Update stored value.
			local cur = PowerAuras:GetParameter("Trigger", "Match", ${...});
			PowerAuras:SetParameter("Trigger", "Match", bit.bxor(cur, 2^value),
				${...});
		]], ...));
		frame:AddWidget(sit);
	end
end

--- Returns the trigger type name.
-- @param params The parameters of the trigger.
function Aggro:GetTriggerType(params)
	return (params["Type"] == 1 and "AggroSimple" or "AggroDetailed");
end

--- Upgrades the trigger from the specified version to the current version.
-- @param version The version to upgrade from.
-- @param params  The trigger parameters to upgrade.
function Aggro:Upgrade(version, params)
	
end