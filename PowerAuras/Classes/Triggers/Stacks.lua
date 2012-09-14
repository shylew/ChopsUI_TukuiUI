-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--- Trigger class definition.
local Stacks = PowerAuras:RegisterTriggerClass("Stacks", {
	--- Dictionary of default parameters this trigger uses.
	Parameters = {
		Operator = "<=",
		Match    = 3,
	},
	--- Dictionary of events this trigger responds to.
	Events = {
	},
	--- Dictionary of provider services required by this trigger type.
	Services = {
		Stacks = true,
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
function Stacks:New(parameters, actionID, provider)
	-- Parameters.
	local op    = parameters["Operator"];
	local match = parameters["Match"];

	-- State locals.
	local count = 0;

	-- Generate the function.
	return function(self, buffer, action, store)
		-- Provider been updated?
		if(buffer.Providers[provider]) then
			-- Update the stored value.
			count = provider.Stacks();
		end

		-- Go compare!
		return PowerAuras:CheckOperator(count, op, match);
	end
end

--- Creates the controls for the basic activation editor frame.
-- @param frame The frame to apply controls to.
-- @param ... ID's to use for Get/SetParameter calls.
function Stacks:CreateTriggerEditor(frame, ...)
	-- Operator.
	local operator = PowerAuras:Create("P_OperatorDropdown", frame);
	operator:LinkParameter("Trigger", "Operator", ...);
	operator:SetRelativeWidth(1 / 3);
	operator:SetPadding(4, 0, 2, 0);
	frame:AddWidget(operator);

	-- Match.
	local match = PowerAuras:Create("P_NumberBox", frame);
	match:SetRelativeWidth(2 / 3);
	match:SetPadding(2, 0, 4, 0);
	match:SetTitle(L["Match"]);
	match:SetMinMaxValues(0, 2^16 - 1);
	match:SetValueStep(1);
	match:LinkParameter("Trigger", "Match", 0, ...);
	frame:AddWidget(match);
end

--- Returns true if the trigger is considered a 'support' trigger and can
--  be shown as an additional trigger option within the simple activation
--  editor.
function Stacks:IsSupportTrigger()
	return true;
end

--- Upgrades the trigger from the specified version to the current version.
-- @param version The version to upgrade from.
-- @param params  The trigger parameters to upgrade.
function Stacks:Upgrade(version, params)
	
end