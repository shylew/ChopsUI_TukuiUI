-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

local LastKilled = {};
local KilledBy = {};

--- Trigger class definition.
local KillingBlow = PowerAuras:RegisterTriggerClass("KillingBlow", {
	--- Dictionary of default parameters this trigger uses.
	Parameters = {
		Unit = "Player",
		Duration = 5,
	},
	--- Dictionary of events this trigger responds to.
	Events = {
		COMBAT_LOG_EVENT_UNFILTERED = function(buffer, ...)
			local _, combatEvent, _, sGUID, _, _, _, dGUID, _, dFlag = ...;
			if (combatEvent == "PARTY_KILL") then
				-- PowerAuras:PrintInfo("PARTY_KILL source="..tostring(sGUID).." dest="..tostring(dGUID));
				--if (GetPlayerInfoByGUID(dGUID)) then
					--if (CombatLog_Object_IsA(dFlag, COMBATLOG_FILTER_HOSTILE_PLAYERS)) then
						KilledBy[sGUID] = KilledBy[sGUID] or {};
						table.insert(KilledBy[sGUID], dGUID);
						LastKilled[dGUID] = GetTime();
						PowerAuras:PrintInfo("KillingBlow");
						buffer.Triggers["KillingBlow"] = true;
					--end
				--end
			end
		end,
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
function KillingBlow:New(parameters)
	local guid, duration = UnitGUID(parameters["Unit"]), parameters["Duration"];
	return function()
		local killed = KilledBy[guid];
		if (not killed or #killed==0) then return false; end
		local deadGuid = killed[1];
		--PowerAuras:PrintInfo("KillingBlow guid="..tostring(guid).." deadGuid="..tostring(deadGuid));
		local death = LastKilled[deadGuid];
		--PowerAuras:PrintInfo("death="..tostring(death));
		if (not death or GetTime() > death + duration) then
			table.remove(killed,1);
			return false;
		end
		return true;
	end;
end

--- Creates the controls for the basic activation editor frame.
-- @param frame The frame to apply controls to.
-- @param ... ID's to use for Get/SetParameter calls.
function KillingBlow:CreateTriggerEditor(frame, ...)
	-- Construct widgets.
	local unit = PowerAuras:Create("DropdownButton", frame);
	unit:SetRelativeWidth(0.4);
	unit:SetTitle("[UL] Unit");
	unit:SetText(PowerAuras:GetParameter("Trigger", "Unit", ...));
	unit:ConnectParameter("Trigger", "Unit", PowerAuras:Loadstring([[
		local self, value = ...;
		self:CloseMenu();
		self:SetText(tostring(value));
	]]), ...);
	unit.OnMenuRefreshed:Connect(PowerAuras:Loadstring(
		PowerAuras:FormatString([==[
		-- Clear the menu.
		local self, menu = ...;
		menu:ClearItems();
		menu:SetLayoutType("Auto");
		-- Populate it with all unit ID's.
		menu:AddLabel("__SINGLE__", "[UL] Units");
		for i = 1, #(PowerAuras.SingleUnitIDs) do
			-- TODO: Localise.
			local id = PowerAuras.SingleUnitIDs[i];
			menu:AddItem(id, "", "[UL] " .. id);
		end
		menu:AddLabel("__GROUP__", "[UL] Group Units");
		-- Run over the group types and do the same.
		for group, ids in pairs(PowerAuras.GroupUnitIDs) do
			menu:AddMenu(group, PowerAuras:Loadstring([=[
				-- Run over the group units of the parent key.
				local menu = ...;
				menu:ClearItems();
				menu:SetLayoutType("Scroll");
				menu:SetFixedHeight(8);
				for i = 1, #(PowerAuras.GroupUnitIDs[menu:GetParentKey()]) do
					local id = PowerAuras.GroupUnitIDs[menu:GetParentKey()][i];
					menu:AddItem(id, "", "[UL] " .. id);
				end
				-- Apply callback.
				menu.OnValueUpdated:Reset();
				menu.OnValueUpdated:Connect(PowerAuras:Loadstring([[
					local menu, key = ...;
					PowerAuras:SetParameter("Trigger", "Unit", key,
						${...});
				]]));
			]=]), "[UL] " .. group);
		end
		-- Apply callback.
		menu.OnValueUpdated:Reset();
		menu.OnValueUpdated:Connect(PowerAuras:Loadstring([[
			local menu, key = ...;
			PowerAuras:SetParameter("Trigger", "Unit", key, ${...});
		]]));
	]==], ...)));

	local duration = PowerAuras:Create("Slider", frame);
	duration:SetRelativeWidth(0.4);
	duration:SetTitle("[UL] Active Duration");
	duration:SetMinMaxValues(0.25, 10);
	duration:SetValueStep(0.05);
	duration:SetValue(
		tonumber(PowerAuras:GetParameter("Trigger", "Duration", ...)) or 0
	);
	duration:ConnectParameter("Trigger", "Duration", duration.SetValue, ...);
	duration.OnValueUpdated:Connect(PowerAuras:FormatString([[
		local self, value = ...;
		PowerAuras:SetParameter("Trigger", "Duration", tonumber(value) or 0, 
			${...});
	]], ...));

	-- Add widgets to frame.
	frame:AddRelativeSpacer(0.05);
	frame:AddWidget(unit);
	frame:AddRelativeSpacer(0.1);
	frame:AddWidget(duration);
	frame:AddRelativeSpacer(0.05);
end

--- Determines whether or not a trigger requires per-frame updates.
-- @param params The parameters of the trigger.
-- @return True if updates are required, false if not.
-- @return The first value is the default timed state on creation. The 
--         second boolean is whether or not the timed status is capable of
--         being toggled by the trigger.
function KillingBlow:IsTimed(params)
	return true, false;
end

--- Upgrades the trigger from the specified version to the current version.
-- @param version The version to upgrade from.
-- @param params  The trigger parameters to upgrade.
function KillingBlow:Upgrade(version, params)
	
end