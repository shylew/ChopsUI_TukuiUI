-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--- Trigger class definition.
local Timer = PowerAuras:RegisterTriggerClass("Timer", {
	--- Dictionary of default parameters this trigger uses.
	Parameters = {
		Mode     = 1, -- 1 = Remaining, 2 = Active, 3 = Duration.
		Operator = "<=",
		Match    = 15,
	},
	--- Dictionary of events this trigger responds to.
	Events = {
	},
	--- Dictionary of provider services required by this trigger type.
	Services = {
		Timer = true,
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
function Timer:New(parameters, actionID, provider)
	-- Parameters.
	local mode  = parameters["Mode"];
	local op    = parameters["Operator"];
	local match = parameters["Match"];

	-- Upvalues.
	local GetTime = GetTime;

	-- State locals.
	local timeStart, timeEnd, checkState = 0, 2^31 - 1, false;

	-- Generate the function.
	return function(self, buffer, action, store)
		-- Provider been updated?
		if(buffer.Providers[provider]) then
			-- Update the stored value.
			timeStart, timeEnd = provider.Timer();

			-- Need to toggle our update state?
			if(not checkState and (timeStart > 0 or timeEnd < 2^31 - 1)) then
				checkState = true;
				PowerAuras:SetTriggerTimed(action, self, true);
			elseif(checkState and timeStart == 0 and timeEnd == 2^31 - 1) then
				checkState = false;
				PowerAuras:SetTriggerTimed(action, self, false);
			end
		end

		-- Determine what we're comparing.
		local time = GetTime();
		local comp = (timeEnd - GetTime());
		if(mode == 2) then
			comp = (GetTime() - timeStart);
		elseif(mode == 3) then
			comp = (timeEnd - timeStart);
		end

		-- Go compare!
		return PowerAuras:CheckOperator(comp, op, match);
	end
end

--- Creates the controls for the basic activation editor frame.
-- @param frame The frame to apply controls to.
-- @param ... ID's to use for Get/SetParameter calls.
function Timer:CreateTriggerEditor(frame, ...)
	-- Comparison mode.
	local mode = PowerAuras:Create("P_Dropdown", frame);
	mode:SetRelativeWidth(1 / 3);
	mode:SetPadding(4, 0, 2, 0);
	mode:SetTitle(L["MatchType"]);
	mode:AddCheckItem(1, L["TimeRemaining"]);
	mode:AddCheckItem(2, L["TimeActive"]);
	mode:AddCheckItem(3, L["TimeDuration"]);
	mode:LinkParameter("Trigger", "Mode", ...);
	frame:AddWidget(mode);

	-- Operator.
	local operator = PowerAuras:Create("P_OperatorDropdown", frame);
	operator:LinkParameter("Trigger", "Operator", ...);
	operator:SetRelativeWidth(1 / 3);
	operator:SetPadding(2, 0, 2, 0);
	frame:AddWidget(operator);

	-- Match.
	local match = PowerAuras:Create("P_NumberBox", frame);
	match:SetRelativeWidth(1 / 3);
	match:SetPadding(2, 0, 4, 0);
	match:SetTitle(L["Match"]);
	match:SetMinMaxValues(0, 3600);
	match:SetValueStep(0.5);
	match:LinkParameter("Trigger", "Match", 0, ...);
	frame:AddWidget(match);
end

--- Returns true if the trigger is considered a 'support' trigger and can
--  be shown as an additional trigger option within the simple activation
--  editor.
function Timer:IsSupportTrigger()
	return true;
end

--- Determines whether or not a trigger requires per-frame updates.
-- @param params The parameters of the trigger.
-- @return True if updates are required, false if not.
-- @return The first value is the default timed state on creation. The 
--         second boolean is whether or not the timed status is capable of
--         being toggled by the trigger.
function Timer:IsTimed(params)
	return false, true;
end

--- Upgrades the trigger from the specified version to the current version.
-- @param version The version to upgrade from.
-- @param params  The trigger parameters to upgrade.
function Timer:Upgrade(version, params)
	
end