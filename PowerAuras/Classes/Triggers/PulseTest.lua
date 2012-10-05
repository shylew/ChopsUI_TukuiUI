-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--- Trigger class definition.
local PulseTest = PowerAuras:RegisterTriggerClass("PulseTest", {
	--- Dictionary of default parameters this trigger uses.
	Parameters = {
		ActiveDuration = 5,
		InactiveDuration = 5,
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
function PulseTest:New(parameters)
	-- Upvalues.
	local activeDuration = parameters["ActiveDuration"];
	local inactiveDuration = parameters["InactiveDuration"];
	-- Store end of pulse, as well as current state.
	local GetTime = GetTime;
	local state, endOfState = false, GetTime();
	-- Generate trigger, return data and function.
	return function()
		local time = GetTime();
		if(time >= endOfState) then
			-- Flip state, update pulse end.
			state = not state;
			if(state) then
				endOfState = time + activeDuration;
			else
				endOfState = time + inactiveDuration;
			end
		end
		return state;
	end;
end

--- Creates the controls for the basic activation editor frame.
-- @param frame The frame to apply controls to.
-- @param ... ID's to use for Get/SetParameter calls.
function PulseTest:CreateTriggerEditor(frame, ...)
	-- Construct widgets.
	local duration = PowerAuras:Create("Slider", frame);
	duration:SetRelativeWidth(0.45);
	duration:SetTitle("Active Duration");
	duration:SetMinMaxValues(0, 60);
	duration:SetValueStep(0.05);
	duration:SetValue(
		PowerAuras:GetParameter("Trigger", "ActiveDuration", ...)
	);
	duration:ConnectParameter("Trigger", "ActiveDuration", duration.SetValue,
		...);
	duration.OnValueUpdated:Connect(PowerAuras:FormatString([[
		local self, value = ...;
		PowerAuras:SetParameter("Trigger", "ActiveDuration",
			tonumber(value) or 0, ${...});
	]], ...));

	local inactive = PowerAuras:Create("Slider", frame);
	inactive:SetRelativeWidth(0.45);
	inactive:SetTitle("Inactive Duration");
	inactive:SetMinMaxValues(0, 60);
	inactive:SetValueStep(0.05);
	inactive:SetValue(
		PowerAuras:GetParameter("Trigger", "InactiveDuration", ...)
	);
	inactive:ConnectParameter("Trigger", "InactiveDuration", inactive.SetValue,
		...);
	inactive.OnValueUpdated:Connect(PowerAuras:FormatString([[
		local self, value = ...;
		PowerAuras:SetParameter("Trigger", "InactiveDuration",
			tonumber(value) or 0, ${...});
	]], ...));

	-- Add widgets to frame.
	frame:AddWidget(duration);
	frame:AddWidget(inactive);
end

--- Determines whether or not a trigger requires per-frame updates.
-- @param params The parameters of the trigger.
-- @return True if updates are required, false if not.
-- @return The first value is the default timed state on creation. The 
--         second boolean is whether or not the timed status is capable of
--         being toggled by the trigger.
function PulseTest:IsTimed(params)
	return true, false;
end

--- Upgrades the trigger from the specified version to the current version.
-- @param version The version to upgrade from.
-- @param params  The trigger parameters to upgrade.
function PulseTest:Upgrade(version, params)
	
end