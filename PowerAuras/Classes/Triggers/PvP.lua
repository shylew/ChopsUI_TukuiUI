-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--- Trigger class definition.
local PvP = PowerAuras:RegisterTriggerClass("PvP", {
	--- Dictionary of default parameters this trigger uses.
	Parameters = {
	},
	--- Dictionary of events this trigger responds to.
	Events = {
		UNIT_FACTION = function(buffer, unit)
			if(unit == "player") then
				buffer.Triggers["PvP"] = true;
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
function PvP:New(parameters)
	-- Return the function.
	return function(self, buffer, action, store)
		-- PvP flagged?
		local state = UnitIsPVP("player");
		if(not state) then
			-- Turn off timed updates and reset our store.
			PowerAuras:SetTriggerTimed(action, self, false);
			store.TimerStart, store.TimerEnd, store.End = nil, nil, nil;
			return false;
		end

		-- Can we update the timer?
		if(IsPVPTimerRunning() and not store.End) then
			-- Update the timer data.
			store.TimerStart = GetTime();
			store.TimerEnd = (GetTime() + (GetPVPTimer() / 1000));
			store.End = GetPVPTimer();
			-- Update providers, turn on timed updates.
			PowerAuras:SetTriggerTimed(action, self, true);
		elseif(not IsPVPTimerRunning()) then
			-- Reset timer.
			store.TimerStart, store.TimerEnd, store.End = nil, nil, nil;
		end

		-- Return our state.
		return state;
	end;
end

--- Creates the controls for the basic activation editor frame.
-- @param frame The frame to apply controls to.
-- @param ... ID's to use for Get/SetParameter calls.
function PvP:CreateTriggerEditor(frame, ...)
	-- No config message.
	local l = PowerAuras:Create("Label", frame);
	l:SetText(L["TriggerNoConf"]);
	l:SetRelativeWidth(1.0);
	l:SetHeight(36);
	l:SetJustifyH("CENTER");
	l:SetJustifyV("MIDDLE");
	frame:AddWidget(l);
end

--- Initialises the per-trigger data store. This can be used to hold
--  values which can then be exposed to other parts of the system.
-- @param params The parameters of this trigger.
-- @return An item to store, or nil.
function PvP:InitialiseDataStore()
	return {
		TimerStart = 0,
		TimerEnd = 2^31 - 1,
		InternalEnd = nil;
	};
end

--- Determines whether or not a trigger requires per-frame updates.
-- @param params The parameters of the trigger.
-- @return True if updates are required, false if not.
-- @return The first value is the default timed state on creation. The 
--         second boolean is whether or not the timed status is capable of
--         being toggled by the trigger.
function PvP:IsTimed(params)
	return false, true;
end

--- Upgrades the trigger from the specified version to the current version.
-- @param version The version to upgrade from.
-- @param params  The trigger parameters to upgrade.
function PvP:Upgrade(version, params)
end