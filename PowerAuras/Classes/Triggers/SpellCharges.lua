-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--- Spell charges trigger. Activates based upon the number of uses a spell
--  has available.
local SpellCharges = PowerAuras:RegisterTriggerClass("SpellCharges", {
	--- Dictionary of default parameters this trigger uses.
	Parameters = {
		Match = "<Spell Name/ID>",
		Charges = 1,
		Operator = "<=",
		StacksInvert = false, -- If true, will show (max-current) charges.
		TimePerCharge = true, -- If false, the timer data will report the time
		                      -- until all charges are restored.
        CustomMax = 0,        -- Custom maximum. Requires either StacksInvert
                              -- to be true, or TimePerCharge to be false.
	},
	--- Dictionary of events this trigger responds to.
	Events = {
		SPELL_UPDATE_CHARGES = "SpellCharges",
	},
	--- Dictionary of provider services required by this trigger type.
	Services = {
	},
	--- Dictionary of services that this trigger can conver to.
	ServiceMirrors = {
		Timer   = "TriggerData",
		Stacks  = "TriggerData",
		Texture = "TriggerData",
		Text    = "TriggerData",
	},
});

--- Constructs a new instance of the trigger and returns it.
-- @param parameters The parameters to construct the trigger from.
function SpellCharges:New(parameters)
	-- Prepare parameters.
	local match = type(parameters["Match"]) == "string"
		and ("%q"):format(parameters["Match"])
		or tonumber(parameters["Match"]);
	-- Comparison operator.
	local operator = parameters["Operator"];
	-- Charges to match.
	local charges = parameters["Charges"];
	-- Stacks inversion.
	local invert = parameters["StacksInvert"];
	-- Time display method.
	local timePerCharge = parameters["TimePerCharge"];
	-- Custom maximum.
	local customMax = ((charges or not timePerCharge)
		and parameters["CustomMax"]
		or 0);

	-- Build function.
	return PowerAuras:Loadstring(PowerAuras:FormatString([[
		-- Get the charges.
		local self, buffer, action, store = ...;
		local current, max, start, cd = GetSpellCharges(${1:s});

		-- If the spell was invalid, fail.
		if(not current) then
			return false;
		end

		-- Override the maximum.
		if(${6:d} > 0) then
			max = math.max(current, ${6:d});
		end

		-- Test.
		if(current ${2:s} ${3:d}) then
			-- Active. Update store.
			store.TimerStart = start;
			store.TimerEnd = (start + (${5:s} and cd * (max - current) or cd));
			store.Stacks = (${4:s} and (max - current) or current);
			store.Texture = select(3, GetSpellInfo(${1:s}));
			return true;
		else
			-- Failed.
			store.TimerStart = nil;
			store.TimerEnd   = nil;
			store.Stacks     = nil;
			store.Texture    = nil;
			return false;
		end
	]], match, operator, charges, invert, timePerCharge, customMax));
end

--- Initialises the per-trigger data store. This can be used to hold
--  values which can then be exposed to other parts of the system.
-- @param params The parameters of this trigger.
-- @return An item to store, or nil.
function SpellCharges:InitialiseDataStore()
	return {
		TimerStart = 0,
		TimerEnd = 2^31 - 1,
		Stacks = 0,
		Texture = PowerAuras.DefaultIcon,
	};
end

--- Creates the controls for the basic activation editor frame.
-- @param frame The frame to apply controls to.
-- @param ... ID's to use for Get/SetParameter calls.
function SpellCharges:CreateTriggerEditor(frame, ...)
	-- Spell match.
	local match = PowerAuras:Create("P_EditBox", frame);
	match:SetUserTooltip("SpellCharges_Match");
	match:LinkParameter("Trigger", "Match", ...);
	match:SetPadding(4, 0, 2, 0);
	match:SetRelativeWidth(0.5);
	match:SetTitle(L["SpellCharges_Match"]);
	frame:AddWidget(match);

	-- Operator.
	local operator = PowerAuras:Create("P_OperatorDropdown", frame);
	operator:SetUserTooltip("Operator");
	operator:LinkParameter("Trigger", "Operator", ...);
	operator:SetRelativeWidth(0.25);
	operator:SetPadding(2, 0, 2, 0);
	frame:AddWidget(operator);

	-- Charges match.
	local charges = PowerAuras:Create("P_NumberBox");
	charges:SetUserTooltip("SpellCharges_Charges");
	charges:SetRelativeWidth(0.25);
	charges:SetPadding(2, 0, 4, 0);
	charges:SetMinMaxValues(0, 2^31 - 1);
	charges:LinkParameter("Trigger", "Charges", 0, ...);
	charges:SetTitle(L["Charges"]);
	frame:AddWidget(charges);
	frame:AddRow(4);

	-- Stacks inversion.
	local stacksInvert = PowerAuras:Create("P_Checkbox", frame);
	stacksInvert:SetUserTooltip("SpellCharges_StacksInvert");
	stacksInvert:LinkParameter("Trigger", "StacksInvert", ...);
	stacksInvert:ConnectParameter("Trigger", "StacksInvert", function()
		PowerAuras.Editor:Refresh();
	end);
	stacksInvert:SetMargins(0, 20, 0, 0);
	stacksInvert:SetPadding(4, 0, 2, 0);
	stacksInvert:SetRelativeWidth(0.65);
	stacksInvert:SetText(
		L("TColon2", L["ServiceInterfaces"]["Stacks"], L["Invert"])
	);
	frame:AddWidget(stacksInvert);

	-- Custom maximum (only show some of the time).
	local showMax = PowerAuras:GetParameter("Trigger", "StacksInvert", ...)
		or PowerAuras:GetParameter("Trigger", "TimePerCharge", ...);

	if(showMax) then
		local max = PowerAuras:Create("P_NumberBox");
		max:SetUserTooltip("SpellCharges_CustomMax");
		max:SetRelativeWidth(0.35);
		max:SetPadding(2, 0, 4, 0);
		max:SetMinMaxValues(0, 2^31 - 1);
		max:LinkParameter("Trigger", "CustomMax", 0, ...);
		max:SetTitle(L["CustomMax"]);
		frame:AddWidget(max);
	end

	-- Timer options.
	local timePerCharge = PowerAuras:Create("P_Checkbox", frame);
	timePerCharge:LinkParameter("Trigger", "TimePerCharge", ...);
	timePerCharge:ConnectParameter("Trigger", "TimePerCharge", function()
		PowerAuras.Editor:Refresh();
	end);
	timePerCharge:SetUserTooltip("SpellCharges_TimeOverall");
	timePerCharge:SetPadding(4, 0, 2, 0);
	timePerCharge:SetRelativeWidth(0.65);
	timePerCharge:SetText(
		L("TColon2", L["ServiceInterfaces"]["Timer"], L["TotalTime"])
	);
	frame:AddRow(4);
	frame:AddWidget(timePerCharge);
end

--- Upgrades the trigger from the specified version to the current version.
-- @param version The version to upgrade from.
-- @param params  The trigger parameters to upgrade.
function SpellCharges:Upgrade(version, params)
end