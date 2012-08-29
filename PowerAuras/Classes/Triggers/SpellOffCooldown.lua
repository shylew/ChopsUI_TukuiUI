-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--- Trigger class definition.
local SpellOffCooldown = PowerAuras:RegisterTriggerClass("SpellOffCooldown", {
	--- Dictionary of default parameters this trigger uses.
	Parameters = {
		Match = "<Ability Name>",
		IgnoreGCD = true,
		IgnoreGCDEnd = true,
		Usable = true,
		Known = true,
	},
	--- Dictionary of events this trigger responds to.
	Events = {
		SPELL_UPDATE_USABLE = "SpellOffCooldown",
		SPELL_UPDATE_COOLDOWN = "SpellOffCooldown",
		SPELL_UPDATE_USABLE = "SpellOffCooldown",
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
function SpellOffCooldown:New(parameters)
	-- Extract parameters.
	local match     = parameters["Match"];
	local ignoreGCD = parameters["IgnoreGCD"];
	local ignoreEnd = parameters["IgnoreGCDEnd"];
	local usable    = parameters["Usable"];
	local known     = parameters["Known"];

	-- GCD detection.
	local gcdSpell = PowerAuras.GCDSpells[select(2, UnitClass("player"))];
	gcdSpell = tonumber(gcdSpell) or tostring(gcdSpell);
	local classGCD = 0;

	-- Generate function.
	return function(self, buffer, action, store)
		-- Get the cooldown.
		local start, duration = GetSpellCooldown(match);
		local gcdStart, gcd = GetSpellCooldown(gcdSpell);
		if(not start) then
			-- Failed, spell doesn't exist.
			return false;
		end

		-- Fix the GCD duration, and store the classwide-GCD if needed.
		gcd = gcd or 0;
		gcdStart = gcdStart or 0;
		if(classGCD ~= gcd and gcd > 0) then
			classGCD = gcd;
		end

		-- Check the cooldown. Ignoring the GCD means this won't show as
		-- being on cooldown during it, and it'll show as being off cooldown
		-- during it too.
		local state;
		if(duration > 0) then
			-- Spell is on cooldown, does it match the GCD?
			if(ignoreGCD and duration == classGCD) then
				-- We just triggered the GCD, we haven't used the spell.
				state = true;
			elseif(ignoreEnd) then
				-- Get remaining cooldown and GCD time.
				-- Round up to the first decimal place. This fixes flickering
				-- issues.
				local time = math.ceil(GetTime() * 10) / 10;
				local remCD = (start + duration) - time;
				local remGCD = (gcd > 0 and (gcdStart + gcd) - time or 0);
				if(remCD <= classGCD and remGCD >= remCD) then
					-- The cooldown will end when the GCD ends.
					state = true;
				elseif(remCD <= classGCD and remGCD < remCD) then
					-- The cooldown will end after the GCD ends.
					state = false;
				else
					-- The cooldown probably isn't going to end any time soon.
					state = false;
				end
			else
				-- Spell is on cooldown then.
				state = false;
			end
		else
			-- Not on CD.
			state = true;
		end

		-- Update the timers and stuff.
		if(not state) then
			store.TimerStart = start;
			store.TimerEnd = (start + duration);
		else
			store.TimerStart = nil;
			store.TimerEnd = nil;
		end

		-- Return the state and usable status.
		local isUsable = (usable and IsUsableSpell(match) or not usable);
		local isKnown = (not known);
		-- Is the match numeric?
		if(not isKnown and type(match) == "number") then
			isKnown = IsSpellKnown(match, false) or IsSpellKnown(match, true);
		elseif(not isKnown) then
			-- It's a spell name - IsSpellKnown needs an ID.
			local id = PowerAuras.SpellIDLookup[match];
			isKnown = (id > 0
				and (IsSpellKnown(id, false) or IsSpellKnown(id, true))
				or false);
		end

		return state and isUsable and isKnown;
	end;
end

--- Creates the controls for the basic activation editor frame.
-- @param frame The frame to apply controls to.
-- @param ... ID's to use for Get/SetParameter calls.
function SpellOffCooldown:CreateTriggerEditor(frame, ...)
	-- Spell match.
	local match = PowerAuras:Create("P_EditBox", frame);
	match:SetUserTooltip("SpellOffCooldown_Match");
	match:LinkParameter("Trigger", "Match", ...);
	match:SetPadding(4, 0, 2, 0);
	match:SetRelativeWidth(0.5);
	match:SetTitle(L["SpellOffCooldown_Match"]);
	frame:AddWidget(match);

	-- Spell usable.
	local usable = PowerAuras:Create("P_Checkbox", frame);
	usable:SetUserTooltip("SpellOffCooldown_Usable");
	usable:LinkParameter("Trigger", "Usable", ...);
	usable:SetMargins(0, 20, 0, 0);
	usable:SetPadding(2, 0, 4, 0);
	usable:SetRelativeWidth(0.5);
	usable:SetText(L["Usable"]);
	frame:AddWidget(usable);
	frame:AddRow(4);

	-- GCD ignoring.
	local ignoreGCD = PowerAuras:Create("P_Checkbox", frame);
	ignoreGCD:SetUserTooltip("SpellOffCooldown_IgnoreGCD");
	ignoreGCD:LinkParameter("Trigger", "IgnoreGCD", ...);
	ignoreGCD:SetPadding(4, 0, 2, 0);
	ignoreGCD:SetRelativeWidth(0.5);
	ignoreGCD:SetText(L["IgnoreGCD"]);
	frame:AddWidget(ignoreGCD);

	-- Spell known.
	local known = PowerAuras:Create("P_Checkbox", frame);
	known:SetUserTooltip("SpellOffCooldown_Known");
	known:LinkParameter("Trigger", "Known", ...);
	known:SetPadding(2, 0, 4, 0);
	known:SetRelativeWidth(0.5);
	known:SetText(L["Known"]);
	frame:AddWidget(known);
	frame:AddRow(4);

	-- Ignore end of GCD.
	local ignoreEnd = PowerAuras:Create("P_Checkbox", frame);
	ignoreEnd:SetUserTooltip("SpellOffCooldown_IgnoreGCDEnd");
	ignoreEnd:LinkParameter("Trigger", "IgnoreGCDEnd", ...);
	ignoreEnd:SetPadding(4, 0, 2, 0);
	ignoreEnd:SetRelativeWidth(0.5);
	ignoreEnd:SetText(L["IgnoreGCDEnd"]);
	frame:AddWidget(ignoreEnd);
end

--- Initialises the per-trigger data store. This can be used to hold
--  values which can then be exposed to other parts of the system.
-- @param params The parameters of this trigger.
-- @return An item to store, or nil.
function SpellOffCooldown:InitialiseDataStore(params)
	return {
		Texture = select(3, GetSpellInfo(params["Match"])),
		TimerStart = 0,
		TimerEnd = 2^31 - 1,
	};
end

--- Determines whether or not a trigger requires per-frame updates.
-- @param params The parameters of the trigger.
-- @return True if updates are required, false if not.
-- @return The first value is the default timed state on creation. The 
--         second boolean is whether or not the timed status is capable of
--         being toggled by the trigger.
function SpellOffCooldown:IsTimed(params)
	return true, false;
end

--- Upgrades the trigger from the specified version to the current version.
-- @param version The version to upgrade from.
-- @param params  The trigger parameters to upgrade.
function SpellOffCooldown:Upgrade(version, params)
	-- 5.0.0.A -> 5.0.0.M
	if(version < PowerAuras.Version("5.0.0.M")) then
		-- Added known parameter.
		params.Known = true;
	end
end