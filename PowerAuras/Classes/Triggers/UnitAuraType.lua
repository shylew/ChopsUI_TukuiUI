-- Lock down local environment.
local PowerAuras = select(2, ...);
setfenv(1, PowerAuras);

--- Mapping of effect spell ID's and their spell effect types.
local CustomSpellTypeMap = {
	-- Debuff: Weakened Armor (stacking armor reduction)
	[113746] = 0x20,

	-- Debuff: Physical Vulnerability
	[81326]  = 0x40,

	-- Debuff: Weakened Blows
	[115798] = 0x80,
	[109466] = 0x80, -- Curse of Enfeeblement

	-- Debuff: Mortal Wounds
	[115804] = 0x100,
	[82654]  = 0x100, -- Widow Venom
	[8680]   = 0x100, -- Wound Poison

	-- Debuff: Magic Vulnerability
	[93068]  = 0x200, -- Master Poisoner
	[1490]   = 0x200, -- Curse of the Elements

	-- Debuff: Slow Casting
	[73975]  = 0x400, -- Necrotic Strike
	[5760]   = 0x400, -- Mind-numbing Poison
	[109466] = 0x400, -- Curse of Enfeeblement

	-- Buff: Stats
	[1126]   = 0x800,
	[117666] = 0x800,
	[20217]  = 0x800,
	[90363]  = 0x800,

	-- Buff: Stamina
	[21562]  = 0x1000,
	[103127] = 0x1000,
	[469]    = 0x1000,
	[90364]  = 0x1000,

	-- Buff: Attack Power
	[57330]  = 0x2000,
	[19506]  = 0x2000,
	[6673]   = 0x2000,

	-- Buff: Spell Power
	[1459]   = 0x4000,
	[61316]  = 0x4000,
	[77747]  = 0x4000,
	[109773] = 0x4000,
	[126309] = 0x4000,

	-- Buff: Haste
	[55610]  = 0x8000,
	[113742] = 0x8000,
	[30809]  = 0x8000,
	[128432] = 0x8000,
	[128433] = 0x8000,

	-- Buff: Spell Haste
	[24907]  = 0x10000,
	[15473]  = 0x10000,
	[51470]  = 0x10000,

	-- Buff: Critical Strike
	[17007]  = 0x20000,
	[1459]   = 0x20000,
	[61316]  = 0x20000,
	[116781] = 0x20000,
	[97229]  = 0x20000,
	[24604]  = 0x20000,
	[90309]  = 0x20000,
	[126373] = 0x20000,
	[126309] = 0x20000,

	-- Buff: Mastery
	[19740]  = 0x40000,
	[116956] = 0x40000,
	[93435]  = 0x40000,
	[128997] = 0x40000,
};

--- Checks if the passed effect is in the custom spell map.
-- @param self       The bit index to check.
-- @param unit       The unit to query.
-- @param index      The index of the effect to query.
-- @param filter     The filter used by UnitAura.
-- @param id         The ID of the effect.
-- @param effectType The dispel type of the effect.
local function CheckCustomEffect(self, unit, index, filter, id, effectType)
	-- Is this in the map?
	if(CustomSpellTypeMap[id]) then
		local v = 2^(self - 1);
		return bit.band(v, CustomSpellTypeMap[id]) == v;
	end
	-- Failed.
	return false;
end

--- List of effect types. Index is the bit index.
local EffectTypes = {
	-- Curse effects.
	[1] = function(self, unit, index, filter, id, effectType)
		return effectType == "Curse";
	end,
	-- Disease effects.
	[2] = function(self, unit, index, filter, id, effectType)
		return effectType == "Disease";
	end,
	-- Magic effects.
	[3] = function(self, unit, index, filter, id, effectType)
		return effectType == "Magic";
	end,
	-- Poison effects.
	[4] = function(self, unit, index, filter, id, effectType)
		return effectType == "Poison";
	end,
	-- Enrage effects.
	[5] = function(self, unit, index, filter, id, effectType)
		-- Scan the tooltip for this one.
		local iter, _t, _i = PowerAuras:GetTooltipLines();
		local _, text = iter(_t, 0);
		return (text == _G.ENCOUNTER_JOURNAL_SECTION_FLAG11)
	end,
	-- Debuff: Weakened Armor
	[6] = CheckCustomEffect,
	-- Debuff: Physical Vulnerability
	[7] = CheckCustomEffect,
	-- Debuff: Weakened Blows
	[8] = CheckCustomEffect,
	-- Debuff: Mortal Wounds
	[9] = CheckCustomEffect,
	-- Debuff: Magic Vulnerability
	[10] = CheckCustomEffect,
	-- Debuff: Slow Casting
	[11] = CheckCustomEffect,
	-- Buff: Stats
	[12] = CheckCustomEffect,
	-- Buff: Stamina
	[13] = CheckCustomEffect,
	-- Buff: Attack Power
	[14] = CheckCustomEffect,
	-- Buff: Spell Power
	[15] = CheckCustomEffect,
	-- Buff: Haste
	[16] = CheckCustomEffect,
	-- Buff: Spell Haste
	[17] = CheckCustomEffect,
	-- Buff: Critical Strike
	[18] = CheckCustomEffect,
	-- Buff: Mastery
	[19] = CheckCustomEffect,
};

--- Checks the specified unit for an effect type.
-- @param unit   The unit to check.
-- @param filter The filter to use.
-- @param match  The match data to find.
-- @param start  The starting index to scan from.
local function CheckUnit(unit, filter, match, start)
	-- Expand the match data.
	local castBy    = match["CastBy"];
	local stealable = match["Stealable"];

	-- Check for effects on this unit.
	local i, max, start = 1, 40, start or 1;
	-- If start is 1, wrapping isn't needed.
	local wrapped = (start == 1);
	while(i <= max) do
		-- Get the real index.
		local j = ((start + i - 2) % max) + 1;

		-- Get effect data.
		-- NOTE: 5.1.0 (or later) will have the cast by player character (cbPC)
		-- argument will always be at index #14.
		local name, _, _, v0, eType, _, _, caster, isStealable, _,
			id, _, _, v1, v2, v3--[[, cbPC]] = UnitAura(unit, j, filt);

		-- Effect exists?
		if(not name and not wrapped) then
			-- Wrap around.
			i = max - (((start + max - 2) % max) + 1) + 1;
			wrapped = true;
		elseif(not name and wrapped) then
			-- Not found, and we've wrapped.
			return false;
		else
			-- Start testin'!
			for k = 1, #(match.Match) do
				-- Test the slot.
				local slot = match.Match[k];
				if(EffectTypes[slot](slot, unit, j, filter, id, eType)) then
					-- Now check the other stuff.
					local result = ((castBy and caster == castBy or not castBy)
						and (stealable and isStealable or not stealable));

					-- Succeeded?
					if(result) then
						return true, j;
					end
				end
			end

			-- Next.
			i = i + 1;
		end
	end
	-- Getting here indicates failure.
	return false;
end

--- Trigger class definition.
local UnitAuraType = PowerAuras:RegisterTriggerClass("UnitAuraType", {
	--- Dictionary of default parameters this trigger uses.
	Parameters = {
		Unit = PowerAuras:EncodeUnits("player"),
		Type = 1, -- 1 = Buff, 2 = Debuff.
		Match = 0x0000001F,
		CastBy = "player",
		Stealable = false,
	},
	--- Dictionary of events this trigger responds to.
	Events = {
		ARENA_OPPONENT_UPDATE = { "ArenaAuraType", "UnitAuraType" },
		GROUP_ROSTER_UPDATE = function(buffer)
			buffer.Triggers["UnitAuraType"] = true;
			if(IsInRaid()) then
				buffer.Triggers["RaidAuraType"] = true;
				buffer.Triggers["RaidPetAuraType"] = true;
			else
				buffer.Triggers["PartyAuraType"] = true;
				buffer.Triggers["PartyPetAuraType"] = true;
			end
			buffer.Triggers["GroupAuraType"] = true;
		end,
		INSTANCE_ENCOUNTER_ENGAGE_UNIT = { "BossAuraType", "UnitAuraType" },
		PLAYER_FOCUS_CHANGED = { "FocusAuraType", "UnitAuraType" },
		PLAYER_TARGET_CHANGED = function(buffer)
			-- If not in a raid, flag party for checks.
			buffer.Triggers["UnitAuraType"] = true;
			if(not IsInRaid()) then
				buffer.Triggers["GroupAuraType"] = true;
			end
			buffer.Triggers["TargetAuraType"] = true;
		end,
		UNIT_AURA = function(buffer, unit)
			-- Flag triggers based on unit.
			buffer.Triggers["UnitAuraType"] = true;
			if(unit == "player") then
				buffer.Triggers["PartyAuraType"] = true;
				buffer.Triggers["GroupAuraType"] = true;
				buffer.Triggers["PlayerAuraType"] = true;
			elseif(unit == "pet") then
				buffer.Triggers["PetAuraType"] = true;
			elseif(unit == "vehicle") then
				buffer.Triggers["VehicleAuraType"] = true;
			elseif(unit == "target") then
				buffer.Triggers["TargetAuraType"] = true;
			elseif(unit == "focus") then
				buffer.Triggers["FocusAuraType"] = true;
			elseif(unit ~= nil) then
				-- Likely a group unit.
				local match = unit:match("%a+");
				if(match == "party") then
					buffer.Triggers["PartyAuraType"] = true;
				elseif(match == "partypet") then
					buffer.Triggers["PartyPetAuraType"] = true;
				elseif(match == "raid") then
					buffer.Triggers["RaidAuraType"] = true;
				elseif(match == "raidpet") then
					buffer.Triggers["RaidPetAuraType"] = true;
				elseif(match == "arena") then
					buffer.Triggers["ArenaAuraType"] = true;
				elseif(match == "boss") then
					buffer.Triggers["BossAuraType"] = true;
				elseif(match == "group") then
					buffer.Triggers["GroupAuraType"] = true;
				end
			end
		end,
		UNIT_ENTERED_VEHICLE = { "VehicleAuraType", "UnitAuraType" },
		UNIT_EXITED_VEHICLE = { "VehicleAuraType", "UnitAuraType" },
		UNIT_PET = { "PetAuraType", "UnitAuraType" },
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
function UnitAuraType:New(parameters)
	-- Decode our parameters.
	local units = PowerAuras:DecodeUnits(parameters["Unit"]);
	local match = PowerAuras:CopyTable(parameters);

	-- Preprocess the matches into just the respective check functions.
	local funcs = {};
	for i = 1, #(EffectTypes) do
		if(bit.band(match.Match, 2^(i - 1)) > 0) then
			tinsert(funcs, i);
		end
	end
	-- Store the table.
	match.Match = funcs;

	-- Turn the type into a filter string.
	local filter = (parameters["Type"] == 2 and "HARMFUL" or "HELPFUL");
	local start = 1;

	-- Return the trigger.
	local UnitAura = _G.UnitAura;
	return function(self, buffer, action, store)
		-- Process units.
		local result, unit, slot = PowerAuras:CheckUnits(
			units, CheckUnit, filter, match, start
		);

		-- Store the index for faster rechecks.
		start = slot;
		if(result) then
			-- Get data to share with our source.
			local name, _, icon, v0, type, dur, exp, caster, steal,
				_, id, _, _, v1, v2, v3 = UnitAura(unit, slot, filter);
			-- Store data in sensible slots.
			store.Texture        = icon;
			store.TimerStart     = ((exp or 2^31 - 1) - (dur or 0));
			store.TimerEnd       = (exp or 2^31 - 1);
			store.Stacks         = v0;
			store.Text["name"]   = name;
			store.Text["icon"]   = ("|T%s:0:0|t"):format(icon);
			store.Text["count"]  = v0;
			store.Text["type"]   = type;
			store.Text["caster"] = caster;
			store.Text["id"]     = id;
			store.Text["tt1"]    = tonumber(v1) or 0;
			store.Text["tt2"]    = tonumber(v2) or 0;
			store.Text["tt3"]    = tonumber(v3) or 0;
		else
			store.Texture        = nil;
			store.TimerStart     = nil;
			store.TimerEnd       = nil;
			store.Stacks         = nil;
			store.Text["name"]   = "";
			store.Text["icon"]   = "";
			store.Text["count"]  = "";
			store.Text["type"]   = "";
			store.Text["caster"] = "";
			store.Text["id"]     = "";
			store.Text["tt1"]    = "";
			store.Text["tt2"]    = "";
			store.Text["tt3"]    = "";
		end
		-- Return the result.
		return result;
	end
end

--- Updates the items in the dropdown.
-- @param frame The dropdown frame.
-- @param value The match data.
local function GetBitFlag(frame, value)
	-- Check items.
	frame:SetRawText(L["None"]);
	local hasChecked = false;
	for i, item in ipairs(frame.ItemsByKey["__ROOT__"]) do
		-- Check the item.
		local checked = (bit.band(2^(i - 1), value) > 0);
		frame:SetItemChecked(item.Key, checked);
		-- Update the text.
		if(not hasChecked and checked) then
			frame:SetText(item.Key);
			hasChecked = true;
		elseif(checked) then
			frame:SetRawText(L["Multiple"]);
		end
	end
end

--- Sets an item bit flag.
-- @param frame The dropdown frame.
-- @param value The bit flag.
local function SetBitFlag(frame, value)
	-- Get the existing parameters and XOR the flag.
	local _, aID, _, tID = PowerAuras:SplitNodeID(frame:GetID());
	local match = PowerAuras:GetParameter("Trigger", "Match", aID, tID);
	match = bit.bxor(match, 2^(value - 1));
	PowerAuras:SetParameter("Trigger", "Match", match, aID, tID);
end

--- Creates the controls for the basic activation editor frame.
-- @param frame The frame to apply controls to.
-- @param ... ID's to use for Get/SetParameter calls.
function UnitAuraType:CreateTriggerEditor(frame, ...)
	-- Effect match.
	local effectMatch = PowerAuras:Create("SimpleDropdown", frame);
	effectMatch:SetUserTooltip("UnitAuraType_Match");
	effectMatch:SetTitle(L["UnitAuraType_Match"]);
	effectMatch:SetRelativeWidth(0.7);
	effectMatch:SetPadding(4, 0, 2, 0);
	effectMatch:SetID(PowerAuras:GetNodeID(nil, ..., 0, select(2, ...), 0, 0));
	for i = 1, #(EffectTypes) do
		effectMatch:AddCheckItem(i, L["UnitAuraType"][i], nil, true);
	end
	GetBitFlag(effectMatch, PowerAuras:GetParameter("Trigger", "Match", ...));
	effectMatch:ConnectParameter("Trigger", "Match", GetBitFlag, ...);
	effectMatch.OnValueUpdated:Connect(SetBitFlag);
	frame:AddWidget(effectMatch);

	-- Effect type.
	local effectType = PowerAuras:Create("P_Dropdown", frame);
	effectType:SetUserTooltip("UnitAuraType_MatchType");
	effectType:SetTitle(L["Type"]);
	effectType:SetRelativeWidth(0.3);
	effectType:SetPadding(2, 0, 4, 0);
	effectType:AddCheckItem(1, L["Buff"]);
	effectType:AddCheckItem(2, L["Debuff"]);
	effectType:LinkParameter("Trigger", "Type", ...);
	frame:AddWidget(effectType);

	-- Unit selection dialog.
	local unitBox = PowerAuras:Create("DialogBox", frame, nil, "UnitDialog",
		"Trigger", "Unit", ...);
	unitBox:SetUserTooltip("UnitAuraType_Unit");
	unitBox:SetTitle(L["Unit"]);
	unitBox:SetRelativeWidth(1 / 3);
	unitBox:SetPadding(4, 0, 2, 0);
	unitBox:SetText(PowerAuras:GetParameter("Trigger", "Unit", ...));
	unitBox:ConnectParameter("Trigger", "Unit", unitBox.SetText, ...);
	unitBox.OnValueUpdated:Connect(PowerAuras:FormatString([[
		local self, value = ...;
		PowerAuras:SetParameter("Trigger", "Unit", value, ${...});
	]], ...));
	frame:AddWidget(unitBox);

	-- Cast by player?
	local castBy = PowerAuras:Create("Checkbox", frame);
	castBy:SetUserTooltip("UnitAuraType_IsMine");
	castBy:SetRelativeWidth(1 / 3);
	castBy:SetMargins(0, 20, 0, 0);
	castBy:SetPadding(2, 0, 2, 0);
	castBy:SetText(L["IsMine"]);
	castBy:ConnectParameter("Trigger", "CastBy", castBy.SetChecked, ...);
	castBy.OnValueUpdated:Connect(PowerAuras:FormatString([[
		local self, value = ...;
		PowerAuras:SetParameter(
			"Trigger", "CastBy", (value and "player" or false), ${...}
		);
	]], ...));
	frame:AddWidget(castBy);

	-- Stealable?
	local steal = PowerAuras:Create("P_Checkbox", frame);
	steal:SetUserTooltip("UnitAuraType_StealPurge");
	steal:SetRelativeWidth(1 / 3);
	steal:SetMargins(0, 20, 0, 0);
	steal:SetPadding(2, 0, 4, 0);
	steal:SetText(L["Stealable"]);
	steal:LinkParameter("Trigger", "Stealable", ...);
	frame:AddWidget(steal);
end

--- Returns the trigger type name.
-- @param params The parameters of the trigger.
function UnitAuraType:GetTriggerType(params)
	-- Decode the unit parameter.
	local unit = PowerAuras:DecodeUnits(params["Unit"]);
	if(PowerAuras:IsValidUnitID(unit)) then
		return ("%sAuraType"):format(
			params["Unit"]:match("^(%a-)%d*%-?[alny]*$")
			              :gsub("^%a", string.upper, 1)
		);
	else
		return "UnitAuraType";
	end
end

--- Initialises the per-trigger data store. This can be used to hold
--  values which can then be exposed to other parts of the system.
-- @param params The parameters of this trigger.
-- @return An item to store, or nil.
function UnitAuraType:InitialiseDataStore(params)
	-- We can communicate to sources, so set this up appropriately.
	return {
		Stacks = 0,
		Text = {
			name   = "",
			icon   = "",
			count  = 0,
			type   = "",
			caster = "",
			id     = 0,
			tt1    = 0,
			tt2    = 0,
			tt3    = 0,
		},
		Texture = PowerAuras.DefaultIcon,
		TimerStart = 0,
		TimerEnd = 2^31 - 1,
	};
end

--- Upgrades the trigger from the specified version to the current version.
-- @param version The version to upgrade from.
-- @param params  The trigger parameters to upgrade.
function UnitAuraType:Upgrade(version, params)
end